# SwiftPass Database Setup Script (PowerShell version)
# This script runs the SQL setup files in the correct order

Write-Host "SwiftPass Database Setup" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green

# Check if we have access to the Supabase CLI
try {
    $null = Get-Command supabase -ErrorAction Stop
}
catch {
    Write-Host "Error: Supabase CLI not found. Please install it first." -ForegroundColor Red
    Write-Host "Visit https://supabase.com/docs/guides/cli for installation instructions."
    exit 1
}

# Set the variables for database connection
$SUPABASE_URL = if ($env:SUPABASE_URL) { $env:SUPABASE_URL } else { "https://gvmrqjyyeruszhlddprq.supabase.co" }
$SUPABASE_KEY = if ($env:SUPABASE_KEY) { $env:SUPABASE_KEY } else { "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd2bXJxanl5ZXJ1c3pobGRkcHJxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU4MDczMzUsImV4cCI6MjA2MTM4MzMzNX0.WM2wftomZif174G4CrfSu6gd-GoGuU55LTiLEf9jwdw" }

# Directory where the SQL files are located
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "Step 1: Running schema setup (tables and policies)..." -ForegroundColor Cyan
try {
    supabase db execute --file "$SCRIPT_DIR\1_schema.sql"
    if ($LASTEXITCODE -ne 0) { throw "Error running schema setup" }
    Write-Host "Schema setup completed successfully." -ForegroundColor Green
}
catch {
    Write-Host "Error: Failed to run schema setup." -ForegroundColor Red
    Write-Host $_.Exception.Message
    exit 1
}

Write-Host "Step 2: Running data initialization (admin account, courses and sections)..." -ForegroundColor Cyan
try {
    supabase db execute --file "$SCRIPT_DIR\2_data_init.sql"
    if ($LASTEXITCODE -ne 0) { throw "Error running data initialization" }
    Write-Host "Data initialization completed successfully." -ForegroundColor Green
}
catch {
    Write-Host "Error: Failed to run data initialization." -ForegroundColor Red
    Write-Host $_.Exception.Message
    exit 1
}

Write-Host "========================" -ForegroundColor Green
Write-Host "SwiftPass database setup completed!" -ForegroundColor Green
Write-Host "You can now access the admin account with:" -ForegroundColor Cyan
Write-Host "Email: admin@swiftpass.edu" -ForegroundColor Yellow
Write-Host "Password: Admin123!" -ForegroundColor Yellow
Write-Host "========================" -ForegroundColor Green 