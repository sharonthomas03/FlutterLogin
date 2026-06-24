import type { LoginResponse, DashboardStats, AdminUser, Post, Report } from "@/types";

const BASE_URL = "http://localhost:5000";

type FetchOptions = RequestInit & {
  headers?: Record<string, string>;
};

/**
 * Make a public API call (no auth header).
 */
export async function apiCall<T = unknown>(endpoint: string, options: FetchOptions = {}): Promise<T> {
  const url = `${BASE_URL}${endpoint}`;
  const response = await fetch(url, {
    headers: {
      "Content-Type": "application/json",
      ...(options.headers || {}),
    },
    ...options,
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.message || "Something went wrong");
  }

  return data as T;
}

/**
 * Make an authenticated API call using the adminToken from localStorage.
 */
export async function authApiCall<T = unknown>(endpoint: string, options: FetchOptions = {}): Promise<T> {
  const token =
    typeof window !== "undefined" ? localStorage.getItem("adminToken") : null;

  const url = `${BASE_URL}${endpoint}`;
  const response = await fetch(url, {
    headers: {
      "Content-Type": "application/json",
      Authorization: token ? `Bearer ${token}` : "",
      ...(options.headers || {}),
    },
    ...options,
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.message || "Something went wrong");
  }

  return data as T;
}

/**
 * Login — POST /api/auth/login
 */
export async function login(email: string, password: string): Promise<LoginResponse> {
  return apiCall<LoginResponse>("/api/auth/login", {
    method: "POST",
    body: JSON.stringify({ email, password }),
  });
}

/**
 * Get dashboard stats — GET /api/admin/dashboard
 */
export async function getDashboardStats(): Promise<DashboardStats> {
  return authApiCall<DashboardStats>("/api/admin/dashboard");
}

/**
 * Get all users — GET /api/admin/users
 */
export async function getUsers(): Promise<AdminUser[] | { users: AdminUser[] }> {
  return authApiCall<AdminUser[] | { users: AdminUser[] }>("/api/admin/users");
}

/**
 * Get all posts — GET /api/admin/posts
 */
export async function getPosts(): Promise<Post[] | { posts: Post[] }> {
  return authApiCall<Post[] | { posts: Post[] }>("/api/admin/posts");
}

/**
 * Get all reports — GET /api/admin/reports
 */
export async function getReports(): Promise<Report[] | { reports: Report[] }> {
  return authApiCall<Report[] | { reports: Report[] }>("/api/admin/reports");
}

// ─── User Actions ────────────────────────────────────────────────────────────

/**
 * Block a user — PATCH /api/admin/users/:id/block
 */
export async function blockUser(userId: string): Promise<unknown> {
  return authApiCall(`/api/admin/users/${userId}/block`, { method: "PATCH" });
}

/**
 * Unblock a user — PATCH /api/admin/users/:id/unblock
 */
export async function unblockUser(userId: string): Promise<unknown> {
  return authApiCall(`/api/admin/users/${userId}/unblock`, { method: "PATCH" });
}

// ─── Post Actions ────────────────────────────────────────────────────────────

/**
 * Delete a post — DELETE /api/admin/posts/:id
 */
export async function deletePost(postId: string): Promise<unknown> {
  return authApiCall(`/api/admin/posts/${postId}`, { method: "DELETE" });
}

/**
 * Hide a post — PATCH /api/admin/posts/:id/hide
 */
export async function hidePost(postId: string): Promise<unknown> {
  return authApiCall(`/api/admin/posts/${postId}/hide`, { method: "PATCH" });
}

/**
 * Unhide a post — PATCH /api/admin/posts/:id/unhide
 */
export async function unhidePost(postId: string): Promise<unknown> {
  return authApiCall(`/api/admin/posts/${postId}/unhide`, { method: "PATCH" });
}

// ─── Report Actions ──────────────────────────────────────────────────────────

/**
 * Mark a report as reviewed — PATCH /api/admin/reports/:id/review
 */
export async function reviewReport(reportId: string): Promise<unknown> {
  return authApiCall(`/api/admin/reports/${reportId}/review`, {
    method: "PATCH",
  });
}

/**
 * Dismiss a report — PATCH /api/admin/reports/:id/dismiss
 */
export async function dismissReport(reportId: string): Promise<unknown> {
  return authApiCall(`/api/admin/reports/${reportId}/dismiss`, {
    method: "PATCH",
  });
}
