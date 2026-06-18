const BASE_URL = "http://localhost:5000";

/**
 * Make a public API call (no auth header).
 */
export async function apiCall(endpoint, options = {}) {
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

  return data;
}

/**
 * Make an authenticated API call using the adminToken from localStorage.
 */
export async function authApiCall(endpoint, options = {}) {
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

  return data;
}

/**
 * Login — POST /api/auth/login
 */
export async function login(email, password) {
  return apiCall("/api/auth/login", {
    method: "POST",
    body: JSON.stringify({ email, password }),
  });
}

/**
 * Get dashboard stats — GET /api/admin/dashboard
 */
export async function getDashboardStats() {
  return authApiCall("/api/admin/dashboard");
}

/**
 * Get all users — GET /api/admin/users
 */
export async function getUsers() {
  return authApiCall("/api/admin/users");
}

/**
 * Get all posts — GET /api/admin/posts
 */
export async function getPosts() {
  return authApiCall("/api/admin/posts");
}

/**
 * Get all reports — GET /api/admin/reports
 */
export async function getReports() {
  return authApiCall("/api/admin/reports");
}

// ─── User Actions ────────────────────────────────────────────────────────────

/**
 * Block a user — PATCH /api/admin/users/:id/block
 */
export async function blockUser(userId) {
  return authApiCall(`/api/admin/users/${userId}/block`, { method: "PATCH" });
}

/**
 * Unblock a user — PATCH /api/admin/users/:id/unblock
 */
export async function unblockUser(userId) {
  return authApiCall(`/api/admin/users/${userId}/unblock`, { method: "PATCH" });
}

// ─── Post Actions ────────────────────────────────────────────────────────────

/**
 * Delete a post — DELETE /api/admin/posts/:id
 */
export async function deletePost(postId) {
  return authApiCall(`/api/admin/posts/${postId}`, { method: "DELETE" });
}

/**
 * Hide a post — PATCH /api/admin/posts/:id/hide
 */
export async function hidePost(postId) {
  return authApiCall(`/api/admin/posts/${postId}/hide`, { method: "PATCH" });
}

/**
 * Unhide a post — PATCH /api/admin/posts/:id/unhide
 */
export async function unhidePost(postId) {
  return authApiCall(`/api/admin/posts/${postId}/unhide`, { method: "PATCH" });
}

// ─── Report Actions ──────────────────────────────────────────────────────────

/**
 * Mark a report as reviewed — PATCH /api/admin/reports/:id/review
 */
export async function reviewReport(reportId) {
  return authApiCall(`/api/admin/reports/${reportId}/review`, {
    method: "PATCH",
  });
}

/**
 * Dismiss a report — PATCH /api/admin/reports/:id/dismiss
 */
export async function dismissReport(reportId) {
  return authApiCall(`/api/admin/reports/${reportId}/dismiss`, {
    method: "PATCH",
  });
}
