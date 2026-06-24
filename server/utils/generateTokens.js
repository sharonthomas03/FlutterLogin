const jwt = require("jsonwebtoken");

/**
 * Generates a short-lived access token (default 15m).
 * Payload includes user id and role.
 *
 * NOTE (Security): For higher security in production, consider storing
 * the access token in memory (React state / Redux) instead of localStorage.
 */
const generateAccessToken = (user) => {
  return jwt.sign(
    {
      id: user._id,
      role: user.role,
    },
    process.env.ACCESS_TOKEN_SECRET,
    {
      expiresIn: process.env.ACCESS_TOKEN_EXPIRES_IN || "15m",
    }
  );
};

/**
 * Generates a long-lived refresh token (default 7d).
 * Payload includes user id and role.
 *
 * NOTE (Security): For higher security in production, consider sending the
 * refresh token as an httpOnly secure cookie instead of in the response body.
 */
const generateRefreshToken = (user) => {
  return jwt.sign(
    {
      id: user._id,
      role: user.role,
    },
    process.env.REFRESH_TOKEN_SECRET,
    {
      expiresIn: process.env.REFRESH_TOKEN_EXPIRES_IN || "7d",
    }
  );
};

module.exports = {
  generateAccessToken,
  generateRefreshToken,
};
