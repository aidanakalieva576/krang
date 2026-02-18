import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:krang/api/api_config.dart';
import 'package:krang/components/navbar_admin.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum StatsRange { today, week, month, year }

String rangeLabel(StatsRange r) {
  switch (r) {
    case StatsRange.today:
      return 'Today';
    case StatsRange.week:
      return 'Week';
    case StatsRange.month:
      return 'Month';
    case StatsRange.year:
      return 'Year';
  }
}

class TopMovie {
  final String title;
  final String imageUrl;
  TopMovie({required this.title, required this.imageUrl});
}

class GenreStat {
  final String name;
  final double percent;
  GenreStat(this.name, this.percent);
}

class StatsPageAdmin extends StatefulWidget {
  const StatsPageAdmin({super.key});

  @override
  State<StatsPageAdmin> createState() => _StatsPageAdminState();
}

class _StatsPageAdminState extends State<StatsPageAdmin> {
  StatsRange _range = StatsRange.today;

  bool _loading = false;
  String? _error;

  // динамические данные
  List<TopMovie> _topMovies = [];
  List<double> _viewingSeries = [];
  List<GenreStat> _genres = [];

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  void _changeRange(StatsRange r) {
    if (_range == r) return;
    setState(() => _range = r);
    _fetchStats();
  }

  String _rangeToQuery(StatsRange r) {
    switch (r) {
      case StatsRange.today:
        return 'today';
      case StatsRange.week:
        return 'week';
      case StatsRange.month:
        return 'month';
      case StatsRange.year:
        return 'year';
    }
  }

  Future<void> _fetchStats() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _fetchStatsFromBackend(); // ✅ ВКЛЮЧАЕМ БЭК
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // 🔌 Подключение к backend (включишь когда будет endpoint)
  Future<void> _fetchStatsFromBackend() async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found (jwt_token)');

    final range = _rangeToQuery(_range);
    final url = Uri.parse('${ApiConfig.baseUrl}/api/admin/stats?range=$range');

    final res = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Stats error: ${res.statusCode} ${res.body}');
    }

    final body = json.decode(res.body);

    final List top = (body['topMovies'] as List? ?? []);
    final List series = (body['viewingSeries'] as List? ?? []);
    final List genres = (body['genres'] as List? ?? []);

    setState(() {
      _topMovies = top.map((x) {
        return TopMovie(
          title: (x['title'] ?? '').toString(),
          imageUrl: (x['thumbnailUrl'] ?? '').toString(), // ✅ ВАЖНО
        );
      }).toList();

      _viewingSeries = series.map((x) {
        // ✅ series = [{label, watchSec}]
        final sec = (x['watchSec'] ?? 0) as num;
        return sec.toDouble() / 60.0; // например переводим в минуты для графика
      }).toList();

      _genres = genres.map((x) {
        return GenreStat(
          (x['name'] ?? '').toString(),
          ((x['percent'] ?? 0) as num).toDouble(),
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF121212);
    const pillSelected = Color(0xFF8B8CA0);
    const pillUnselected = Color(0xFF2E2E31);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _fetchStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reports & Analytics',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ⏱️ Пилы
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _TimePill(
                            label: 'Today',
                            selected: _range == StatsRange.today,
                            colorSelected: pillSelected,
                            colorUnselected: pillUnselected,
                            onTap: () => _changeRange(StatsRange.today),
                          ),
                          const SizedBox(width: 10),
                          _TimePill(
                            label: 'Week',
                            selected: _range == StatsRange.week,
                            colorSelected: pillSelected,
                            colorUnselected: pillUnselected,
                            onTap: () => _changeRange(StatsRange.week),
                          ),
                          const SizedBox(width: 10),
                          _TimePill(
                            label: 'Month',
                            selected: _range == StatsRange.month,
                            colorSelected: pillSelected,
                            colorUnselected: pillUnselected,
                            onTap: () => _changeRange(StatsRange.month),
                          ),
                          const SizedBox(width: 10),
                          _TimePill(
                            label: 'Year',
                            selected: _range == StatsRange.year,
                            colorSelected: pillSelected,
                            colorUnselected: pillUnselected,
                            onTap: () => _changeRange(StatsRange.year),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    if (_error != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),

                    // 🎬 Top watched movies
                    const Text(
                      'Top Watched Movies',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    SizedBox(
                      height: 120,
                      child: _loading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _topMovies.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, i) {
                                final m = _topMovies[i];
                                return _MovieCardNet(
                                  imageUrl: m.imageUrl,
                                  title: m.title,
                                );
                              },
                            ),
                    ),

                    const SizedBox(height: 18),

                    // 📈 Viewing time
                    const Text(
                      'Viewing time',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      height: 200,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _loading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : CustomPaint(
                              painter: _LineChartPainter(
                                values: _viewingSeries,
                                maxVal: 60,
                                targetLine: 37,
                              ),
                              child: Container(),
                            ),
                    ),

                    const SizedBox(height: 20),

                    // 🌀 Top Genres
                    const Text(
                      'Top Genres',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 220,
                            height: 220,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(140),
                            ),
                            child: _loading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : CustomPaint(
                                    painter: _PieChartPainter(genres: _genres),
                                    child: Container(),
                                  ),
                          ),
                          const SizedBox(height: 14),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: _genres.take(4).map((g) {
                                return _GenreColumn(
                                  name: g.name,
                                  percent: '${g.percent.toStringAsFixed(0)}%',
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),

          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: NavbarAdmin(selectedIndex: 2),
          ),
        ],
      ),
    );
  }
}

