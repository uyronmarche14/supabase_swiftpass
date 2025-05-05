-- SwiftPass Schema Definition
-- This file contains all table definitions and security policies

-- Create students table with simplified required fields
CREATE TABLE IF NOT EXISTS students (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    student_id TEXT UNIQUE NOT NULL,
    course TEXT,
    section TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create admins table
CREATE TABLE IF NOT EXISTS admins (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    role TEXT DEFAULT 'admin' NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create subjects table
CREATE TABLE IF NOT EXISTS subjects (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    code TEXT UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create labs table
CREATE TABLE IF NOT EXISTS labs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    section TEXT,
    day_of_week TEXT NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    subject_id UUID REFERENCES subjects(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create student_labs table (many-to-many relationship)
CREATE TABLE IF NOT EXISTS student_labs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    student_id UUID REFERENCES students(id) NOT NULL,
    lab_id UUID REFERENCES labs(id) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    UNIQUE(student_id, lab_id)
);

-- Create attendance table (references labs instead of containing lab_schedule)
CREATE TABLE IF NOT EXISTS attendance (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    student_id UUID REFERENCES students(id) NOT NULL,
    lab_id UUID REFERENCES labs(id) NOT NULL,
    time_in TIMESTAMP WITH TIME ZONE NOT NULL,
    time_out TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create qr_codes table
CREATE TABLE IF NOT EXISTS qr_codes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    student_id UUID REFERENCES students(id) NOT NULL,
    qr_data JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Enable Row Level Security on all tables
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE labs ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_labs ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE qr_codes ENABLE ROW LEVEL SECURITY;

-- Function to check if user is an admin
CREATE OR REPLACE FUNCTION is_admin() 
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM admins WHERE id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =================== SECURITY POLICIES ===================

-- Admins policies
CREATE POLICY "Admins can view their own data"
    ON admins FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Admins can update their own data"
    ON admins FOR UPDATE
    USING (auth.uid() = id);

-- Students policies
CREATE POLICY "Students can view their own data"
    ON students FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Students can update their own data"
    ON students FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Admins can view all student data"
    ON students FOR SELECT
    USING (is_admin());

CREATE POLICY "Admins can update all student data"
    ON students FOR UPDATE
    USING (is_admin());

-- Subjects policies
CREATE POLICY "Anyone can view subjects"
    ON subjects FOR SELECT
    USING (true);

CREATE POLICY "Admins can create subjects"
    ON subjects FOR INSERT
    WITH CHECK (is_admin());

CREATE POLICY "Admins can update subjects"
    ON subjects FOR UPDATE
    USING (is_admin());

CREATE POLICY "Admins can delete subjects"
    ON subjects FOR DELETE
    USING (is_admin());

-- Labs policies
CREATE POLICY "Anyone can view labs"
    ON labs FOR SELECT
    USING (true);

CREATE POLICY "Admins can create labs"
    ON labs FOR INSERT
    WITH CHECK (is_admin());

CREATE POLICY "Admins can update labs"
    ON labs FOR UPDATE
    USING (is_admin());

CREATE POLICY "Admins can delete labs"
    ON labs FOR DELETE
    USING (is_admin());

-- Student_labs policies
CREATE POLICY "Students can view their own lab enrollments"
    ON student_labs FOR SELECT
    USING (auth.uid() = student_id);

CREATE POLICY "Students can enroll in labs"
    ON student_labs FOR INSERT
    WITH CHECK (auth.uid() = student_id);

CREATE POLICY "Students can unenroll from labs"
    ON student_labs FOR DELETE
    USING (auth.uid() = student_id);

CREATE POLICY "Admins can view all lab enrollments"
    ON student_labs FOR SELECT
    USING (is_admin());

CREATE POLICY "Admins can manage lab enrollments"
    ON student_labs FOR INSERT
    WITH CHECK (is_admin());

CREATE POLICY "Admins can delete lab enrollments"
    ON student_labs FOR DELETE
    USING (is_admin());

-- Attendance policies
CREATE POLICY "Students can view their own attendance"
    ON attendance FOR SELECT
    USING (auth.uid() = student_id);

CREATE POLICY "Students can create their own attendance records"
    ON attendance FOR INSERT
    WITH CHECK (auth.uid() = student_id);

CREATE POLICY "Admins can view all attendance"
    ON attendance FOR SELECT
    USING (is_admin());

CREATE POLICY "Admins can manage attendance"
    ON attendance FOR ALL
    USING (is_admin());

-- QR codes policies
CREATE POLICY "Students can view their own QR codes"
    ON qr_codes FOR SELECT
    USING (auth.uid() = student_id);

CREATE POLICY "Students can update their own QR codes"
    ON qr_codes FOR UPDATE
    USING (auth.uid() = student_id);

CREATE POLICY "Admins can view all QR codes"
    ON qr_codes FOR SELECT
    USING (is_admin()); 