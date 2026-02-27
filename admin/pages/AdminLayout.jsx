import React from "react";
import { Outlet } from "react-router-dom";
import AdminNavbar from "../components.admin/AdminNavbar";
import Sidebar from "../components.admin/Sidebar";

export default function AdminLayout() {
  return (
    <div className="bg-[#1f1f1f] min-h-screen">

      {/* фиксированный navbar */}
      <AdminNavbar />

      {/* sidebar + content */}
      <div className="flex">

        <Sidebar />

        {/* контент с отступами */}
        <main className="flex-1 ml-64 pt-16">
          <div className="p-10">
            <Outlet />
          </div>
        </main>

      </div>

    </div>
  );
}