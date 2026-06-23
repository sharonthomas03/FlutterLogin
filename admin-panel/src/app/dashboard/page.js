"use client";

import { useEffect, useState } from "react";
import { getDashboardStats } from "@/lib/api";
import StatCard from "@/components/StatCard";
import { Users, ShieldCheck, Ban, FileText, RefreshCw } from "lucide-react";

export default function DashboardPage() {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [lastUpdated, setLastUpdated] = useState(null);

  async function fetchStats() {
    setLoading(true);
    setError("");
    try {
      const data = await getDashboardStats();
      setStats(data);
      setLastUpdated(new Date());
    } catch (err) {
      setError(err.message || "Failed to load dashboard data.");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    fetchStats();
  }, []);

  // Get admin user info from localStorage
  const adminUser =
    typeof window !== "undefined"
      ? JSON.parse(localStorage.getItem("adminUser") || "null")
      : null;

  const statCards = [
    {
      title: "Total Users",
      key: "totalUsers",
      icon: <Users size={22} />,
      gradient: "bg-gradient-to-br from-sky-500 to-blue-600",
      subtitle: "Registered users",
    },
    {
      title: "Total Admins",
      key: "totalAdmins",
      icon: <ShieldCheck size={22} />,
      gradient: "bg-gradient-to-br from-violet-500 to-indigo-600",
      subtitle: "Admin accounts",
    },
    {
      title: "Blocked Users",
      key: "blockedUsers",
      icon: <Ban size={22} />,
      gradient: "bg-gradient-to-br from-rose-500 to-pink-600",
      subtitle: "Restricted accounts",
    },
    {
      title: "Total Posts",
      key: "totalPosts",
      icon: <FileText size={22} />,
      gradient: "bg-gradient-to-br from-emerald-500 to-teal-600",
      subtitle: "Published content",
    },
  ];

  return (
    <div className="p-8 min-h-screen">
      {/* Page Header */}
      <div className="flex items-start justify-between mb-8">
        <div>
          <h1 className="text-2xl font-bold text-white tracking-tight">
            Dashboard
          </h1>
          <p className="text-slate-400 text-sm mt-1">
            {adminUser ? (
              <>
                Welcome back,{" "}
                <span className="text-violet-400 font-medium">
                  {adminUser.username}
                </span>
              </>
            ) : (
              "Overview of your platform"
            )}
          </p>
        </div>

        <div className="flex items-center gap-3">
          {lastUpdated && (
            <span className="text-slate-500 text-xs hidden sm:block">
              Updated {lastUpdated.toLocaleTimeString()}
            </span>
          )}
          <button
            onClick={fetchStats}
            disabled={loading}
            className="flex items-center gap-2 px-4 py-2 rounded-xl bg-slate-800 border border-slate-700 text-slate-300 hover:text-white hover:border-slate-500 text-sm font-medium transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <RefreshCw
              size={14}
              className={loading ? "animate-spin" : ""}
            />
            Refresh
          </button>
        </div>
      </div>

      {/* Error state */}
      {error && (
        <div className="bg-red-500/10 border border-red-500/30 text-red-400 text-sm rounded-xl px-5 py-4 mb-6">
          {error}
        </div>
      )}

      {/* Stat Cards Grid */}
      {loading && !stats ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-5">
          {[...Array(4)].map((_, i) => (
            <div
              key={i}
              className="h-36 rounded-2xl bg-slate-800 border border-slate-700 animate-pulse"
            />
          ))}
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-5">
          {statCards.map(({ title, key, icon, gradient, subtitle }) => (
            <StatCard
              key={key}
              title={title}
              value={stats?.[key]}
              icon={icon}
              gradient={gradient}
              subtitle={subtitle}
            />
          ))}
        </div>
      )}

      {/* Activity Section */}
      {stats && (
        <div className="mt-10">
          <h2 className="text-lg font-semibold text-white mb-4">
            Platform Overview
          </h2>
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
            {/* User breakdown */}
            <div className="bg-slate-800 border border-slate-700 rounded-2xl p-6">
              <h3 className="text-sm font-semibold text-slate-300 uppercase tracking-wider mb-4">
                User Breakdown
              </h3>
              <div className="space-y-3">
                {[
                  {
                    label: "Regular Users",
                    value: stats.totalUsers,
                    color: "bg-sky-500",
                    total: stats.totalUsers + stats.totalAdmins,
                  },
                  {
                    label: "Admins",
                    value: stats.totalAdmins,
                    color: "bg-violet-500",
                    total: stats.totalUsers + stats.totalAdmins,
                  },
                  {
                    label: "Blocked",
                    value: stats.blockedUsers,
                    color: "bg-rose-500",
                    total: stats.totalUsers + stats.totalAdmins,
                  },
                ].map(({ label, value, color, total }) => {
                  const pct = total > 0 ? Math.round((value / total) * 100) : 0;
                  return (
                    <div key={label}>
                      <div className="flex justify-between text-sm mb-1.5">
                        <span className="text-slate-400">{label}</span>
                        <span className="text-white font-medium tabular-nums">
                          {value}
                        </span>
                      </div>
                      <div className="w-full h-2 bg-slate-700 rounded-full overflow-hidden">
                        <div
                          className={`h-full rounded-full ${color} transition-all duration-700`}
                          style={{ width: `${pct}%` }}
                        />
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>

            {/* Quick stats summary */}
            <div className="bg-slate-800 border border-slate-700 rounded-2xl p-6">
              <h3 className="text-sm font-semibold text-slate-300 uppercase tracking-wider mb-4">
                Quick Summary
              </h3>
              <div className="space-y-4">
                {[
                  {
                    label: "Total accounts",
                    value: stats.totalUsers + stats.totalAdmins,
                    badge: "all",
                  },
                  {
                    label: "Active accounts",
                    value:
                      stats.totalUsers +
                      stats.totalAdmins -
                      stats.blockedUsers,
                    badge: "active",
                  },
                  {
                    label: "Block rate",
                    value:
                      stats.totalUsers + stats.totalAdmins > 0
                        ? `${Math.round(
                            (stats.blockedUsers /
                              (stats.totalUsers + stats.totalAdmins)) *
                              100
                          )}%`
                        : "0%",
                    badge: "rate",
                  },
                  { label: "Total posts", value: stats.totalPosts, badge: "posts" },
                ].map(({ label, value }) => (
                  <div
                    key={label}
                    className="flex items-center justify-between py-2 border-b border-slate-700/60 last:border-0"
                  >
                    <span className="text-slate-400 text-sm">{label}</span>
                    <span className="text-white font-semibold text-sm tabular-nums">
                      {value}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
