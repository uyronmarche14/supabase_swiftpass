const express = require("express");
const router = express.Router();
const { supabase } = require("../config/supabase");

// Get student profile
router.get("/:studentId", async (req, res) => {
  try {
    const { studentId } = req.params;

    const { data, error } = await supabase
      .from("students")
      .select("*")
      .eq("id", studentId)
      .single();

    if (error) throw error;

    res.json(data);
  } catch (error) {
    console.error("Get student error:", error);
    res.status(400).json({ error: error.message });
  }
});

// Update student profile
router.put("/:studentId", async (req, res) => {
  try {
    const { studentId } = req.params;
    const { fullName, course, labSchedule } = req.body;

    const updates = {};
    if (fullName) updates.full_name = fullName;
    if (course) updates.course = course;
    if (labSchedule) updates.lab_schedule = labSchedule;

    const { data, error } = await supabase
      .from("students")
      .update(updates)
      .eq("id", studentId)
      .select()
      .single();

    if (error) throw error;

    // Update QR code data if profile is updated
    if (Object.keys(updates).length > 0) {
      // Get student data for complete QR code
      const { data: student, error: studentError } = await supabase
        .from("students")
        .select("*")
        .eq("id", studentId)
        .single();

      if (studentError) throw studentError;

      const qrData = {
        studentId: student.student_id,
        fullName: student.full_name,
        course: student.course,
        labSchedule: student.lab_schedule,
      };

      // Update QR code data
      const { error: qrError } = await supabase
        .from("qr_codes")
        .update({
          qr_data: qrData,
          updated_at: new Date().toISOString(),
        })
        .eq("student_id", studentId);

      if (qrError) throw qrError;
    }

    res.json(data);
  } catch (error) {
    console.error("Update student error:", error);
    res.status(400).json({ error: error.message });
  }
});

// Get all students (admin only)
router.get("/", async (req, res) => {
  try {
    // This route should be protected with admin middleware
    const { data, error } = await supabase
      .from("students")
      .select("*")
      .order("created_at", { ascending: false });

    if (error) throw error;

    res.json(data);
  } catch (error) {
    console.error("Get all students error:", error);
    res.status(400).json({ error: error.message });
  }
});

module.exports = router;
