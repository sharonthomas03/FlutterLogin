"use client";

import { useEffect, useState } from "react";
import { getReports, reviewReport, dismissReport } from "@/lib/api";
import {
  Flag,
  RefreshCw,
  AlertCircle,
  User,
  FileText,
  CheckCircle,
  XCircle,
} from "lucide-react";

export default function ReportsPage() {
  const [reports, setReports] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  // Track which report has an action running: { [reportId]: 'review' | 'dismiss' | null }
  const [actionLoading, setActionLoading] = useState({});
  const [actionError, setActionError] = useState({});

  async function fetchReports() {
    setLoading(true);
    setError("");
    try {
      const data = await getReports();
      setReports(Array.isArray(data) ? data : data.reports || []);
    } catch (err) {
      setError(err.message || "Failed to load reports.");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    fetchReports();
  }, []);

  async function handleReview(reportId) {
    setActionLoading((prev) => ({ ...prev, [reportId]: "review" }));
    setActionError((prev) => ({ ...prev, [reportId]: "" }));
    try {
      await reviewReport(reportId);
      setReports((prev) =>
        prev.map((r) =>
          r._id === reportId ? { ...r, status: "reviewed" } : r
        )
      );
    } catch (err) {
      setActionError((prev) => ({
        ...prev,
        [reportId]: err.message || "Failed to mark as reviewed.",
      }));
    } finally {
      setActionLoading((prev) => ({ ...prev, [reportId]: null }));
    }
  }

  async function handleDismiss(reportId) {
    setActionLoading((prev) => ({ ...prev, [reportId]: "dismiss" }));
    setActionError((prev) => ({ ...prev, [reportId]: "" }));
    try {
      await dismissReport(reportId);
      setReports((prev) =>
        prev.map((r) =>
          r._id === reportId ? { ...r, status: "dismissed" } : r
        )
      );
    } catch (err) {
      setActionError((prev) => ({
        ...prev,
        [reportId]: err.message || "Failed to dismiss report.",
      }));
    } finally {
      setActionLoading((prev) => ({ ...prev, [reportId]: null }));
    }
  }

  function getStatusBadge(status) {
    const styles = {
      pending: "bg-amber-500/15 text-amber-400 border-amber-500/30",
      reviewed: "bg-emerald-500/15 text-emerald-400 border-emerald-500/30",
      dismissed: "bg-slate-700 text-slate-400 border-slate-600",
    };
    const style = styles[status] || styles.pending;
    return (
      <span
        className={`px-2.5 py-0.5 rounded-full text-xs font-medium border capitalize ${style}`}
      >
        {status || "pending"}
      </span>
    );
  }

  return (
    <div className="p-8 min-h-screen">
      {/* Page Header */}
      <div className="flex items-start justify-between mb-8">
        <div>
          <h1 className="text-2xl font-bold text-white tracking-tight flex items-center gap-2">
            <Flag size={24} className="text-rose-400" />
            Reports
          </h1>
          <p className="text-slate-400 text-sm mt-1">
            Review user-submitted reports and take action
          </p>
        </div>
        <button
          onClick={fetchReports}
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
            <p className="font-medium">Failed to load reports</p>
            <p className="text-red-400/80 mt-0.5">{error}</p>
          </div>
        </div>
      )}

      {/* Loading Skeleton */}
      {loading ? (
        <div className="space-y-3">
          {[...Array(5)].map((_, i) => (
            <div
              key={i}
              className="bg-slate-800 border border-slate-700 rounded-2xl p-5 animate-pulse"
            >
              <div className="flex items-start justify-between mb-3">
                <div className="h-4 w-1/3 bg-slate-700 rounded" />
                <div className="h-5 w-16 bg-slate-700 rounded-full" />
              </div>
              <div className="flex gap-4 mb-3">
                <div className="h-3 w-28 bg-slate-700/60 rounded" />
                <div className="h-3 w-28 bg-slate-700/60 rounded" />
              </div>
              <div className="flex gap-2">
                <div className="h-7 w-32 bg-slate-700 rounded-xl" />
                <div className="h-7 w-24 bg-slate-700 rounded-xl" />
              </div>
            </div>
          ))}
        </div>
      ) : reports.length === 0 && !error ? (
        /* Empty State */
        <div className="flex flex-col items-center justify-center py-24 bg-slate-800 border border-slate-700 rounded-2xl">
          <div className="w-16 h-16 rounded-2xl bg-slate-700 flex items-center justify-center mb-4">
            <Flag size={28} className="text-slate-500" />
          </div>
          <p className="text-slate-300 font-semibold text-lg">
            No reports found
          </p>
          <p className="text-slate-500 text-sm mt-1">
            No reports have been submitted yet.
          </p>
        </div>
      ) : (
        /* Reports List */
        <>
          <p className="text-sm text-slate-400 mb-4">
            {reports.length} report{reports.length !== 1 ? "s" : ""} found
          </p>
          <div className="space-y-3">
            {reports.map((report, idx) => {
              const busy = actionLoading[report._id];
              const rowError = actionError[report._id];
              const isResolved =
                report.status === "reviewed" || report.status === "dismissed";

              return (
                <div
                  key={report._id || idx}
                  className={`bg-slate-800 border rounded-2xl p-5 transition-all duration-200 ${
                    isResolved
                      ? "border-slate-700/50 opacity-80"
                      : "border-slate-700 hover:border-slate-500 hover:shadow-lg hover:shadow-slate-900/40"
                  }`}
                >
                  {/* Top: reason + status badge */}
                  <div className="flex items-start justify-between gap-3 mb-3">
                    <h3 className="text-white font-semibold text-sm flex-1">
                      {report.reason || "No reason provided"}
                    </h3>
                    {getStatusBadge(report.status)}
                  </div>

                  {/* Meta: reported post + reported by */}
                  <div className="flex flex-wrap items-center gap-4 mb-4">
                    {/* Post info */}
                    {report.post && (
                      <div className="flex items-center gap-1.5 text-xs text-slate-500">
                        <FileText size={11} />
                        <span className="text-slate-400">Post:</span>
                        <span className="text-slate-300 line-clamp-1 max-w-[200px]">
                          {report.post.title || report.post._id}
                        </span>
                      </div>
                    )}

                    {/* Reporter */}
                    {report.reportedBy && (
                      <div className="flex items-center gap-1.5 text-xs text-slate-500">
                        <User size={11} />
                        <span className="text-slate-400">Reported by:</span>
                        <span className="text-slate-300">
                          {report.reportedBy.username ||
                            report.reportedBy.email ||
                            "Unknown"}
                        </span>
                      </div>
                    )}
                  </div>

                  {/* Per-report action error */}
                  {rowError && (
                    <p className="text-red-400 text-xs mb-3">{rowError}</p>
                  )}

                  {/* Action Buttons */}
                  <div className="flex items-center gap-2 pt-3 border-t border-slate-700/60">
                    {/* Mark as Reviewed — disabled if already reviewed or dismissed */}
                    <button
                      onClick={() => handleReview(report._id)}
                      disabled={!!busy || report.status === "reviewed" || report.status === "dismissed"}
                      className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-medium bg-emerald-500/10 text-emerald-400 border border-emerald-500/30 hover:bg-emerald-500/20 transition-all duration-200 disabled:opacity-40 disabled:cursor-not-allowed"
                    >
                      {busy === "review" ? (
                        <RefreshCw size={11} className="animate-spin" />
                      ) : (
                        <CheckCircle size={11} />
                      )}
                      Mark as Reviewed
                    </button>

                    {/* Dismiss — disabled if already dismissed */}
                    <button
                      onClick={() => handleDismiss(report._id)}
                      disabled={!!busy || report.status === "dismissed"}
                      className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-medium bg-slate-700 text-slate-300 border border-slate-600 hover:bg-slate-600 hover:text-white transition-all duration-200 disabled:opacity-40 disabled:cursor-not-allowed"
                    >
                      {busy === "dismiss" ? (
                        <RefreshCw size={11} className="animate-spin" />
                      ) : (
                        <XCircle size={11} />
                      )}
                      Dismiss
                    </button>
                  </div>
                </div>
              );
            })}
          </div>
        </>
      )}
    </div>
  );
}
