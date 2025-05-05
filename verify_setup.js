/**
 * SwiftPass Database Setup Verification
 *
 * This script connects to Supabase and verifies that the database setup
 * is working correctly by checking tables, admin account, and course data.
 */

// Import the Supabase client
const { createClient } = require("@supabase/supabase-js");

// Configure Supabase connection
const supabaseUrl =
  process.env.SUPABASE_URL || "https://gvmrqjyyeruszhlddprq.supabase.co";
const supabaseKey =
  process.env.SUPABASE_KEY ||
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd2bXJxanl5ZXJ1c3pobGRkcHJxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU4MDczMzUsImV4cCI6MjA2MTM4MzMzNX0.WM2wftomZif174G4CrfSu6gd-GoGuU55LTiLEf9jwdw";
const supabase = createClient(supabaseUrl, supabaseKey);

// Terminal color codes for better output
const colors = {
  reset: "\x1b[0m",
  green: "\x1b[32m",
  red: "\x1b[31m",
  yellow: "\x1b[33m",
  blue: "\x1b[34m",
  cyan: "\x1b[36m",
};

/**
 * Log a message with color
 */
function log(message, color = colors.reset) {
  console.log(`${color}${message}${colors.reset}`);
}

/**
 * Verify a specific table exists and has data
 */
async function verifyTable(tableName, expectedMinimumRows = 1) {
  try {
    const { data, error, count } = await supabase
      .from(tableName)
      .select("*", { count: "exact" })
      .limit(1);

    if (error) throw new Error(`Error querying ${tableName}: ${error.message}`);

    if (count === null || count < expectedMinimumRows) {
      log(
        `❌ Table ${tableName} exists but has insufficient data (${
          count || 0
        } rows, expected ${expectedMinimumRows})`,
        colors.yellow
      );
      return false;
    }

    log(`✅ Table ${tableName} verified with ${count} rows`, colors.green);
    return true;
  } catch (err) {
    log(`❌ Failed to verify table ${tableName}: ${err.message}`, colors.red);
    return false;
  }
}

/**
 * Verify admin account exists
 */
async function verifyAdminAccount() {
  try {
    const { data, error } = await supabase
      .from("admins")
      .select("*")
      .eq("email", "admin@swiftpass.edu")
      .single();

    if (error)
      throw new Error(`Error querying admin account: ${error.message}`);

    if (!data) {
      log("❌ Admin account not found", colors.red);
      return false;
    }

    log(
      `✅ Admin account verified: ${data.email} (${data.role})`,
      colors.green
    );
    return true;
  } catch (err) {
    log(`❌ Failed to verify admin account: ${err.message}`, colors.red);
    return false;
  }
}

/**
 * Verify courses exist
 */
async function verifyCourses() {
  try {
    const { data, error } = await supabase.from("subjects").select("*");

    if (error) throw new Error(`Error querying subjects: ${error.message}`);

    if (!data || data.length < 2) {
      log(
        `❌ Expected at least 2 courses, found ${data?.length || 0}`,
        colors.yellow
      );
      return false;
    }

    const courses = data.map((c) => `${c.code} (${c.name})`).join(", ");
    log(`✅ Courses verified: ${courses}`, colors.green);
    return true;
  } catch (err) {
    log(`❌ Failed to verify courses: ${err.message}`, colors.red);
    return false;
  }
}

/**
 * Verify lab sections
 */
async function verifyLabSections() {
  try {
    const { data, error } = await supabase
      .from("labs")
      .select("section")
      .order("section");

    if (error) throw new Error(`Error querying lab sections: ${error.message}`);

    if (!data || data.length < 3) {
      log(
        `❌ Expected at least 3 lab sections, found ${data?.length || 0}`,
        colors.yellow
      );
      return false;
    }

    // Get unique sections
    const sections = [...new Set(data.map((l) => l.section))];
    log(`✅ Lab sections verified: ${sections.join(", ")}`, colors.green);
    return true;
  } catch (err) {
    log(`❌ Failed to verify lab sections: ${err.message}`, colors.red);
    return false;
  }
}

/**
 * Run all verifications
 */
async function runVerification() {
  log("\n🔍 SwiftPass Database Verification", colors.cyan);
  log("==============================\n", colors.cyan);

  let success = true;

  log("Checking database tables...", colors.blue);
  success = (await verifyTable("students", 0)) && success;
  success = (await verifyTable("admins", 1)) && success;
  success = (await verifyTable("subjects", 2)) && success;
  success = (await verifyTable("labs", 6)) && success;

  log("\nChecking admin account...", colors.blue);
  success = (await verifyAdminAccount()) && success;

  log("\nChecking courses and sections...", colors.blue);
  success = (await verifyCourses()) && success;
  success = (await verifyLabSections()) && success;

  log("\n==============================", colors.cyan);
  if (success) {
    log("✅ Database verification PASSED!", colors.green);
    log("The database is set up correctly and ready to use.", colors.green);
  } else {
    log("⚠️ Database verification FAILED!", colors.red);
    log(
      "Please check the errors above and run the setup scripts again.",
      colors.red
    );
  }
  log("==============================\n", colors.cyan);

  return success;
}

// Run the verification
runVerification()
  .then((success) => {
    process.exit(success ? 0 : 1);
  })
  .catch((err) => {
    log(`\n❌ Fatal error: ${err.message}`, colors.red);
    process.exit(1);
  });
