const express = require("express");
const router = express.Router();
const QRCode = require("qrcode");
const { supabase } = require("../config/supabase");

// Generate QR code for student
router.get("/generate/:studentId", async (req, res) => {
  try {
    const { studentId } = req.params;

    // Get student data
    const { data: student, error: studentError } = await supabase
      .from("students")
      .select("*")
      .eq("id", studentId)
      .single();

    if (studentError) throw studentError;

    // Generate QR data
    const qrData = {
      studentId: student.student_id,
      fullName: student.full_name,
      course: student.course,
      labSchedule: student.lab_schedule,
    };

    // Generate QR code
    const qrCode = await QRCode.toDataURL(JSON.stringify(qrData));

    res.json({
      qrCode,
      studentData: qrData,
    });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Scan QR code and record attendance
router.post("/scan", async (req, res) => {
  try {
    const { qrData } = req.body;
    const parsedData = JSON.parse(qrData);

    // Record attendance
    const { data, error } = await supabase.from("attendance").insert([
      {
        student_id: parsedData.studentId,
        time_in: new Date().toISOString(),
        lab_schedule: parsedData.labSchedule,
      },
    ]);

    if (error) throw error;

    res.json({
      message: "Attendance recorded successfully",
      attendance: data,
    });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Get attendance history for student
router.get("/attendance/:studentId", async (req, res) => {
  try {
    const { studentId } = req.params;

    const { data, error } = await supabase
      .from("attendance")
      .select("*")
      .eq("student_id", studentId)
      .order("time_in", { ascending: false });

    if (error) throw error;

    res.json(data);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

module.exports = router;
