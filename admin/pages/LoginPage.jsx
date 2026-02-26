import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { login } from "../api/authApi";

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [msg, setMsg] = useState("");
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const onSubmit = async (e) => {
    e.preventDefault();
    setMsg("");
    setLoading(true);
    try {
      const data = await login({ email, password });

      localStorage.setItem("token", data.token);
      localStorage.setItem("role", data.role);       // важно
      localStorage.setItem("username", data.username);
      localStorage.setItem("email", data.email);

      // пускаем в админку только админа
      const role = String(data.role || "").toLowerCase();
      if (role !== "admin") {
        setMsg("❌ У вас нет прав администратора");
        localStorage.removeItem("token");
        localStorage.removeItem("role");
        return;
      }

      navigate("/admin/movies");
    } catch (err) {
      const text =
        err?.response?.data?.error ||
        err?.response?.data?.message ||
        err?.message ||
        "Ошибка";
      setMsg("❌ " + text);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
      <div className="w-full max-w-md bg-white border rounded-2xl p-6 shadow-sm">
        <h1 className="text-xl font-semibold mb-1">Вход в админку</h1>
        <p className="text-sm text-gray-500 mb-5">Используй email и пароль администратора</p>

        <form onSubmit={onSubmit} className="space-y-3">
          <div>
            <label className="text-sm text-gray-600">Email</label>
            <input
              className="w-full border rounded-xl px-4 py-2 mt-1"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              type="email"
              required
            />
          </div>

          <div>
            <label className="text-sm text-gray-600">Пароль</label>
            <input
              className="w-full border rounded-xl px-4 py-2 mt-1"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              type="password"
              required
            />
          </div>

          <button
            disabled={loading}
            className="w-full bg-black text-white rounded-xl py-2.5 disabled:opacity-60"
            type="submit"
          >
            {loading ? "Вход..." : "Войти"}
          </button>

          {msg && <div className="text-sm">{msg}</div>}
        </form>
      </div>
    </div>
  );
}
