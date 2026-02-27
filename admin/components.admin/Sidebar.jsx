import React from "react";
import { NavLink, useNavigate } from "react-router-dom";
import { User, Plus, LayoutGrid, LogOut } from "lucide-react";

const Item = ({ to, icon, label }) => (
  <NavLink
    to={to}
    className={({ isActive }) =>
      `flex items-center gap-3 px-6 py-3 text-sm transition-colors
       ${isActive
         ? "bg-[#555A72] text-white"
         : "text-white/80 hover:bg-white/5"}`
    }
  >
    {icon}
    <span>{label}</span>
  </NavLink>
);

export default function Sidebar() {

  const navigate = useNavigate();

  const logout = () => {
    localStorage.clear();
    navigate("/login");
  };

  return (
    <aside className="
      fixed
      top-16
      left-0
      bottom-0
      w-64
      bg-[#1A1A1A]
      border-r border-black/40
      flex flex-col
      z-40
    ">

      <nav className="pt-6 flex-1">

        <Item
          to="/admin/add-admin"
          icon={<Plus size={18} />}
          label="Add admin"
        />

        <Item
          to="/admin/user-control"
          icon={<User size={18} />}
          label="Users"
        />

        <Item
          to="/admin/movies"
          icon={<LayoutGrid size={18} />}
          label="Movies"
        />

      </nav>


      <button
        onClick={logout}
        className="
          flex items-center gap-3
          px-6 py-4
          text-red-400
          hover:bg-red-500/10
          border-t border-white/10
        "
      >
        <LogOut size={18} />
        Logout
      </button>

    </aside>
  );
}