class _TimePill extends StatelessWidget {
  final String label;
  final bool selected;
  final Color colorSelected;
  final Color colorUnselected;
  final VoidCallback onTap;

  const _TimePill({
    required this.label,
    required this.selected,
    required this.colorSelected,
    required this.colorUnselected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colorSelected : colorUnselected,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _MovieCardNet extends StatelessWidget {
  final String imageUrl;
  final String title;
  const _MovieCardNet({required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey[800]),
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 96,
          child: Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _GenreColumn extends StatelessWidget {
  final String name;
  final String percent;
  const _GenreColumn({required this.name, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(name, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 6),
        Text(
          percent,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final double maxVal;
  final double targetLine;

  _LineChartPainter({
    required this.values,
    required this.maxVal,
    required this.targetLine,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final axisPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 2;

    const graphShift = 13.0;

    canvas.drawLine(
      Offset(20 + graphShift, 8),
      Offset(20 + graphShift, size.height - 28),
      axisPaint,
    );
    canvas.drawLine(
      Offset(20 + graphShift, size.height - 28),
      Offset(size.width - 12 + graphShift, size.height - 28),
      axisPaint,
    );

    final left = 24.0 + graphShift;
    final top = 16.0;
    final bottom = size.height - 32;
    final plotWidth = size.width - left - 24;
    final dxStep = values.length == 1 ? 0 : plotWidth / (values.length - 1);

    // target dashed line
    final lineY = top + (1 - (targetLine / maxVal)) * (bottom - top);
    final dashPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.2;

    const dashWidth = 6.0;
    const dashSpace = 6.0;
    double startX = left;
    while (startX < left + plotWidth) {
      canvas.drawLine(
        Offset(startX, lineY),
        Offset(startX + dashWidth, lineY),
        dashPaint,
      );
      startX += dashWidth + dashSpace;
    }

    // series line
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = left + dxStep * i;
      final y = top + (1 - (values[i] / maxVal)) * (bottom - top);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = Colors.white;
    for (int i = 0; i < values.length; i++) {
      final x = left + dxStep * i;
      final y = top + (1 - (values[i] / maxVal)) * (bottom - top);
      canvas.drawCircle(Offset(x, y), 4.0, dotPaint);
      canvas.drawCircle(Offset(x, y), 2.0, Paint()..color = Colors.black87);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.maxVal != maxVal ||
        oldDelegate.targetLine != targetLine;
  }
}

class _PieChartPainter extends CustomPainter {
  final List<GenreStat> genres;
  _PieChartPainter({required this.genres});

  @override
  void paint(Canvas canvas, Size size) {
    if (genres.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 6;

    final paints = [
      Paint()..color = const Color(0xFF8B8CA0),
      Paint()..color = const Color(0xFFA1A2B8),
      Paint()..color = const Color(0xFF9A9BAB),
      Paint()..color = const Color(0xFF7F798C),
    ];

    final total = genres.fold<double>(0, (s, g) => s + g.percent);

    double startRadian = -pi / 2;
    for (int i = 0; i < genres.length; i++) {
      final sweep = (genres[i].percent / total) * 2 * pi;
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(rect, startRadian, sweep, true, paints[i % paints.length]);
      startRadian += sweep;
    }

    final border = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, border);
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.genres != genres;
  }
}
