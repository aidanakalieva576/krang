import React from "react";
// import logo from "admin/public/logo.png";

export default function AdminNavbar() {
  return (
    <header className="h-16 bg-[#1f1f1f] border-b border-black/40 flex items-center px-6">
      <div className="flex items-center gap-4 select-none">
        <div className="w-14 h-10 rounded-full overflow-hidden bg-black/30 border border-white/10 flex items-center justify-center">
{/*           <img src={logo} alt="KRANG" className="w-full h-full object-cover" /> */}
        </div>
        <h1 className="text-2xl font-semibold text-white/90">Admin</h1>
      </div>
    </header>
  );
}
