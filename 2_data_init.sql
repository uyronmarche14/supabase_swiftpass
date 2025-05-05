-- SwiftPass Data Initialization
-- This file should be run after 1_schema.sql
-- It loads initial data including admin account and standard courses/sections

-- =================== ADMIN ACCOUNT SETUP ===================

-- Create admin account (admin@swiftpass.edu / Admin123!)
-- WARNING: This script contains hard-coded credentials for demonstration purposes only.
-- In a production environment, you should use more secure methods.

-- First, delete any existing admin account with this email if it exists
DO $$
BEGIN
  -- Delete from admins table first to maintain foreign key integrity
  DELETE FROM admins WHERE email = 'admin@swiftpass.edu';
  
  -- Get the user ID of any existing admin user with this email
  DECLARE admin_user_id UUID;
  BEGIN
    SELECT id INTO admin_user_id FROM auth.users WHERE email = 'admin@swiftpass.edu';
    IF admin_user_id IS NOT NULL THEN
      -- Delete from auth.users if found
      DELETE FROM auth.users WHERE id = admin_user_id;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    -- Ignore errors if the user doesn't exist
    RAISE NOTICE 'No existing admin user found with this email';
  END;
END
$$;

-- Create admin user directly in auth.users table
DO $$
DECLARE
  admin_id UUID := gen_random_uuid();
BEGIN
  -- Insert directly into auth.users table with minimal required fields
  INSERT INTO auth.users (
    id,
    email,
    raw_user_meta_data,
    created_at
  ) VALUES (
    admin_id,
    'admin@swiftpass.edu',
    jsonb_build_object(
      'full_name', 'System Administrator',
      'role', 'super_admin'
    ),
    NOW()
  );

  -- Set password directly in auth.users table
  -- Use proper authentication methods in production
  UPDATE auth.users 
  SET encrypted_password = crypt('Admin123!', gen_salt('bf'))
  WHERE id = admin_id;
  
  -- Confirm user email if email_confirmed_at column exists
  BEGIN
    UPDATE auth.users 
    SET email_confirmed_at = NOW()
    WHERE id = admin_id;
  EXCEPTION WHEN undefined_column THEN
    RAISE NOTICE 'Column email_confirmed_at not found, skipping email confirmation';
  END;
  
  -- Add admin to the admins table
  INSERT INTO admins (id, email, full_name, role, created_at, updated_at)
  VALUES (
    admin_id,
    'admin@swiftpass.edu',
    'System Administrator',
    'super_admin',
    NOW(),
    NOW()
  ) ON CONFLICT (id) DO NOTHING;
  
  RAISE NOTICE 'Created admin account with ID: %', admin_id;
END $$;

-- =================== COURSE AND SECTION DATA ===================

-- Seed subjects (courses) with proper codes and full names
INSERT INTO subjects (name, code, description)
VALUES 
    ('Bachelor of Science in Information Technology', 'BSIT', 'A program that focuses on the design of technological information systems, including computing systems, as solutions for business and research data and communications support needs.'),
    ('Bachelor of Science in Computer Science', 'BSCS', 'A program that focuses on computer theory, computing problems and solutions, and the design of computer systems and user interfaces from a scientific perspective.')
ON CONFLICT (code) DO UPDATE SET 
    name = EXCLUDED.name,
    description = EXCLUDED.description;

-- Create labs with specific sections
INSERT INTO labs (name, section, day_of_week, start_time, end_time, subject_id)
SELECT
    'Programming Laboratory', 
    'A2021',
    'Monday',
    '09:00',
    '11:00',
    id
FROM subjects WHERE code = 'BSIT'
ON CONFLICT DO NOTHING;

INSERT INTO labs (name, section, day_of_week, start_time, end_time, subject_id)
SELECT
    'Programming Laboratory', 
    'B2021',
    'Tuesday',
    '13:00',
    '15:00',
    id
FROM subjects WHERE code = 'BSIT'
ON CONFLICT DO NOTHING;

INSERT INTO labs (name, section, day_of_week, start_time, end_time, subject_id)
SELECT
    'Programming Laboratory', 
    'C2021',
    'Wednesday',
    '10:00',
    '12:00',
    id
FROM subjects WHERE code = 'BSIT'
ON CONFLICT DO NOTHING;

INSERT INTO labs (name, section, day_of_week, start_time, end_time, subject_id)
SELECT
    'Database Laboratory', 
    'A2021',
    'Thursday',
    '09:00',
    '11:00',
    id
FROM subjects WHERE code = 'BSCS'
ON CONFLICT DO NOTHING;

INSERT INTO labs (name, section, day_of_week, start_time, end_time, subject_id)
SELECT
    'Database Laboratory', 
    'B2021',
    'Friday',
    '13:00',
    '15:00',
    id
FROM subjects WHERE code = 'BSCS'
ON CONFLICT DO NOTHING;

INSERT INTO labs (name, section, day_of_week, start_time, end_time, subject_id)
SELECT
    'Database Laboratory', 
    'C2021',
    'Thursday',
    '15:00',
    '17:00',
    id
FROM subjects WHERE code = 'BSCS'
ON CONFLICT DO NOTHING;

-- Display summary of created data
DO $$
BEGIN
  RAISE NOTICE 'Data initialization complete:';
  RAISE NOTICE '- Admin account created: admin@swiftpass.edu';
  RAISE NOTICE '- Courses created: BSIT, BSCS';
  RAISE NOTICE '- Sections created: A2021, B2021, C2021';
  RAISE NOTICE '- Lab sessions created for each course and section';
END $$; 