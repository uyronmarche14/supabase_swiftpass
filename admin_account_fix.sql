-- Create admin account (admin@swiftpass.edu / Admin123!)
-- WARNING: This script contains hard-coded credentials for demonstration purposes only.
-- In a production environment, you should use more secure methods.

-- First, delete any existing admin account with this email if it exists
DELETE FROM auth.users WHERE email = 'admin@swiftpass.edu';
DELETE FROM admins WHERE email = 'admin@swiftpass.edu';

-- Sign up the admin account using Supabase's auth.sign_up function
SELECT
  auth.sign_up(
    'admin@swiftpass.edu',
    'Admin123!',
    NULL,
    jsonb_build_object(
      'full_name', 'System Administrator',
      'role', 'super_admin'
    )
  );

-- Since the signup process is asynchronous, we need to:
-- 1. Get the user ID
-- 2. Confirm their email (skip email verification)
-- 3. Add them to the admins table

-- Get the user ID of the admin
DO $$
DECLARE
  admin_id UUID;
BEGIN
  -- Get the admin user ID
  SELECT id INTO admin_id FROM auth.users WHERE email = 'admin@swiftpass.edu';

  -- Confirm the admin's email (skip email verification)
  UPDATE auth.users 
  SET email_confirmed_at = NOW(),
      confirmed_at = NOW(),
      is_confirmed = TRUE
  WHERE id = admin_id;
  
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

-- Display the result
SELECT email, confirmed_at, is_confirmed, id 
FROM auth.users 
WHERE email = 'admin@swiftpass.edu'; 