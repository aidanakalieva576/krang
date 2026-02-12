import React from "react";
import { Outlet } from "react-router-dom";
import Sidebar from "../components.admin/Sidebar";

export default function AdminLayout() {
  return (
    <div className="min-h-screen bg-gray-50 flex">
      <Sidebar />

      <main className="flex-1 p-6">
        <div className="max-w-6xl mx-auto">
          <Outlet />
        </div>
      </main>
    </div>
  );
}
