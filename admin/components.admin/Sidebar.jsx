import React from "react";
import { NavLink } from "react-router-dom";
import { User, Plus, LayoutGrid } from "lucide-react";

const Item = ({ to, icon, label }) => (
  <NavLink
    to={to}
    className={({ isActive }) =>
      `flex items-center gap-3 px-6 py-3 text-sm text-white/80
       transition-colors select-none
       ${isActive ? "bg-[#555A72] text-white" : "hover:bg-white/5"}`
    }
  >
    <span className="w-6 flex items-center justify-center">
      {icon}
    </span>
    <span className="whitespace-nowrap font-medium">{label}</span>
  </NavLink>
);

export default function Sidebar() {
  return (
    <aside className="w-64 min-h-[calc(100vh-64px)] bg-[#1A1A1A] border-r border-black/40">
      <nav className="pt-6 space-y-1">

        <Item
          to="/admin/add-admin"
          icon={<Plus size={18} className="text-white" />}
          label="Add admin"
        />

        <Item
          to="/admin/user-control"
          icon={<User size={18} className="text-white" />}
          label="Users"
        />

        <Item
          to="/admin/movies"
          icon={<LayoutGrid size={18} className="text-white" />}
          label="Movies"
        />

      </nav>
    </aside>
  );
}