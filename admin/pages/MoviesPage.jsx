import React, { useEffect, useState } from "react";
import { http } from "../api/http";

export default function MoviesPage() {
  const [movies, setMovies] = useState([]);
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState("");

  const load = async () => {
    setErr("");
    setLoading(true);
    try {
      const { data } = await http.get("/api/admin/movies");
      setMovies(Array.isArray(data) ? data : (data?.content ?? []));
    } catch (e) {
      setErr(e?.response?.data?.message || e?.message || "Ошибка загрузки");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, []);

  const onDelete = async (id) => {
    if (!confirm(`Удалить фильм #${id}?`)) return;
    await http.delete(`/api/admin/movies/${id}`);
    await load();
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
                <th className="p-3">Name</th>
                <th className="p-3"></th>
                <th className="p-3"></th>
                <th className="p-3">Hidden</th>
                <th className="p-3"></th>
              </tr>
            </thead>
            <tbody>
              {movies.map((m) => (
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
              {movies.length === 0 && (
                <tr><td className="p-3" colSpan={6}>Пусто</td></tr>
              )}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
