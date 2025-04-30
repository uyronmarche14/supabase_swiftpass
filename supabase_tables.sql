-- Create students table with simplified required fields
CREATE TABLE students (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    student_id TEXT UNIQUE NOT NULL,
    course TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create subjects table
CREATE TABLE subjects (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    code TEXT UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create labs table
CREATE TABLE labs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    day_of_week TEXT NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    subject_id UUID REFERENCES subjects(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create student_labs table (many-to-many relationship)
CREATE TABLE student_labs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    student_id UUID REFERENCES students(id) NOT NULL,
    lab_id UUID REFERENCES labs(id) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    UNIQUE(student_id, lab_id)
);

-- Create attendance table (references labs instead of containing lab_schedule)
CREATE TABLE attendance (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    student_id UUID REFERENCES students(id) NOT NULL,
    lab_id UUID REFERENCES labs(id) NOT NULL,
    time_in TIMESTAMP WITH TIME ZONE NOT NULL,
    time_out TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create qr_codes table
CREATE TABLE qr_codes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    student_id UUID REFERENCES students(id) NOT NULL,
    qr_data JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create RLS policies
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE labs ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_labs ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE qr_codes ENABLE ROW LEVEL SECURITY;

-- Students policies
CREATE POLICY "Students can view their own data"
    ON students FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Students can update their own data"
    ON students FOR UPDATE
    USING (auth.uid() = id);

-- Subjects policies (all users can read subjects)
CREATE POLICY "Anyone can view subjects"
    ON subjects FOR SELECT
    USING (true);

-- Labs policies (all users can read labs)
CREATE POLICY "Anyone can view labs"
    ON labs FOR SELECT
    USING (true);

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

-- Attendance policies
CREATE POLICY "Students can view their own attendance"
    ON attendance FOR SELECT
    USING (auth.uid() = student_id);

CREATE POLICY "Students can create their own attendance records"
    ON attendance FOR INSERT
    WITH CHECK (auth.uid() = student_id);

-- QR codes policies
CREATE POLICY "Students can view their own QR codes"
    ON qr_codes FOR SELECT
    USING (auth.uid() = student_id);

CREATE POLICY "Students can update their own QR codes"
    ON qr_codes FOR UPDATE
    USING (auth.uid() = student_id); 