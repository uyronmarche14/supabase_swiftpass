# SwiftPass QR Attendance System - Backend

This is the backend for the SwiftPass QR-based attendance system, built with Express.js and Supabase.

## Features

- Student registration and authentication
- QR code generation for students
- Attendance tracking with time-in and time-out
- Student profile management
- Course and lab schedule management

## Installation

1. Clone the repository
2. Install dependencies:
   ```
   npm install
   ```
3. Create a `.env` file based on `.env.example` and fill in your Supabase credentials
4. Run the SQL script in your Supabase dashboard:
   ```
   supabase_tables.sql
   ```
5. Start the server:
   ```
   npm run dev
   ```

## Environment Variables

- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_ANON_KEY`: Your Supabase anon key
- `SUPABASE_SERVICE_ROLE_KEY`: Your Supabase service role key
- `PORT`: Server port (default: 5000)
- `NODE_ENV`: Environment (development/production)
- `JWT_SECRET`: Secret for JWT token generation

## API Endpoints

### Auth

- `POST /api/auth/register`: Register a new student
- `POST /api/auth/login`: Login and get token

### Students

- `GET /api/students/:studentId`: Get student profile
- `PUT /api/students/:studentId`: Update student profile
- `GET /api/students`: Get all students (admin only)

### QR Code

- `GET /api/qr/generate/:studentId`: Generate QR code for student
- `POST /api/qr/scan`: Scan QR code and record attendance
- `GET /api/qr/attendance/:studentId`: Get attendance history for student

### Attendance

- `POST /api/attendance/time-in`: Record time in
- `PATCH /api/attendance/time-out/:attendanceId`: Record time out
- `GET /api/attendance/student/:studentId`: Get attendance records for student
- `GET /api/attendance/date/:date`: Get all attendance records for a date (admin only)

## Database Schema

The system uses the following tables:

- `students`: Student profiles linked to Supabase Auth
- `attendance`: Attendance records with time-in and time-out
- `qr_codes`: QR code data for students

## Security

- JWT-based authentication
- Row-level security with Supabase
- Role-based access control (student/admin)
