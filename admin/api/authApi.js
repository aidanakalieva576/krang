import { http } from "./http";

export async function login({ email, password }) {
  const { data } = await http.post("/api/auth/login", { email, password });
  // data: { token, username, email, role }
  return data;
}
