const express = require("express");
const router = express.Router();

const User = require("../models/User");
const Post = require("../models/Post");
const Report = require("../models/Report");
const auth = require("../middleware/auth");
const adminMiddleware = require("../middleware/adminMiddleware");

// Apply both middlewares to every admin route
router.use(auth, adminMiddleware);

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────

// @route   GET /api/admin/dashboard
// @desc    Overview stats
// @access  Admin
router.get("/dashboard", async (req, res) => {
  try {
    const [totalUsers, totalAdmins, blockedUsers, totalPosts] = await Promise.all([
      User.countDocuments({ role: "user" }),
      User.countDocuments({ role: "admin" }),
      User.countDocuments({ isBlocked: true }),
      Post.countDocuments(),
    ]);

    res.json({ totalUsers, totalAdmins, blockedUsers, totalPosts });
  } catch (err) {
    console.error("Dashboard error:", err);
    res.status(500).json({ message: "Server error" });
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// USER MANAGEMENT
// ─────────────────────────────────────────────────────────────────────────────

// @route   GET /api/admin/users
// @desc    Get all users (no passwords)
// @access  Admin
router.get("/users", async (req, res) => {
  try {
    const users = await User.find().select("-password").sort({ createdAt: -1 });
    res.json({ users });
  } catch (err) {
    console.error("Admin get users error:", err);
    res.status(500).json({ message: "Server error" });
  }
});

// @route   PATCH /api/admin/users/:id/block
// @desc    Block a user (cannot block another admin)
// @access  Admin
router.patch("/users/:id/block", async (req, res) => {
  try {
    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    if (user.role === "admin") {
      return res.status(403).json({ message: "Cannot block another admin" });
    }

    user.isBlocked = true;
    await user.save();

    res.json({ message: "User blocked successfully", userId: user._id });
  } catch (err) {
    console.error("Block user error:", err);
    if (err.name === "CastError") {
      return res.status(404).json({ message: "User not found" });
    }
    res.status(500).json({ message: "Server error" });
  }
});

// @route   PATCH /api/admin/users/:id/unblock
// @desc    Unblock a user
// @access  Admin
router.patch("/users/:id/unblock", async (req, res) => {
  try {
    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    user.isBlocked = false;
    await user.save();

    res.json({ message: "User unblocked successfully", userId: user._id });
  } catch (err) {
    console.error("Unblock user error:", err);
    if (err.name === "CastError") {
      return res.status(404).json({ message: "User not found" });
    }
    res.status(500).json({ message: "Server error" });
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// POST MANAGEMENT
// ─────────────────────────────────────────────────────────────────────────────

// @route   GET /api/admin/posts
// @desc    Get ALL posts (including hidden), with author info
// @access  Admin
router.get("/posts", async (req, res) => {
  try {
    const posts = await Post.find()
      .sort({ createdAt: -1 })
      .populate("createdBy", "username email");
    res.json({ posts });
  } catch (err) {
    console.error("Admin get posts error:", err);
    res.status(500).json({ message: "Server error" });
  }
});

// @route   DELETE /api/admin/posts/:id
// @desc    Admin can delete any post
// @access  Admin
router.delete("/posts/:id", async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);

    if (!post) {
      return res.status(404).json({ message: "Post not found" });
    }

    await post.deleteOne();

    res.json({ message: "Post deleted successfully" });
  } catch (err) {
    console.error("Admin delete post error:", err);
    if (err.name === "CastError") {
      return res.status(404).json({ message: "Post not found" });
    }
    res.status(500).json({ message: "Server error" });
  }
});

// @route   PATCH /api/admin/posts/:id/hide
// @desc    Hide a post from public listing
// @access  Admin
router.patch("/posts/:id/hide", async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);

    if (!post) {
      return res.status(404).json({ message: "Post not found" });
    }

    post.isHidden = true;
    await post.save();

    res.json({ message: "Post hidden successfully", postId: post._id });
  } catch (err) {
    console.error("Hide post error:", err);
    if (err.name === "CastError") {
      return res.status(404).json({ message: "Post not found" });
    }
    res.status(500).json({ message: "Server error" });
  }
});

// @route   PATCH /api/admin/posts/:id/unhide
// @desc    Unhide a post (make it visible again)
// @access  Admin
router.patch("/posts/:id/unhide", async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);

    if (!post) {
      return res.status(404).json({ message: "Post not found" });
    }

    post.isHidden = false;
    await post.save();

    res.json({ message: "Post unhidden successfully", postId: post._id });
  } catch (err) {
    console.error("Unhide post error:", err);
    if (err.name === "CastError") {
      return res.status(404).json({ message: "Post not found" });
    }
    res.status(500).json({ message: "Server error" });
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// REPORT MANAGEMENT
// ─────────────────────────────────────────────────────────────────────────────

// @route   GET /api/admin/reports
// @desc    Get all reports with post and user info
// @access  Admin
router.get("/reports", async (req, res) => {
  try {
    const reports = await Report.find()
      .sort({ createdAt: -1 })
      .populate("post", "title content imageUrl")
      .populate("reportedBy", "username email");
    res.json({ reports });
  } catch (err) {
    console.error("Admin get reports error:", err);
    res.status(500).json({ message: "Server error" });
  }
});

// @route   PATCH /api/admin/reports/:id/review
// @desc    Mark a report as reviewed
// @access  Admin
router.patch("/reports/:id/review", async (req, res) => {
  try {
    const report = await Report.findById(req.params.id);

    if (!report) {
      return res.status(404).json({ message: "Report not found" });
    }

    report.status = "reviewed";
    await report.save();

    res.json({ message: "Report marked as reviewed", reportId: report._id });
  } catch (err) {
    console.error("Review report error:", err);
    if (err.name === "CastError") {
      return res.status(404).json({ message: "Report not found" });
    }
    res.status(500).json({ message: "Server error" });
  }
});

// @route   PATCH /api/admin/reports/:id/dismiss
// @desc    Dismiss a report
// @access  Admin
router.patch("/reports/:id/dismiss", async (req, res) => {
  try {
    const report = await Report.findById(req.params.id);

    if (!report) {
      return res.status(404).json({ message: "Report not found" });
    }

    report.status = "dismissed";
    await report.save();

    res.json({ message: "Report dismissed", reportId: report._id });
  } catch (err) {
    console.error("Dismiss report error:", err);
    if (err.name === "CastError") {
      return res.status(404).json({ message: "Report not found" });
    }
    res.status(500).json({ message: "Server error" });
  }
});

module.exports = router;
