import React, { useMemo, useState } from "react";
import { http } from "../api/http";

export default function AddAdminPage() {
  const [username, setUsername] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const [loading, setLoading] = useState(false);
  const [msg, setMsg] = useState("");

  const usernameValid = useMemo(() => /^[a-zA-Z0-9_]{4,20}$/.test(username), [username]);
  const emailValid = useMemo(() => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email), [email]);
  const passwordValid = useMemo(
    () => password.length >= 8 && /[A-Za-z]/.test(password) && /\d/.test(password),
    [password]
  );

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
        password,
      });

      setMsg("✅ Admin created");
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

  const inputCls =
    "w-72 max-w-full bg-[#1a1a1a] text-white/90 placeholder:text-white/30 " +
    "border border-black/50 rounded-md px-3 py-2 outline-none " +
    "focus:border-white/20 focus:ring-2 focus:ring-white/5";

  const labelCls = "text-sm text-white/80 mb-2";

  return (
    <div className="text-white/90">
      <form onSubmit={onSubmit} className="space-y-10">
        <div>
          <div className={labelCls}>Username</div>
          <input
            className={inputCls}
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            placeholder=""
          />
          {!usernameValid && username.length > 0 && (
            <div className="text-xs text-red-400 mt-2">
              4–20 символов, латиница/цифры/_
            </div>
          )}
        </div>

        <div>
          <div className={labelCls}>Email</div>
          <input
            className={inputCls}
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder=""
          />
          {!emailValid && email.length > 0 && (
            <div className="text-xs text-red-400 mt-2">Неверный email</div>
          )}
        </div>

        <div>
          <div className={labelCls}>Password</div>
          <input
            className={inputCls}
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder=""
          />
          {!passwordValid && password.length > 0 && (
            <div className="text-xs text-red-400 mt-2">
              8+ символов, 1 буква и 1 цифра
            </div>
          )}
        </div>

        <button
          type="submit"
          disabled={!formValid || loading}
          className="w-72 max-w-full bg-[#555A72] text-white font-medium
                     rounded-md px-4 py-2
                     disabled:opacity-40 disabled:cursor-not-allowed
                     hover:opacity-95 transition"
        >
          {loading ? "Creating..." : "Create admin"}
        </button>

        {msg && <div className="text-sm text-white/80">{msg}</div>}
      </form>
    </div>
  );
}
