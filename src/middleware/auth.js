const jwt = require("jsonwebtoken");
const { supabase } = require("../config/supabase");

// Authentication middleware
exports.authenticate = async (req, res, next) => {
  try {
    // Get token from header
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({ error: "No token provided" });
    }

    const token = authHeader.split(" ")[1];

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Check if user exists in database
    const { data: user, error } = await supabase
      .from("students")
      .select("id, email, full_name, student_id")
      .eq("id", decoded.userId)
      .single();

    if (error || !user) {
      return res.status(401).json({ error: "Invalid token" });
    }

    // Add user to request object
    req.user = user;
    next();
  } catch (error) {
    console.error("Auth middleware error:", error);
    if (error.name === "JsonWebTokenError") {
      return res.status(401).json({ error: "Invalid token" });
    }
    if (error.name === "TokenExpiredError") {
      return res.status(401).json({ error: "Token expired" });
    }
    res.status(500).json({ error: "Server error" });
  }
};

// Admin middleware - check if user is an admin
exports.isAdmin = async (req, res, next) => {
  try {
    // Check if user exists and has admin role
    const { data, error } = await supabase
      .from("students")
      .select("is_admin")
      .eq("id", req.user.id)
      .single();

    if (error || !data || !data.is_admin) {
      return res.status(403).json({ error: "Access denied" });
    }

    next();
  } catch (error) {
    console.error("Admin middleware error:", error);
    res.status(500).json({ error: "Server error" });
  }
};
