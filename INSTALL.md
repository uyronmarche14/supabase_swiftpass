# SwiftPass QR Attendance System - Installation Guide

This guide will help you set up the entire QR-based attendance system, including the backend server and frontend mobile app.

## Prerequisites

- Node.js v16 or higher
- npm or yarn
- Supabase account (free tier works)
- Expo Go app (for mobile testing)

## Backend Setup

1. **Install backend dependencies**

```bash
cd supabase_backend
npm install
```

2. **Create `.env` file**

Create a `.env` file in the `supabase_backend` directory with the following contents:

```
# Supabase Configuration
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key

# Server Configuration
PORT=5000
NODE_ENV=development

# JWT Configuration
JWT_SECRET=your_secure_random_string
```

Replace the placeholder values with your actual Supabase credentials.

3. **Set up Supabase tables**

- Log in to your Supabase dashboard
- Go to the SQL Editor
- Paste the contents of `supabase_tables.sql` and run the query

4. **Start the backend server**

```bash
npm run dev
```

The server should start on port 5000.

## Frontend Setup

1. **Install frontend dependencies**

```bash
cd swiftpass_v2
npm install
```

2. **Create `.env` file**

Create a `.env` file in the `swiftpass_v2` directory with the following contents:

```
# Supabase Configuration
EXPO_PUBLIC_SUPABASE_URL=your_supabase_url
EXPO_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key

# API Configuration (Android simulator needs 10.0.2.2 instead of localhost)
EXPO_PUBLIC_API_URL=http://localhost:5000/api
```

3. **Start the frontend app**

```bash
npm start
```

This will start the Expo development server.

## Troubleshooting

### Profile Creation Error

If you encounter a "Student profile creation error" when registering, check:

1. Ensure your Supabase tables are properly set up
2. Verify that your Supabase service role key has proper permissions
3. Check the console logs for more detailed error information

### Network Request Failed

If you see "Network request failed" errors:

1. Make sure your backend server is running
2. Check that your API URL is correct:
   - For Android emulators: `http://10.0.2.2:5000/api`
   - For iOS simulators or web: `http://localhost:5000/api`
   - For physical devices: Use your computer's local IP address

### Environment Variables Not Loading

If your environment variables aren't loading correctly:

1. Make sure to restart the server after changing `.env` files
2. For the Expo app, you may need to restart the Expo server with the `-c` flag to clear the cache:
   ```bash
   npm start -- -c
   ```

## Security Considerations

- The JWT_SECRET should be a strong, random string
- In production, set up HTTPS for both backend and frontend
- Review Supabase RLS (Row Level Security) policies
- Never commit `.env` files to version control

## Next Steps

After installation, you can:

1. Register a new student account
2. View your QR code on the dashboard
3. Set up a scanner application (not included) to scan the QR codes and record attendance

For any questions or issues, please refer to the project documentation or contact the development team.
