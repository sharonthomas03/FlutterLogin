const express = require("express");
const router = express.Router();

const auth = require("../middleware/auth");
const User = require("../models/User");

const buildProfileResponse = (user) => ({
  id: user._id,
  username: user.username,
  email: user.email,
  bio: user.bio || "",
});

// @route   GET api/profile
// @desc    Get current user profile
// @access  Private
router.get("/", auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select("-password");

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json({ user: buildProfileResponse(user) });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
});

// @route   PUT api/profile
// @desc    Update current user profile
// @access  Private
router.put("/", auth, async (req, res) => {
  const { username, email, bio } = req.body;

  try {
    const user = await User.findById(req.user.id);

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    const nextUsername = typeof username === "string" ? username.trim() : user.username;
    const nextEmail = typeof email === "string" ? email.trim().toLowerCase() : user.email;
    const nextBio = typeof bio === "string" ? bio.trim() : user.bio;

    if (!nextUsername || !nextEmail) {
      return res.status(400).json({ message: "Username and email are required" });
    }

    const emailOwner = await User.findOne({ email: nextEmail, _id: { $ne: user._id } });
    if (emailOwner) {
      return res.status(400).json({ message: "User with this email already exists" });
    }

    const usernameOwner = await User.findOne({ username: nextUsername, _id: { $ne: user._id } });
    if (usernameOwner) {
      return res.status(400).json({ message: "User with this username already exists" });
    }

    user.username = nextUsername;
    user.email = nextEmail;
    user.bio = nextBio;

    await user.save();

    res.json({
      message: "Profile updated successfully",
      user: buildProfileResponse(user),
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
});

module.exports = router;
