const express = require("express");
const router = express.Router();
const jwt = require("jsonwebtoken");
const User = require("../models/User");
const { generateAccessToken, generateRefreshToken } = require("../utils/generateTokens");

const buildAuthResponse = (user) => ({
  id: user._id,
  username: user.username,
  email: user.email,
  bio: user.bio || "",
  role: user.role,
});

// @route   POST api/auth/register
// @desc    Register a user
// @access  Public
router.post("/register", async (req, res) => {
  const { username, email, password, bio } = req.body;

  try {
    // Basic validation
    if (!username || !email || !password) {
      return res.status(400).json({ message: "Please enter all fields" });
    }

    // Check if user already exists by email
    let user = await User.findOne({ email });
    if (user) {
      return res.status(400).json({ message: "User with this email already exists" });
    }

    // Check if user already exists by username
    user = await User.findOne({ username });
    if (user) {
      return res.status(400).json({ message: "User with this username already exists" });
    }

    // Create new user
    user = new User({
      username,
      email,
      password,
      bio: bio || "",
    });

    await user.save();

    // Create access token + refresh token
    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user);

    // Persist refresh token in DB
    user.refreshToken = refreshToken;
    await user.save();

    res.status(201).json({
      accessToken,
      refreshToken,
      user: buildAuthResponse(user),
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
});

// @route   POST api/auth/login
// @desc    Authenticate user & get token
// @access  Public
router.post("/login", async (req, res) => {
  const { email, password } = req.body;

  try {
    // Basic validation
    if (!email || !password) {
      return res.status(400).json({ message: "Please enter all fields" });
    }

    // Check for user
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: "Invalid credentials" });
    }

    // Validate password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(400).json({ message: "Invalid credentials" });
    }

    // Check if account is blocked
    if (user.isBlocked) {
      return res.status(403).json({ message: "Your account has been blocked by admin" });
    }

    // Create access token + refresh token
    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user);

    // Persist refresh token in DB
    user.refreshToken = refreshToken;
    await user.save();

    res.json({
      accessToken,
      refreshToken,
      user: buildAuthResponse(user),
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
});

// @route   POST api/auth/refresh-token
// @desc    Get a new access token using a valid refresh token
// @access  Public
router.post("/refresh-token", async (req, res) => {
  const { refreshToken } = req.body;

  if (!refreshToken) {
    return res.status(401).json({ message: "Refresh token is required" });
  }

  try {
    // Verify the refresh token signature + expiry
    const decoded = jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET);

    // Find user by id from payload
    const user = await User.findById(decoded.id);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Ensure the token matches the one stored in DB (rotation / revocation check)
    if (user.refreshToken !== refreshToken) {
      return res.status(403).json({ message: "Refresh token is invalid or has been revoked" });
    }

    // Reject blocked users
    if (user.isBlocked) {
      return res.status(403).json({ message: "Your account has been blocked by admin" });
    }

    // Issue a fresh access token
    const accessToken = generateAccessToken(user);

    res.json({ accessToken });
  } catch (err) {
    // Handles TokenExpiredError and JsonWebTokenError
    return res.status(403).json({ message: "Refresh token expired or invalid" });
  }
});

// @route   POST api/auth/logout
// @desc    Invalidate the refresh token stored in DB
// @access  Public
router.post("/logout", async (req, res) => {
  const { refreshToken } = req.body;

  try {
    if (refreshToken) {
      // Find user by their current refresh token and clear it
      const user = await User.findOne({ refreshToken });
      if (user) {
        user.refreshToken = "";
        await user.save();
      }
    }

    res.json({ message: "Logged out successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
});

module.exports = router;
