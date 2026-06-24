"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import {
  LayoutDashboard,
  Users,
  FileText,
  Flag,
  LogOut,
  ShieldCheck,
} from "lucide-react";
import { LucideIcon } from "lucide-react";
import { logout } from "@/lib/api";

type NavItem = {
  href: string;
  label: string;
  icon: LucideIcon;
};

const navItems: NavItem[] = [
  {
    href: "/dashboard",
    label: "Dashboard",
    icon: LayoutDashboard,
  },
  {
    href: "/dashboard/users",
    label: "Users",
    icon: Users,
  },
  {
    href: "/dashboard/posts",
    label: "Posts",
    icon: FileText,
  },
  {
    href: "/dashboard/reports",
    label: "Reports",
    icon: Flag,
  },
];

export default function Sidebar() {
  const pathname = usePathname();
  const router = useRouter();

  async function handleLogout() {
    await logout(); // Invalidates refresh token in DB + clears localStorage
    router.push("/login");
  }

  return (
    <aside className="flex flex-col w-64 min-h-screen bg-gradient-to-b from-slate-900 to-slate-800 border-r border-slate-700 shadow-xl">
      {/* Logo */}
      <div className="flex items-center gap-3 px-6 py-6 border-b border-slate-700">
        <div className="flex items-center justify-center w-9 h-9 rounded-xl bg-gradient-to-br from-violet-500 to-indigo-600 shadow-lg">
          <ShieldCheck size={20} className="text-white" />
        </div>
        <div>
          <p className="text-white font-bold text-sm leading-none">AdminPanel</p>
          <p className="text-slate-400 text-xs mt-0.5">Management Console</p>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 px-3 py-6 space-y-1">
        {navItems.map(({ href, label, icon: Icon }) => {
          const isActive =
            href === "/dashboard"
              ? pathname === "/dashboard"
              : pathname.startsWith(href);
          return (
            <Link
              key={href}
              href={href}
              className={`flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-all duration-200 group ${
                isActive
                  ? "bg-gradient-to-r from-violet-600 to-indigo-600 text-white shadow-lg shadow-violet-500/20"
                  : "text-slate-400 hover:bg-slate-700/60 hover:text-white"
              }`}
            >
              <Icon
                size={18}
                className={`transition-transform duration-200 group-hover:scale-110 ${
                  isActive ? "text-white" : "text-slate-400"
                }`}
              />
              {label}
            </Link>
          );
        })}
      </nav>

      {/* Logout */}
      <div className="px-3 py-4 border-t border-slate-700">
        <button
          onClick={handleLogout}
          className="flex items-center gap-3 w-full px-4 py-3 rounded-xl text-sm font-medium text-slate-400 hover:bg-red-500/10 hover:text-red-400 transition-all duration-200 group"
        >
          <LogOut
            size={18}
            className="transition-transform duration-200 group-hover:scale-110"
          />
          Logout
        </button>
      </div>
    </aside>
  );
}
