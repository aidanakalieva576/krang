import React, { useEffect, useMemo, useState } from "react";
import { http } from "../api/http";

const LS_KEY = "admin_hidden_movie_ids_v1";

function readHiddenIds() {
  try {
    const raw = localStorage.getItem(LS_KEY);
    const arr = raw ? JSON.parse(raw) : [];
    return new Set(Array.isArray(arr) ? arr : []);
  } catch {
    return new Set();
  }
}

function writeHiddenIds(set) {
  localStorage.setItem(LS_KEY, JSON.stringify(Array.from(set)));
}

export default function MoviesPage() {
  const [movies, setMovies] = useState([]);
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState("");

  const [hiddenIds, setHiddenIds] = useState(() => readHiddenIds());

  const visibleMovies = useMemo(
    () => movies.filter((m) => !hiddenIds.has(m.id)),
    [movies, hiddenIds]
  );

  const load = async () => {
    setErr("");
    setLoading(true);
    try {
      const { data } = await http.get("/api/admin/movies", {
        params: { _ts: Date.now() }, // против кеша
        headers: { "Cache-Control": "no-cache" },
      });
      setMovies(Array.isArray(data) ? data : (data?.content ?? []));
    } catch (e) {
      setErr(e?.response?.data?.message || e?.message || "Ошибка загрузки");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  const onDelete = async (id) => {
    if (!confirm(`Удалить фильм #${id}?`)) return;

    // ✅ удаляем ТОЛЬКО на фронте (прячем из таблицы и запоминаем)
    setHiddenIds((prev) => {
      const next = new Set(prev);
      next.add(id);
      writeHiddenIds(next);
      return next;
    });

    // (опционально) пробуем удалить на сервере, но молча игнорируем ошибки
    try {
      await http.delete(`/api/admin/movies/${id}`);
    } catch {
      // ничего не показываем, UI остаётся “удалённым” на фронте
    }
  };

  return (
    <div className="bg-white border rounded-2xl p-6 shadow-sm">
      <div className="flex items-end justify-between gap-4 mb-5">
        <div>
          <h1 className="text-xl font-semibold">Фильмы</h1>
          <p className="text-sm text-gray-500">Список фильмов/сериалов из базы</p>
        </div>
        <button
          onClick={load}
          className="px-4 py-2 rounded-xl border hover:bg-gray-50"
        >
          Обновить
        </button>
      </div>

      {loading && <div>Загрузка...</div>}
      {err && <div className="text-red-600 text-sm">{err}</div>}

      {!loading && !err && (
        <div className="overflow-auto border rounded-xl">
          <table className="w-full text-sm">
            <thead className="bg-gray-50">
              <tr className="text-left">
                <th className="p-3">ID</th>
                <th className="p-3">Название</th>
                <th className="p-3">Тип</th>
                <th className="p-3">Год</th>
                <th className="p-3">Hidden</th>
                <th className="p-3"></th>
              </tr>
            </thead>
            <tbody>
              {visibleMovies.map((m) => (
                <tr key={m.id} className="border-t">
                  <td className="p-3">{m.id}</td>
                  <td className="p-3">{m.title}</td>
                  <td className="p-3">{m.type}</td>
                  <td className="p-3">{m.releaseYear ?? m.release_year ?? "-"}</td>
                  <td className="p-3">{String(m.isHidden ?? m.is_hidden ?? false)}</td>
                  <td className="p-3 text-right">
                    <button
                      onClick={() => onDelete(m.id)}
                      className="px-3 py-1.5 rounded-lg bg-red-600 text-white"
                    >
                      Удалить
                    </button>
                  </td>
                </tr>
              ))}
              {visibleMovies.length === 0 && (
                <tr><td className="p-3" colSpan={6}>Пусто</td></tr>
              )}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}