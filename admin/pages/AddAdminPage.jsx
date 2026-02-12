import React, { useState } from "react";
import { http } from "../api/http";

export default function AddAdminPage() {
  const [username, setUsername] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const [loading, setLoading] = useState(false);
  const [msg, setMsg] = useState("");

  // ===== ВАЛИДАЦИИ =====

  const usernameValid = /^[a-zA-Z0-9_]{4,20}$/.test(username);
  const emailValid = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  const passwordValid =
    password.length >= 8 &&
    /[A-Za-z]/.test(password) &&
    /\d/.test(password);

  const formValid = usernameValid && emailValid && passwordValid;

  const onSubmit = async (e) => {
    e.preventDefault();
    if (!formValid) return;

    setMsg("");
    setLoading(true);

    try {
      await http.post("/api/admin/register", {
        username: username.trim(),
        email: email.trim().toLowerCase(),
        password
      });

      setMsg("✅ Админ успешно создан");
      setUsername("");
      setEmail("");
      setPassword("");

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
    <div className="bg-white border rounded-2xl p-6 shadow-sm max-w-xl">
      <h1 className="text-xl font-semibold mb-5">
        Создать администратора
      </h1>

      <form onSubmit={onSubmit} className="space-y-4">

        {/* USERNAME */}
        <div>
          <label className="text-sm text-gray-600">Username</label>
          <input
            className="w-full border rounded-xl px-4 py-2 mt-1"
            placeholder="admin_01"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
          />
          {!usernameValid && username.length > 0 && (
            <p className="text-xs text-red-500 mt-1">
              4–20 символов, только латиница, цифры и _
            </p>
          )}
        </div>

        {/* EMAIL */}
        <div>
          <label className="text-sm text-gray-600">Email</label>
          <input
            className="w-full border rounded-xl px-4 py-2 mt-1"
            placeholder="admin@mail.com"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            type="email"
          />
          {!emailValid && email.length > 0 && (
            <p className="text-xs text-red-500 mt-1">
              Неверный формат email
            </p>
          )}
        </div>

        {/* PASSWORD */}
        <div>
          <label className="text-sm text-gray-600">Пароль</label>
          <input
            className="w-full border rounded-xl px-4 py-2 mt-1"
            placeholder="Минимум 8 символов"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            type="password"
          />
          {!passwordValid && password.length > 0 && (
            <p className="text-xs text-red-500 mt-1">
              Минимум 8 символов, 1 буква и 1 цифра
            </p>
          )}
        </div>

        <button
          disabled={!formValid || loading}
          className="w-full bg-black text-white rounded-xl py-2.5 disabled:opacity-50"
          type="submit"
        >
          {loading ? "Создание..." : "Создать админа"}
        </button>

        {msg && <div className="text-sm mt-2">{msg}</div>}
      </form>
    </div>
  );
}
