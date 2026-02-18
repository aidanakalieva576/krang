package com.krang.backend.service;

import java.sql.Timestamp;

import com.krang.backend.dto.*;

import lombok.RequiredArgsConstructor;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
@RequiredArgsConstructor
public class AdminStatsService {

    private final JdbcTemplate jdbc;

    public AdminStatsResponse getStats(StatsRange range) {
        TimeWindow w = window(range);

        // 1) TOP MOVIES
        // считаем суммарное watch_time_sec по movie_id за период
        var topMovies = jdbc.query(""" 
                select wl.movie_id as id,
                       coalesce(m.title,'') as title,
                       coalesce(m.thumbnail_url,'') as thumbnailUrl,
                       coalesce(sum(wl.watch_time_sec),0) as watchSec
                from watch_logs wl
                left join movies m on m.id = wl.movie_id
                where wl.watched_at >= ? and wl.watched_at < ?
                group by wl.movie_id, m.title, m.thumbnail_url
                order by watchSec desc
                limit 10
                """,
                (rs, i) -> new TopMovieDto(
                        rs.getLong("id"),
                        rs.getString("title"),
                        rs.getString("thumbnailUrl"),
                        rs.getLong("watchSec")
                ),
                Timestamp.from(w.start), Timestamp.from(w.end)
        );

        // 2) VIEWING SERIES (для графика)
        // сегодня: по часам; неделя/месяц: по дням; год: по месяцам
        var series = buildSeries(range, w);

        // 3) GENRES (категории) — топ по времени просмотра
        // предполагаю movies.category_id -> categories.id
        var genresRaw = jdbc.query("""
                select c.name as name,
                       coalesce(sum(wl.watch_time_sec),0) as watchSec
                from watch_logs wl
                join movies m on m.id = wl.movie_id
                left join categories c on c.id = m.category_id
                where wl.watched_at >= ? and wl.watched_at < ?
                group by c.name
                order by watchSec desc
                limit 4
                """,
                (rs, i) -> Map.entry(
                        rs.getString("name") == null ? "Unknown" : rs.getString("name"),
                        rs.getLong("watchSec")
                ),
                Timestamp.from(w.start), Timestamp.from(w.end)
        );

        long totalGenreSec = genresRaw.stream().mapToLong(Map.Entry::getValue).sum();
        List<GenreDto> genres = new ArrayList<>();
        for (var e : genresRaw) {
            double pct = totalGenreSec == 0 ? 0.0 : (e.getValue() * 100.0 / totalGenreSec);
            genres.add(new GenreDto(e.getKey(), e.getValue(), pct));
        }

        return new AdminStatsResponse(range.name(), topMovies, series, genres);
    }

    private List<SeriesPointDto> buildSeries(StatsRange range, TimeWindow w) {
        return switch (range) {
            case today -> seriesByHour(w);
            case week, month -> seriesByDay(w);
            case year -> seriesByMonth(w);
        };
    }

    private List<SeriesPointDto> seriesByHour(TimeWindow w) {
        // label = "00", "01"... "23"
        var map = new HashMap<Integer, Long>();

        jdbc.query("""
                select extract(hour from wl.watched_at) as h,
                       coalesce(sum(wl.watch_time_sec),0) as s
                from watch_logs wl
                where wl.watched_at >= ? and wl.watched_at < ?
                group by h
                """,
                rs -> {
                    map.put(rs.getInt("h"), rs.getLong("s"));
                },
                Timestamp.from(w.start), Timestamp.from(w.end)
        );

        List<SeriesPointDto> out = new ArrayList<>();
        for (int h = 0; h < 24; h++) {
            out.add(new SeriesPointDto(String.format("%02d", h), map.getOrDefault(h, 0L)));
        }
        return out;
    }

    private List<SeriesPointDto> seriesByDay(TimeWindow w) {
        var map = new HashMap<LocalDate, Long>();
        jdbc.query("""
                select date(wl.watched_at) as d,
                       coalesce(sum(wl.watch_time_sec),0) as s
                from watch_logs wl
                where wl.watched_at >= ? and wl.watched_at < ?
                group by d
                """,
                rs -> {
                    map.put(rs.getDate("d").toLocalDate(), rs.getLong("s"));
                },
                Timestamp.from(w.start), Timestamp.from(w.end)
        );

        List<SeriesPointDto> out = new ArrayList<>();
        LocalDate cur = w.start.atZone(w.zone).toLocalDate();
        LocalDate endDate = w.end.minusSeconds(1).atZone(w.zone).toLocalDate();

        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM");
        while (!cur.isAfter(endDate)) {
            out.add(new SeriesPointDto(cur.format(fmt), map.getOrDefault(cur, 0L)));
            cur = cur.plusDays(1);
        }
        return out;
    }

    private List<SeriesPointDto> seriesByMonth(TimeWindow w) {
        var map = new HashMap<YearMonth, Long>();

        jdbc.query("""
                select extract(year from wl.watched_at) as y,
                       extract(month from wl.watched_at) as m,
                       coalesce(sum(wl.watch_time_sec),0) as s
                from watch_logs wl
                where wl.watched_at >= ? and wl.watched_at < ?
                group by y, m
                """,
                rs -> {
                    int y = rs.getInt("y");
                    int m = rs.getInt("m");
                    map.put(YearMonth.of(y, m), rs.getLong("s"));
                },
                Timestamp.from(w.start), Timestamp.from(w.end)
        );

        List<SeriesPointDto> out = new ArrayList<>();
        YearMonth cur = YearMonth.from(w.start.atZone(w.zone));
        YearMonth end = YearMonth.from(w.end.minusSeconds(1).atZone(w.zone));

        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("MMM");
        while (!cur.isAfter(end)) {
            out.add(new SeriesPointDto(cur.atDay(1).format(fmt), map.getOrDefault(cur, 0L)));
            cur = cur.plusMonths(1);
        }
        return out;
    }

    private TimeWindow window(StatsRange range) {
        ZoneId zone = ZoneId.systemDefault();
        ZonedDateTime now = ZonedDateTime.now(zone);

        Instant start;
        Instant end = now.toInstant();

        start = switch (range) {
            case today -> now.toLocalDate().atStartOfDay(zone).toInstant();
            case week -> now.minusDays(6).toLocalDate().atStartOfDay(zone).toInstant();  // 7 дней включая сегодня
            case month -> now.minusDays(29).toLocalDate().atStartOfDay(zone).toInstant(); // 30 дней
            case year -> now.minusDays(364).toLocalDate().atStartOfDay(zone).toInstant(); // 365 дней
        };

        return new TimeWindow(zone, start, end);
    }

    private record TimeWindow(ZoneId zone, Instant start, Instant end) {}
}
