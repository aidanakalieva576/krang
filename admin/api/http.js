import axios from "axios";

export const http = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL ?? "http://localhost:8080",
  timeout: 15000,
});

http.interceptors.request.use((config) => {
  const token = localStorage.getItem("token");
  console.log("[HTTP]", config.method?.toUpperCase(), config.url, {
    auth: token ? `Bearer ${token.slice(0, 20)}...` : null,
  });
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

