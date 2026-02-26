import React from "react";
import ReactDOM from "react-dom/client";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import "./index.css";

import RequireAdmin from "./RequireAdmin";

// pages лежат рядом с src, поэтому ../pages
import LoginPage from "../pages/LoginPage";
import AdminLayout from "../pages/AdminLayout";
import MoviesPage from "../pages/MoviesPage";
import AddAdminPage from "../pages/AddAdminPage";
import UserControlPage from "../pages/UserControlPage";

ReactDOM.createRoot(document.getElementById("root")).render(
  <BrowserRouter>
    <Routes>
      {/* public */}
      <Route path="/login" element={<LoginPage />} />

      {/* protected */}
      <Route
        path="/admin"
        element={
          <RequireAdmin>
            <AdminLayout />
          </RequireAdmin>
        }
      >
        <Route index element={<Navigate to="movies" replace />} />
        <Route path="movies" element={<MoviesPage />} />
        <Route path="add-admin" element={<AddAdminPage />} />
        <Route path="user-control" element={<UserControlPage />} />
      </Route>

      {/* default */}
      <Route path="*" element={<Navigate to="/login" replace />} />
    </Routes>
  </BrowserRouter>
);
