import React from "react";
import { NavLink } from "react-router-dom";

const Sidebar = () => {
  const linkClass = ({ isActive }) =>
    `flex items-center gap-3 py-3 px-4 rounded-lg mx-3 ${
      isActive ? "bg-primary text-white" : "text-gray-700 hover:bg-gray-100"
    }`;

  return (
    <aside className="w-64 min-h-screen bg-white border-r">
      <div className="px-5 py-4 border-b">
        <p className="text-lg font-semibold">KRANG Admin</p>
        <p className="text-xs text-gray-500">панель управления</p>
      </div>

      <nav className="py-4">
        <NavLink to="/admin/add-admin" className={linkClass}>
          Добавить админа
        </NavLink>

        <NavLink to="/admin/movies" className={linkClass}>
          Фильмы
        </NavLink>
      </nav>
    </aside>
  );
};

export default Sidebar;
