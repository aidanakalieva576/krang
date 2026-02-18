import React from "react";
import { Outlet } from "react-router-dom";
import AdminNavbar from "../components.admin/AdminNavbar";
import Sidebar from "../components.admin/Sidebar";

export default function AdminLayout() {
  return (
    <div className="min-h-screen bg-[#1f1f1f]">
      <AdminNavbar />

      <div className="flex">
        <Sidebar />

        <main className="flex-1 min-h-[calc(100vh-64px)] bg-[#1f1f1f]">
          <div className="p-10">
            <Outlet />
          </div>
        </main>
      </div>
    </div>
  );
}
