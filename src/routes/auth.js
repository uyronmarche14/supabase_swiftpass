const express = require("express");
const router = express.Router();
const { supabase } = require("../config/supabase");
const jwt = require("jsonwebtoken");

// Register new student
router.post("/register", async (req, res) => {
  try {
    const { email, password, fullName, studentId, course } = req.body;

    // Create user in Supabase Auth with autoconfirm enabled
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email,
      password,
      options: {
        emailRedirectTo: null, // Disable email redirects
        data: {
          full_name: fullName,
          student_id: studentId,
        },
      },
    });

    if (authError) throw authError;

    // Create student profile in database
    const { data: profileData, error: profileError } = await supabase
      .from("students")
      .insert([
        {
          id: authData.user.id,
          email,
          full_name: fullName,
          student_id: studentId,
          course,
        },
      ]);

    if (profileError) throw profileError;

    // Generate QR code data
    const qrData = {
      studentId,
      fullName,
      course,
    };

    // Store QR data
    const { error: qrError } = await supabase.from("qr_codes").insert([
      {
        student_id: authData.user.id,
        qr_data: qrData,
      },
    ]);

    if (qrError) throw qrError;

    // Since email confirmation is not required, let's generate the token right away
    const token = jwt.sign(
      { userId: authData.user.id },
      process.env.JWT_SECRET,
      {
        expiresIn: "24h",
      }
    );

    res.status(201).json({
      message: "Student registered successfully",
      user: authData.user,
      token: token, // Provide token on registration
    });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Login
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) throw error;

    const token = jwt.sign({ userId: data.user.id }, process.env.JWT_SECRET, {
      expiresIn: "24h",
    });

    res.json({
      token,
      user: data.user,
    });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

module.exports = router;
