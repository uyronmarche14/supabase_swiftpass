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

# SwiftPass Database Setup

This directory contains the SQL scripts and setup tools for initializing the SwiftPass database in Supabase.

## Files Structure

- `1_schema.sql`: Contains all table definitions and security policies
- `2_data_init.sql`: Contains initial data setup including admin account and course/section data
- `run_setup.sh`: Bash script to run both SQL files in order (Linux/Mac)
- `run_setup.ps1`: PowerShell script to run both SQL files in order (Windows)

## Prerequisites

- Supabase CLI installed and configured
  - Visit [Supabase CLI documentation](https://supabase.com/docs/guides/cli) for installation instructions

## Running the Setup

### On Windows:

```powershell
cd supabase_backend
.\run_setup.ps1
```

### On Linux/Mac:

```bash
cd supabase_backend
chmod +x run_setup.sh
./run_setup.sh
```

## Manual Setup

If you prefer to run the scripts manually, execute them in this order:

1. Run the schema setup:

   ```
   supabase db execute --file 1_schema.sql
   ```

2. Run the data initialization:
   ```
   supabase db execute --file 2_data_init.sql
   ```

## Admin Account

After setup, you can log in with the default admin account:

- **Email**: admin@swiftpass.edu
- **Password**: Admin123!

## Database Schema

### Tables

1. **students**: Stores student profiles linked to Supabase auth
2. **admins**: Stores admin profiles linked to Supabase auth
3. **subjects**: Stores course information (BSIT, BSCS, etc.)
4. **labs**: Stores lab sessions with course and section information
5. **student_labs**: Many-to-many relationship between students and labs
6. **attendance**: Tracks student attendance for labs
7. **qr_codes**: Stores student QR code data for lab access

### Course and Section Structure

The database is seeded with the following courses and sections:

**Courses:**

- BSIT (Bachelor of Science in Information Technology)
- BSCS (Bachelor of Science in Computer Science)

**Sections:**

- A2021
- B2021
- C2021

## Troubleshooting

If you encounter errors:

1. Ensure Supabase CLI is installed and properly configured
2. Verify that you have the correct permissions to access the Supabase project
3. Check for any conflicts with existing data in your database
4. For Windows users, ensure PowerShell execution policy allows running scripts
