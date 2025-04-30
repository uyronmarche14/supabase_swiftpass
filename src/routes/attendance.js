const express = require("express");
const router = express.Router();
const { supabase } = require("../config/supabase");

// Record time in
router.post("/time-in", async (req, res) => {
  try {
    const { studentId, labSchedule } = req.body;

    // Check if student exists
    const { data: student, error: studentError } = await supabase
      .from("students")
      .select("id")
      .eq("id", studentId)
      .single();

    if (studentError) throw new Error("Student not found");

    // Create attendance record
    const { data, error } = await supabase
      .from("attendance")
      .insert([
        {
          student_id: studentId,
          time_in: new Date().toISOString(),
          lab_schedule: labSchedule,
        },
      ])
      .select()
      .single();

    if (error) throw error;

    res.status(201).json({
      message: "Time in recorded successfully",
      attendance: data,
    });
  } catch (error) {
    console.error("Time in error:", error);
    res.status(400).json({ error: error.message });
  }
});

// Record time out
router.patch("/time-out/:attendanceId", async (req, res) => {
  try {
    const { attendanceId } = req.params;

    // Update attendance record with time out
    const { data, error } = await supabase
      .from("attendance")
      .update({
        time_out: new Date().toISOString(),
      })
      .eq("id", attendanceId)
      .select()
      .single();

    if (error) throw error;

    res.json({
      message: "Time out recorded successfully",
      attendance: data,
    });
  } catch (error) {
    console.error("Time out error:", error);
    res.status(400).json({ error: error.message });
  }
});

// Get attendance records for a student
router.get("/student/:studentId", async (req, res) => {
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
    console.error("Get attendance error:", error);
    res.status(400).json({ error: error.message });
  }
});

// Get all attendance records for a specific date (admin only)
router.get("/date/:date", async (req, res) => {
  try {
    const { date } = req.params;

    // Create date range for the specified date
    const startDate = new Date(date);
    startDate.setHours(0, 0, 0, 0);

    const endDate = new Date(date);
    endDate.setHours(23, 59, 59, 999);

    const { data, error } = await supabase
      .from("attendance")
      .select("*, students(full_name, student_id, course)")
      .gte("time_in", startDate.toISOString())
      .lte("time_in", endDate.toISOString())
      .order("time_in", { ascending: true });

    if (error) throw error;

    res.json(data);
  } catch (error) {
    console.error("Get attendance by date error:", error);
    res.status(400).json({ error: error.message });
  }
});

module.exports = router;
