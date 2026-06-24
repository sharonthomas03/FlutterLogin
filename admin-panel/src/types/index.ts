// ─── User Types ──────────────────────────────────────────────────────────────

export type AdminUser = {
  _id: string;
  username: string;
  email: string;
  role: "admin" | "user";
  isBlocked: boolean;
};

// ─── Post Types ──────────────────────────────────────────────────────────────

export type Post = {
  _id: string;
  title: string;
  content?: string;
  isHidden: boolean;
  createdBy?: {
    _id: string;
    username?: string;
    name?: string;
  };
  authorName?: string;
  createdAt?: string;
  updatedAt?: string;
};

// ─── Report Types ────────────────────────────────────────────────────────────

export type ReportStatus = "pending" | "reviewed" | "dismissed";

export type Report = {
  _id: string;
  reason?: string;
  status: ReportStatus;
  post?: {
    _id: string;
    title?: string;
  };
  reportedBy?: {
    _id: string;
    username?: string;
    email?: string;
  };
  createdAt?: string;
  updatedAt?: string;
};

// ─── Dashboard Stats ─────────────────────────────────────────────────────────

export type DashboardStats = {
  totalUsers: number;
  totalAdmins: number;
  blockedUsers: number;
  totalPosts: number;
};

// ─── API Response Types ──────────────────────────────────────────────────────

export type LoginResponse = {
  accessToken: string;
  refreshToken: string;
  user: AdminUser;
};

export type ApiErrorResponse = {
  message: string;
};
