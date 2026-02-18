import { Routes, Route } from "react-router-dom";
import AdminLayout from "./admin/pages/AdminLayout";
import AddAdminPage from "./admin/pages/AddAdminPage";
import MoviesPage from "./admin/pages/MoviesPage";

export default function App() {
  return (
    <Routes>
      <Route path="/admin" element={<AdminLayout />}>
        <Route path="add-admin" element={<AddAdminPage />} />
        <Route path="movies" element={<MoviesPage />} />
      </Route>
    </Routes>
  );
}
