const jwt = require("jsonwebtoken");

/**
 * Authentication middleware.
 *
 * Reads the Authorization header (format: "Bearer <accessToken>"),
 * verifies the access token using ACCESS_TOKEN_SECRET, and attaches
 * the decoded payload to req.user.
 *
 * The refresh token must NEVER be used here — it is only accepted by
 * /api/auth/refresh-token and /api/auth/logout.
 */
module.exports = function (req, res, next) {
  // Get token from header
  const authHeader = req.header("Authorization");

  if (!authHeader) {
    return res.status(401).json({ message: "No token, authorization denied" });
  }

  // Expecting format 'Bearer <accessToken>'
  const parts = authHeader.split(" ");
  if (parts.length !== 2 || parts[0] !== "Bearer") {
    return res.status(401).json({ message: "Token format is invalid, expected Bearer <token>" });
  }

  const accessToken = parts[1];

  try {
    const decoded = jwt.verify(accessToken, process.env.ACCESS_TOKEN_SECRET);
    // Attach user payload to the request object
    req.user = decoded;
    next();
  } catch (err) {
    res.status(401).json({ message: "Access token expired or invalid" });
  }
};
