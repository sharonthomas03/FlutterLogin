"use client";

import { useEffect, useState } from "react";
import { getUsers, blockUser, unblockUser } from "@/lib/api";
import {
  Users,
  RefreshCw,
  AlertCircle,
  ShieldCheck,
  UserX,
  UserCheck,
  Lock,
  Unlock,
} from "lucide-react";

export default function UsersPage() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  // Track which user IDs have an action in progress
  const [actionLoading, setActionLoading] = useState({});
  // Per-user action error
  const [actionError, setActionError] = useState({});

  // Get the logged-in admin's ID so we don't allow self-block
  const adminUser =
    typeof window !== "undefined"
      ? JSON.parse(localStorage.getItem("adminUser") || "null")
      : null;

  async function fetchUsers() {
    setLoading(true);
    setError("");
    try {
      const data = await getUsers();
      setUsers(Array.isArray(data) ? data : data.users || []);
    } catch (err) {
      setError(err.message || "Failed to load users.");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    fetchUsers();
  }, []);

  async function handleBlock(userId) {
    setActionLoading((prev) => ({ ...prev, [userId]: true }));
    setActionError((prev) => ({ ...prev, [userId]: "" }));
    try {
      await blockUser(userId);
      // Update locally — no full refetch needed
      setUsers((prev) =>
        prev.map((u) => (u._id === userId ? { ...u, isBlocked: true } : u))
      );
    } catch (err) {
      setActionError((prev) => ({
        ...prev,
        [userId]: err.message || "Failed to block user.",
      }));
    } finally {
      setActionLoading((prev) => ({ ...prev, [userId]: false }));
    }
  }

  async function handleUnblock(userId) {
    setActionLoading((prev) => ({ ...prev, [userId]: true }));
    setActionError((prev) => ({ ...prev, [userId]: "" }));
    try {
      await unblockUser(userId);
      setUsers((prev) =>
        prev.map((u) => (u._id === userId ? { ...u, isBlocked: false } : u))
      );
    } catch (err) {
      setActionError((prev) => ({
        ...prev,
        [userId]: err.message || "Failed to unblock user.",
      }));
    } finally {
      setActionLoading((prev) => ({ ...prev, [userId]: false }));
    }
  }

  function getRoleBadge(role) {
    if (!role) return null;
    const isAdmin = role.toLowerCase() === "admin";
    return (
      <span
        className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium ${
          isAdmin
            ? "bg-violet-500/15 text-violet-400 border border-violet-500/30"
            : "bg-slate-700 text-slate-300 border border-slate-600"
        }`}
      >
        {isAdmin && <ShieldCheck size={11} />}
        {role}
      </span>
    );
  }

  return (
    <div className="p-8 min-h-screen">
      {/* Page Header */}
      <div className="flex items-start justify-between mb-8">
        <div>
          <h1 className="text-2xl font-bold text-white tracking-tight flex items-center gap-2">
            <Users size={24} className="text-sky-400" />
            Users
          </h1>
          <p className="text-slate-400 text-sm mt-1">
            Manage all registered users on the platform
          </p>
        </div>
        <button
          onClick={fetchUsers}
          disabled={loading}
          className="flex items-center gap-2 px-4 py-2 rounded-xl bg-slate-800 border border-slate-700 text-slate-300 hover:text-white hover:border-slate-500 text-sm font-medium transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <RefreshCw size={14} className={loading ? "animate-spin" : ""} />
          Refresh
        </button>
      </div>

      {/* Page-level Error */}
      {error && (
        <div className="flex items-start gap-3 bg-red-500/10 border border-red-500/30 text-red-400 text-sm rounded-xl px-5 py-4 mb-6">
          <AlertCircle size={16} className="mt-0.5 shrink-0" />
          <div>
            <p className="font-medium">Failed to load users</p>
            <p className="text-red-400/80 mt-0.5">{error}</p>
          </div>
        </div>
      )}

      {/* Loading Skeleton */}
      {loading ? (
        <div className="bg-slate-800 border border-slate-700 rounded-2xl overflow-hidden">
          <div className="px-6 py-4 border-b border-slate-700">
            <div className="h-4 w-24 bg-slate-700 rounded animate-pulse" />
          </div>
          {[...Array(5)].map((_, i) => (
            <div
              key={i}
              className="flex items-center gap-4 px-6 py-4 border-b border-slate-700/50 last:border-0"
            >
              <div className="w-9 h-9 rounded-full bg-slate-700 animate-pulse shrink-0" />
              <div className="flex-1 space-y-2">
                <div className="h-3 w-32 bg-slate-700 rounded animate-pulse" />
                <div className="h-3 w-48 bg-slate-700/60 rounded animate-pulse" />
              </div>
              <div className="h-5 w-16 bg-slate-700 rounded-full animate-pulse" />
              <div className="h-5 w-16 bg-slate-700 rounded-full animate-pulse" />
              <div className="h-8 w-24 bg-slate-700 rounded-xl animate-pulse" />
            </div>
          ))}
        </div>
      ) : users.length === 0 && !error ? (
        /* Empty State */
        <div className="flex flex-col items-center justify-center py-24 bg-slate-800 border border-slate-700 rounded-2xl">
          <div className="w-16 h-16 rounded-2xl bg-slate-700 flex items-center justify-center mb-4">
            <Users size={28} className="text-slate-500" />
          </div>
          <p className="text-slate-300 font-semibold text-lg">No users found</p>
          <p className="text-slate-500 text-sm mt-1">
            There are no registered users yet.
          </p>
        </div>
      ) : (
        /* Users Table */
        <div className="bg-slate-800 border border-slate-700 rounded-2xl overflow-hidden">
          <div className="px-6 py-4 border-b border-slate-700">
            <p className="text-sm font-medium text-slate-300">
              {users.length} user{users.length !== 1 ? "s" : ""}
            </p>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-slate-700/60">
                  <th className="text-left px-6 py-3 text-xs font-semibold text-slate-400 uppercase tracking-wider">
                    User
                  </th>
                  <th className="text-left px-6 py-3 text-xs font-semibold text-slate-400 uppercase tracking-wider">
                    Email
                  </th>
                  <th className="text-left px-6 py-3 text-xs font-semibold text-slate-400 uppercase tracking-wider">
                    Role
                  </th>
                  <th className="text-left px-6 py-3 text-xs font-semibold text-slate-400 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="text-left px-6 py-3 text-xs font-semibold text-slate-400 uppercase tracking-wider">
                    Action
                  </th>
                </tr>
              </thead>
              <tbody>
                {users.map((user, idx) => {
                  const isSelf = adminUser && adminUser._id === user._id;
                  const isAdmin = user.role === "admin";
                  const busy = actionLoading[user._id];
                  const rowError = actionError[user._id];

                  return (
                    <tr
                      key={user._id || idx}
                      className="border-b border-slate-700/40 last:border-0 hover:bg-slate-700/30 transition-colors"
                    >
                      {/* Avatar + Name */}
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-3">
                          <div className="w-9 h-9 rounded-full bg-gradient-to-br from-sky-500 to-indigo-600 flex items-center justify-center shrink-0">
                            <span className="text-white text-sm font-bold">
                              {(user.username || "?")[0].toUpperCase()}
                            </span>
                          </div>
                          <span className="text-white text-sm font-medium">
                            {user.username || "—"}
                          </span>
                        </div>
                      </td>

                      {/* Email */}
                      <td className="px-6 py-4">
                        <span className="text-slate-400 text-sm">
                          {user.email || "—"}
                        </span>
                      </td>

                      {/* Role badge */}
                      <td className="px-6 py-4">
                        {getRoleBadge(user.role) || (
                          <span className="text-slate-500 text-sm">—</span>
                        )}
                      </td>

                      {/* Blocked badge */}
                      <td className="px-6 py-4">
                        {user.isBlocked ? (
                          <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-500/15 text-red-400 border border-red-500/30">
                            <UserX size={11} />
                            Blocked
                          </span>
                        ) : (
                          <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium bg-emerald-500/15 text-emerald-400 border border-emerald-500/30">
                            <UserCheck size={11} />
                            Active
                          </span>
                        )}
                      </td>

                      {/* Action button */}
                      <td className="px-6 py-4">
                        <div className="flex flex-col gap-1">
                          {isSelf ? (
                            <span className="text-xs text-slate-500 italic">
                              (you)
                            </span>
                          ) : isAdmin ? (
                            <span className="text-xs text-slate-500 italic">
                              Admin — protected
                            </span>
                          ) : user.isBlocked ? (
                            <button
                              onClick={() => handleUnblock(user._id)}
                              disabled={busy}
                              className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-medium bg-emerald-500/10 text-emerald-400 border border-emerald-500/30 hover:bg-emerald-500/20 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
                            >
                              {busy ? (
                                <RefreshCw size={11} className="animate-spin" />
                              ) : (
                                <Unlock size={11} />
                              )}
                              Unblock
                            </button>
                          ) : (
                            <button
                              onClick={() => handleBlock(user._id)}
                              disabled={busy}
                              className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-medium bg-red-500/10 text-red-400 border border-red-500/30 hover:bg-red-500/20 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
                            >
                              {busy ? (
                                <RefreshCw size={11} className="animate-spin" />
                              ) : (
                                <Lock size={11} />
                              )}
                              Block
                            </button>
                          )}
                          {rowError && (
                            <p className="text-red-400 text-xs mt-0.5">
                              {rowError}
                            </p>
                          )}
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
}
