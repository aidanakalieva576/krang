import React from "react";

export default function AdminNavbar() {
  return (
    <header className="
      fixed top-0 left-0 right-0
      h-16
      bg-[#1f1f1f]
      border-b border-black/40
      flex items-center px-6
      z-50
    ">
      <div className="flex items-center gap-4 select-none">

        <div className="w-14 h-10 rounded-full overflow-hidden bg-black/30 border border-white/10 flex items-center justify-center">
          {/* logo */}
        </div>

        <h1 className="text-2xl font-semibold text-white/90">
          Admin
        </h1>

      </div>
    </header>
  );
}