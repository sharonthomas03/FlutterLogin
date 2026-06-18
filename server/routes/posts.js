const express = require("express");
const router = express.Router();

const Post = require("../models/Post");
const Report = require("../models/Report");
const auth = require("../middleware/auth");
const upload = require("../middleware/upload");

// ─────────────────────────────────────────────────────────────────────────────
// Helper: build the imageUrl from the uploaded file
// ─────────────────────────────────────────────────────────────────────────────
const buildImageUrl = (req) => {
  if (!req.file) return "";
  return `${req.protocol}://${req.get("host")}/uploads/${req.file.filename}`;
};

// ─────────────────────────────────────────────────────────────────────────────
// @route   POST /api/posts
// @desc    Create a new post (with optional image)
// @access  Protected
// ─────────────────────────────────────────────────────────────────────────────
router.post("/", auth, upload.single("image"), async (req, res) => {
  try {
    const { title, content } = req.body;

    // Validation
    if (!title || !content) {
      return res.status(400).json({ message: "Title and content are required" });
    }
    if (title.trim().length < 3) {
      return res.status(400).json({ message: "Title must be at least 3 characters" });
    }
    if (content.trim().length < 5) {
      return res.status(400).json({ message: "Content must be at least 5 characters" });
    }

    const post = new Post({
      title: title.trim(),
      content: content.trim(),
      imageUrl: buildImageUrl(req),
      createdBy: req.user.id,
    });

    await post.save();

    res.status(201).json({
      message: "Post created successfully",
      post,
    });
  } catch (err) {
    console.error("Create post error:", err);
    // Multer file-type error
    if (err.message && err.message.includes("Only image files")) {
      return res.status(400).json({ message: err.message });
    }
    res.status(500).json({ message: "Server error" });
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// @route   GET /api/posts/my
// @desc    Get posts created by the logged-in user
// @access  Protected
// ─────────────────────────────────────────────────────────────────────────────
router.get("/my", auth, async (req, res) => {
  try {
    const posts = await Post.find({ createdBy: req.user.id }).sort({ createdAt: -1 });
    res.json({ posts });
  } catch (err) {
    console.error("Get my posts error:", err);
    res.status(500).json({ message: "Server error" });
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// @route   GET /api/posts
// @desc    Get all visible posts (public) with author info
// @access  Public
// ─────────────────────────────────────────────────────────────────────────────
router.get("/", async (req, res) => {
  try {
    const posts = await Post.find({ isHidden: false })
      .sort({ createdAt: -1 })
      .populate("createdBy", "username email");
    res.json({ posts });
  } catch (err) {
    console.error("Get all posts error:", err);
    res.status(500).json({ message: "Server error" });
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// @route   PUT /api/posts/:id
// @desc    Update a post (only by owner)
// @access  Protected
// ─────────────────────────────────────────────────────────────────────────────
router.put("/:id", auth, upload.single("image"), async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);

    if (!post) {
      return res.status(404).json({ message: "Post not found" });
    }

    // Ownership check
    if (post.createdBy.toString() !== req.user.id) {
      return res.status(403).json({ message: "Forbidden: You can only edit your own posts" });
    }

    const { title, content } = req.body;

    // Validate only if provided
    if (title !== undefined) {
      if (title.trim().length < 3) {
        return res.status(400).json({ message: "Title must be at least 3 characters" });
      }
      post.title = title.trim();
    }

    if (content !== undefined) {
      if (content.trim().length < 5) {
        return res.status(400).json({ message: "Content must be at least 5 characters" });
      }
      post.content = content.trim();
    }

    // If a new image was uploaded, replace the imageUrl
    if (req.file) {
      post.imageUrl = buildImageUrl(req);
    }

    await post.save();

    res.json({
      message: "Post updated successfully",
      post,
    });
  } catch (err) {
    console.error("Update post error:", err);
    if (err.message && err.message.includes("Only image files")) {
      return res.status(400).json({ message: err.message });
    }
    // Invalid ObjectId format
    if (err.name === "CastError") {
      return res.status(404).json({ message: "Post not found" });
    }
    res.status(500).json({ message: "Server error" });
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// @route   DELETE /api/posts/:id
// @desc    Delete a post (only by owner)
// @access  Protected
// ─────────────────────────────────────────────────────────────────────────────
router.delete("/:id", auth, async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);

    if (!post) {
      return res.status(404).json({ message: "Post not found" });
    }

    // Ownership check
    if (post.createdBy.toString() !== req.user.id) {
      return res.status(403).json({ message: "Forbidden: You can only delete your own posts" });
    }

    await post.deleteOne();

    res.json({ message: "Post deleted successfully" });
  } catch (err) {
    console.error("Delete post error:", err);
    if (err.name === "CastError") {
      return res.status(404).json({ message: "Post not found" });
    }
    res.status(500).json({ message: "Server error" });
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// @route   POST /api/posts/:id/report
// @desc    Report a post (one report per user per post)
// @access  Protected
// ─────────────────────────────────────────────────────────────────────────────
router.post("/:id/report", auth, async (req, res) => {
  try {
    const { reason } = req.body;

    if (!reason || reason.trim().length === 0) {
      return res.status(400).json({ message: "Reason is required" });
    }

    const post = await Post.findById(req.params.id);
    if (!post) {
      return res.status(404).json({ message: "Post not found" });
    }

    // Prevent duplicate report from the same user
    const existing = await Report.findOne({
      post: post._id,
      reportedBy: req.user.id,
    });
    if (existing) {
      return res.status(400).json({ message: "You have already reported this post" });
    }

    const report = new Report({
      post: post._id,
      reportedBy: req.user.id,
      reason: reason.trim(),
    });

    await report.save();

    res.status(201).json({ message: "Post reported successfully", report });
  } catch (err) {
    console.error("Report post error:", err);
    if (err.name === "CastError") {
      return res.status(404).json({ message: "Post not found" });
    }
    res.status(500).json({ message: "Server error" });
  }
});

module.exports = router;
