import { http } from "./http";

// AUTH
export async function loginAdmin({ email, password }) {
  const { data } = await http.post("/api/auth/login", { email, password });
  // ожидаем: { token, role } или похожее
  return data;
}

// MOVIES
export async function getMovies() {
  const { data } = await http.get("/api/admin/movies");
  return data;
}

export async function deleteMovie(id) {
  const { data } = await http.delete(`/api/admin/movies/${id}`);
  return data;
}

export async function createMovie(payload) {
  const { data } = await http.post("/api/admin/movies", payload);
  return data;
}

export async function updateMovie(id, payload) {
  const { data } = await http.put(`/api/admin/movies/${id}`, payload);
  return data;
}

// USERS (если есть)
export async function getUsers() {
  const { data } = await http.get("/api/admin/users");
  return data;
}
