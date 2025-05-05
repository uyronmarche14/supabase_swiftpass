#!/bin/bash

# SwiftPass Database Setup Script
# This script runs the SQL setup files in the correct order

echo "SwiftPass Database Setup"
echo "========================"

# Check if we have access to the Supabase CLI
if ! command -v supabase &> /dev/null; then
    echo "Error: Supabase CLI not found. Please install it first."
    echo "Visit https://supabase.com/docs/guides/cli for installation instructions."
    exit 1
fi

# Set the variables for database connection
SUPABASE_URL=${SUPABASE_URL:-"https://gvmrqjyyeruszhlddprq.supabase.co"}
SUPABASE_KEY=${SUPABASE_KEY:-"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd2bXJxanl5ZXJ1c3pobGRkcHJxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU4MDczMzUsImV4cCI6MjA2MTM4MzMzNX0.WM2wftomZif174G4CrfSu6gd-GoGuU55LTiLEf9jwdw"}

# Directory where the SQL files are located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Step 1: Running schema setup (tables and policies)..."
supabase db execute --file "${SCRIPT_DIR}/1_schema.sql" || {
    echo "Error: Failed to run schema setup."
    exit 1
}
echo "Schema setup completed successfully."

echo "Step 2: Running data initialization (admin account, courses and sections)..."
supabase db execute --file "${SCRIPT_DIR}/2_data_init.sql" || {
    echo "Error: Failed to run data initialization."
    exit 1
}
echo "Data initialization completed successfully."

echo "========================"
echo "SwiftPass database setup completed!"
echo "You can now access the admin account with:"
echo "Email: admin@swiftpass.edu"
echo "Password: Admin123!"
echo "========================" 