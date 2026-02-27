import React, { useEffect, useMemo, useState } from "react";
import { http } from "../api/http";

function pickId(u) {
  return u?.id ?? u?.userId ?? u?.user_id ?? u?.uuid ?? u?.uid ?? null;
}

function pickUsername(u) {
  return u?.username ?? u?.login ?? u?.name ?? u?.sub ?? "-";
}

function pickEmail(u) {
  return u?.email ?? u?.mail ?? u?.e_mail ?? "-";
}

function pickRole(u) {
  return u?.role ?? u?.authority ?? u?.authorities ?? "-";
}

function pickActive(u) {
  const v = u?.isActive ?? u?.is_active ?? u?.active ?? null;
  return v == null ? "-" : String(v);
}

export default function UsersControlPage() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState("");

  const load = async () => {
    setErr("");
    setLoading(true);
    try {
      const { data } = await http.get("/api/admin/users2", {
        params: { _ts: Date.now() },
        headers: { "Cache-Control": "no-cache" },
      });

      const list = Array.isArray(data) ? data : (data?.content ?? []);
      setUsers(list);
    } catch (e) {
      const status = e?.response?.status;
      if (status === 403) setErr("403: нет доступа к списку пользователей.");
      else if (status === 401) setErr("401: токен не принят. Перезайди в админку.");
      else setErr(e?.response?.data?.message || e?.message || "Ошибка загрузки");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  const visibleUsers = useMemo(() => users, [users]);

const onDelete = async (u) => {
  const email = pickEmail(u);
  if (!email || email === "-") return;

  if (!confirm(`Удалить пользователя ${email}?`)) return;

  setUsers(prev => prev.filter(x => pickEmail(x) !== email));

  try {
    await http.delete("/api/admin/delete", {
      data: { email }   // ✅ body
    });
  } catch (e) {
    setUsers(prev => [...prev, u]);
    alert("Ошибка удаления");
  }
};

  return (
    <div className="bg-white border rounded-2xl p-6 shadow-sm">
      <div className="flex items-end justify-between gap-4 mb-5">
        <div>
          <h1 className="text-xl font-semibold">Пользователи</h1>
          <p className="text-sm text-gray-500">Список пользователей из базы</p>
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
                <th className="p-3">Username</th>
                <th className="p-3">Email</th>
                <th className="p-3">Role</th>
                <th className="p-3">Active</th>
                <th className="p-3"></th>
              </tr>
            </thead>

            <tbody>
  {visibleUsers.map((u, index) => {
    const key = pickId(u) ?? pickEmail(u) ?? index;
    return (
      <tr key={String(key)} className="border-t">
        <td className="p-3">{pickId(u) ?? "-"}</td>
        <td className="p-3">{pickUsername(u)}</td>
        <td className="p-3">{pickEmail(u)}</td>
        <td className="p-3">
          {Array.isArray(pickRole(u)) ? pickRole(u).join(", ") : String(pickRole(u))}
        </td>
        <td className="p-3">{pickActive(u)}</td>
        <td className="p-3 text-right">
          <button
            type="button"
            onClick={() => onDelete(u)}
            className="px-3 py-1.5 rounded-lg bg-red-600 text-white"
          >
            Удалить
          </button>
        </td>
      </tr>
    );
  })}
</tbody>
          </table>
        </div>
      )}
    </div>
  );
}