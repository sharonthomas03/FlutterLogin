/**
 * adminMiddleware.js
 * Must be used AFTER authMiddleware (auth.js).
 * Allows access only if req.user.role === "admin".
 */
module.exports = function (req, res, next) {
  if (!req.user || req.user.role !== "admin") {
    return res.status(403).json({ message: "Access denied. Admin only." });
  }
  next();
};
