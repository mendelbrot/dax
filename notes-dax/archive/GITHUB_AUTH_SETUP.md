# GitHub Authentication Setup Guide

This guide will help you set up GitHub OAuth authentication for your Flutter app with Supabase.

## Prerequisites

1. A GitHub account
2. Supabase CLI installed and running locally (`supabase start`)

## Step 1: Create a GitHub OAuth App

1. Go to GitHub Settings → Developer settings → OAuth Apps
   - Direct link: https://github.com/settings/developers

2. Click "New OAuth App"

3. Fill in the application details:
   - **Application name**: `DAX App` (or your preferred name)
   - **Homepage URL**: `http://127.0.0.1:3000` (or your app URL)
   - **Authorization callback URL**: `http://127.0.0.1:54321/auth/v1/callback`
     - This is your local Supabase Auth callback URL
     - Format: `{SUPABASE_URL}/auth/v1/callback`
     - For local: `http://127.0.0.1:54321/auth/v1/callback`
     - For production: `https://{your-project-ref}.supabase.co/auth/v1/callback`

4. Click "Register application"

5. Copy the **Client ID** and generate a **Client Secret**

## Step 2: Configure Supabase with GitHub Credentials

1. Set environment variables for your GitHub OAuth credentials:

   ```bash
   export SUPABASE_AUTH_EXTERNAL_GITHUB_CLIENT_ID="your-github-client-id"
   export SUPABASE_AUTH_EXTERNAL_GITHUB_SECRET="your-github-client-secret"
   ```

2. Restart Supabase to load the new environment variables:

   ```bash
   cd /home/greg/repos/dax/supabase
   supabase stop
   supabase start
   ```

   Or if Supabase is already running, you may need to restart it:

   ```bash
   supabase stop && supabase start
   ```

## Step 3: Verify Configuration

1. Check that GitHub OAuth is enabled in `supabase/config.toml`:
   ```toml
   [auth.external.github]
   enabled = true
   ```

2. Verify your Supabase instance is running:
   ```bash
   supabase status
   ```

3. You should see the API URL: `http://127.0.0.1:54321`

## Step 4: Test the Authentication Flow

1. Run your Flutter app:
   ```bash
   cd /home/greg/repos/dax/client-flutter
   flutter run
   ```

2. Click "Sign in with GitHub" button

3. You should be redirected to GitHub for authorization

4. After authorizing, you'll be redirected back to the app

## Troubleshooting

### Issue: "Invalid redirect URI" error

- Make sure the callback URL in your GitHub OAuth app matches exactly:
  - Local: `http://127.0.0.1:54321/auth/v1/callback`
  - The redirect URL in the Flutter app (`com.example.dax://login-callback`) is different - that's for the mobile app deep link

### Issue: Environment variables not loading

- Make sure you've exported the variables in the same terminal session where you run `supabase start`
- Or create a `.env` file in the supabase directory (if supported by your Supabase CLI version)

### Issue: Deep link not working on mobile

- For Android: Verify the intent filter in `android/app/src/main/AndroidManifest.xml`
- For iOS: Verify the URL scheme in `ios/Runner/Info.plist`
- Make sure the redirect URL in `auth_screen.dart` matches: `com.example.dax://login-callback`

## Production Setup

When deploying to production:

1. Update the GitHub OAuth App callback URL to your production Supabase URL
2. Update `supabase_config.dart` with your production Supabase URL and anon key
3. Set environment variables on your production server/hosting platform
4. Update the redirect URL in the Flutter app if needed

## Additional Resources

- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [GitHub OAuth Apps Documentation](https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/creating-an-oauth-app)
- [Supabase Flutter SDK](https://supabase.com/docs/reference/dart/introduction)
