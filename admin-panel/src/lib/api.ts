import type { LoginResponse, DashboardStats, AdminUser, Post, Report } from "@/types";

const BASE_URL = "http://localhost:5000";

type FetchOptions = RequestInit & {
  headers?: Record<string, string>;
};

// ─── Token Helpers ────────────────────────────────────────────────────────────

function getAccessToken(): string | null {
  return typeof window !== "undefined" ? localStorage.getItem("accessToken") : null;
}

function getRefreshToken(): string | null {
  return typeof window !== "undefined" ? localStorage.getItem("refreshToken") : null;
}

function clearTokens(): void {
  localStorage.removeItem("accessToken");
  localStorage.removeItem("refreshToken");
  // Also remove legacy key if it exists from old sessions
  localStorage.removeItem("adminToken");
  localStorage.removeItem("adminUser");
}

/**
 * Attempt to refresh the access token using the stored refresh token.
 * Returns the new access token on success, or null on failure.
 */
async function refreshAccessToken(): Promise<string | null> {
  const refreshToken = getRefreshToken();
  if (!refreshToken) return null;

  try {
    const response = await fetch(`${BASE_URL}/api/auth/refresh-token`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refreshToken }),
    });

    if (!response.ok) return null;

    const data = await response.json();
    if (data.accessToken) {
      localStorage.setItem("accessToken", data.accessToken);
      return data.accessToken;
    }
    return null;
  } catch {
    return null;
  }
}

// ─── Core API Helpers ─────────────────────────────────────────────────────────

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
 * Make an authenticated API call using the accessToken from localStorage.
 *
 * If the server returns 401 (access token expired/invalid):
 *   1. Attempt to refresh using the stored refresh token.
 *   2. If refresh succeeds, retry the original request once with the new access token.
 *   3. If refresh fails, clear all tokens and redirect to /login.
 *
 * NOTE (Security): For production, prefer storing the refresh token in an
 * httpOnly secure cookie and the access token in memory/localStorage.
 */
export async function authApiCall<T = unknown>(endpoint: string, options: FetchOptions = {}): Promise<T> {
  const token = getAccessToken();
  const url = `${BASE_URL}${endpoint}`;

  // ── First attempt ──────────────────────────────────────────────────────────
  const response = await fetch(url, {
    headers: {
      "Content-Type": "application/json",
      Authorization: token ? `Bearer ${token}` : "",
      ...(options.headers || {}),
    },
    ...options,
  });

  // ── Handle non-401 errors immediately ──────────────────────────────────────
  if (response.status !== 401) {
    const data = await response.json();
    if (!response.ok) {
      throw new Error(data.message || "Something went wrong");
    }
    return data as T;
  }

  // ── 401 → try to refresh ───────────────────────────────────────────────────
  const newAccessToken = await refreshAccessToken();

  if (!newAccessToken) {
    // Refresh failed — clear tokens and redirect to login
    clearTokens();
    if (typeof window !== "undefined") {
      window.location.href = "/login";
    }
    throw new Error("Session expired. Please log in again.");
  }

  // ── Retry original request once with the new access token ──────────────────
  const retryResponse = await fetch(url, {
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${newAccessToken}`,
      ...(options.headers || {}),
    },
    ...options,
  });

  const retryData = await retryResponse.json();
  if (!retryResponse.ok) {
    throw new Error(retryData.message || "Something went wrong");
  }

  return retryData as T;
}

// ─── Auth API ─────────────────────────────────────────────────────────────────

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
 * Logout — POST /api/auth/logout
 * Clears the refresh token from the DB, then wipes localStorage.
 */
export async function logout(): Promise<void> {
  const refreshToken = getRefreshToken();
  try {
    await fetch(`${BASE_URL}/api/auth/logout`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refreshToken }),
    });
  } catch {
    // Best-effort — always clear local tokens even if the request fails
  } finally {
    clearTokens();
  }
}

// ─── Admin Stats ──────────────────────────────────────────────────────────────

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
