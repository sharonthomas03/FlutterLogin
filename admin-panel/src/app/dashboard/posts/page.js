"use client";

import { useEffect, useState } from "react";
import { getPosts, deletePost, hidePost, unhidePost } from "@/lib/api";
import {
  FileText,
  RefreshCw,
  AlertCircle,
  User,
  Eye,
  EyeOff,
  Trash2,
  EyeOffIcon,
} from "lucide-react";

export default function PostsPage() {
  const [posts, setPosts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  // Track per-post action loading: { [postId]: 'delete' | 'hide' | 'unhide' | null }
  const [actionLoading, setActionLoading] = useState({});
  const [actionError, setActionError] = useState({});

  async function fetchPosts() {
    setLoading(true);
    setError("");
    try {
      const data = await getPosts();
      setPosts(Array.isArray(data) ? data : data.posts || []);
    } catch (err) {
      setError(err.message || "Failed to load posts.");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    fetchPosts();
  }, []);

  async function handleDelete(postId) {
    if (!confirm("Are you sure you want to permanently delete this post?")) return;
    setActionLoading((prev) => ({ ...prev, [postId]: "delete" }));
    setActionError((prev) => ({ ...prev, [postId]: "" }));
    try {
      await deletePost(postId);
      // Remove from local state
      setPosts((prev) => prev.filter((p) => p._id !== postId));
    } catch (err) {
      setActionError((prev) => ({
        ...prev,
        [postId]: err.message || "Failed to delete post.",
      }));
    } finally {
      setActionLoading((prev) => ({ ...prev, [postId]: null }));
    }
  }

  async function handleHide(postId) {
    setActionLoading((prev) => ({ ...prev, [postId]: "hide" }));
    setActionError((prev) => ({ ...prev, [postId]: "" }));
    try {
      await hidePost(postId);
      setPosts((prev) =>
        prev.map((p) => (p._id === postId ? { ...p, isHidden: true } : p))
      );
    } catch (err) {
      setActionError((prev) => ({
        ...prev,
        [postId]: err.message || "Failed to hide post.",
      }));
    } finally {
      setActionLoading((prev) => ({ ...prev, [postId]: null }));
    }
  }

  async function handleUnhide(postId) {
    setActionLoading((prev) => ({ ...prev, [postId]: "unhide" }));
    setActionError((prev) => ({ ...prev, [postId]: "" }));
    try {
      await unhidePost(postId);
      setPosts((prev) =>
        prev.map((p) => (p._id === postId ? { ...p, isHidden: false } : p))
      );
    } catch (err) {
      setActionError((prev) => ({
        ...prev,
        [postId]: err.message || "Failed to unhide post.",
      }));
    } finally {
      setActionLoading((prev) => ({ ...prev, [postId]: null }));
    }
  }

  return (
    <div className="p-8 min-h-screen">
      {/* Page Header */}
      <div className="flex items-start justify-between mb-8">
        <div>
          <h1 className="text-2xl font-bold text-white tracking-tight flex items-center gap-2">
            <FileText size={24} className="text-emerald-400" />
            Posts
          </h1>
          <p className="text-slate-400 text-sm mt-1">
            View and manage all content published on the platform
          </p>
        </div>
        <button
          onClick={fetchPosts}
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
            <p className="font-medium">Failed to load posts</p>
            <p className="text-red-400/80 mt-0.5">{error}</p>
          </div>
        </div>
      )}

      {/* Loading Skeleton */}
      {loading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
          {[...Array(6)].map((_, i) => (
            <div
              key={i}
              className="bg-slate-800 border border-slate-700 rounded-2xl p-5 animate-pulse"
            >
              <div className="h-4 w-3/4 bg-slate-700 rounded mb-3" />
              <div className="space-y-2 mb-4">
                <div className="h-3 bg-slate-700/60 rounded" />
                <div className="h-3 w-5/6 bg-slate-700/60 rounded" />
              </div>
              <div className="flex items-center justify-between">
                <div className="h-3 w-20 bg-slate-700 rounded" />
                <div className="flex gap-2">
                  <div className="h-7 w-16 bg-slate-700 rounded-xl" />
                  <div className="h-7 w-16 bg-slate-700 rounded-xl" />
                </div>
              </div>
            </div>
          ))}
        </div>
      ) : posts.length === 0 && !error ? (
        /* Empty State */
        <div className="flex flex-col items-center justify-center py-24 bg-slate-800 border border-slate-700 rounded-2xl">
          <div className="w-16 h-16 rounded-2xl bg-slate-700 flex items-center justify-center mb-4">
            <FileText size={28} className="text-slate-500" />
          </div>
          <p className="text-slate-300 font-semibold text-lg">No posts found</p>
          <p className="text-slate-500 text-sm mt-1">
            There are no posts published yet.
          </p>
        </div>
      ) : (
        /* Posts Grid */
        <>
          <p className="text-sm text-slate-400 mb-4">
            {posts.length} post{posts.length !== 1 ? "s" : ""} found
          </p>
          <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
            {posts.map((post, idx) => {
              const busy = actionLoading[post._id];
              const rowError = actionError[post._id];
              // Author is populated as createdBy from the backend
              const authorName =
                post.createdBy?.username ||
                post.createdBy?.name ||
                post.authorName ||
                "Unknown";

              return (
                <div
                  key={post._id || idx}
                  className={`bg-slate-800 border rounded-2xl p-5 transition-all duration-200 hover:shadow-lg hover:shadow-slate-900/40 flex flex-col ${
                    post.isHidden
                      ? "border-amber-500/30 opacity-75"
                      : "border-slate-700 hover:border-slate-500"
                  }`}
                >
                  {/* Hidden badge */}
                  {post.isHidden && (
                    <div className="flex items-center gap-1 mb-2">
                      <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-medium bg-amber-500/15 text-amber-400 border border-amber-500/30">
                        <EyeOffIcon size={10} />
                        Hidden
                      </span>
                    </div>
                  )}

                  {/* Title */}
                  <h3 className="text-white font-semibold text-sm leading-snug mb-2 line-clamp-2">
                    {post.title || "Untitled Post"}
                  </h3>

                  {/* Content */}
                  {post.content && (
                    <p className="text-slate-400 text-xs leading-relaxed mb-3 line-clamp-3 flex-1">
                      {post.content}
                    </p>
                  )}

                  {/* Per-post action error */}
                  {rowError && (
                    <p className="text-red-400 text-xs mb-2">{rowError}</p>
                  )}

                  {/* Footer: author + action buttons */}
                  <div className="flex items-center justify-between mt-auto pt-3 border-t border-slate-700/60">
                    <div className="flex items-center gap-1.5 text-xs text-slate-500">
                      <User size={11} />
                      <span>{authorName}</span>
                    </div>

                    <div className="flex items-center gap-1.5">
                      {/* Hide / Unhide */}
                      {post.isHidden ? (
                        <button
                          onClick={() => handleUnhide(post._id)}
                          disabled={!!busy}
                          title="Make post visible"
                          className="flex items-center gap-1 px-2.5 py-1.5 rounded-xl text-xs font-medium bg-emerald-500/10 text-emerald-400 border border-emerald-500/30 hover:bg-emerald-500/20 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                          {busy === "unhide" ? (
                            <RefreshCw size={11} className="animate-spin" />
                          ) : (
                            <Eye size={11} />
                          )}
                          Unhide
                        </button>
                      ) : (
                        <button
                          onClick={() => handleHide(post._id)}
                          disabled={!!busy}
                          title="Hide post from public"
                          className="flex items-center gap-1 px-2.5 py-1.5 rounded-xl text-xs font-medium bg-amber-500/10 text-amber-400 border border-amber-500/30 hover:bg-amber-500/20 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                          {busy === "hide" ? (
                            <RefreshCw size={11} className="animate-spin" />
                          ) : (
                            <EyeOff size={11} />
                          )}
                          Hide
                        </button>
                      )}

                      {/* Delete */}
                      <button
                        onClick={() => handleDelete(post._id)}
                        disabled={!!busy}
                        title="Permanently delete post"
                        className="flex items-center gap-1 px-2.5 py-1.5 rounded-xl text-xs font-medium bg-red-500/10 text-red-400 border border-red-500/30 hover:bg-red-500/20 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        {busy === "delete" ? (
                          <RefreshCw size={11} className="animate-spin" />
                        ) : (
                          <Trash2 size={11} />
                        )}
                        Delete
                      </button>
                    </div>
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
