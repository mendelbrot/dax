# OTP Authentication Setup Guide

This guide documents the email OTP (One-Time Password) authentication setup for the DAX app.

## Overview

The app uses invite-only email OTP authentication. Users must already exist in Supabase (created via admin) to sign in. New users cannot sign up themselves.

## Email Template Configuration

To ensure Supabase sends OTP codes instead of magic links, you must configure the email template in the Supabase Dashboard.

### Steps

1. Go to your Supabase Dashboard → **Authentication** → **Email Templates**
2. Find the **Magic Link** template (or the template used for sign-in)
3. Edit the template to use the following:

**Subject:** `Your Sign-In Code for Dax`

**Body:**
```html
<h2>Dax</h2>
<h3 style="font-size: 32px; letter-spacing: 8px;">{{ .Token }}</h3>
```

### Important Notes

- **`{{ .Token }}`** - This variable displays the 6-digit OTP code. Including this in the template tells Supabase to send an OTP code.
- **`{{ .ConfirmationURL }}`** - If this variable is present in the template, Supabase will send a magic link instead. Make sure this is NOT in your template.
- The token is a 6-digit numeric code (e.g., `123456`)
- The token expires after 1 hour (configured in `supabase/config.toml` as `otp_expiry = 3600`)

## Dashboard Configuration

1. **Enable Email Provider:**
   - Go to **Authentication** → **Providers**
   - Enable the **Email** provider
   - Disable **Enable email signup** (app is invite-only)

2. **Site URL:**
   - The Site URL setting can affect whether magic links or OTP codes are sent
   - If you're using OTP codes, you can leave the Site URL as-is or clear it

## Authentication Flow

1. User enters their email address
2. User clicks "Send Code"
3. Supabase sends an email with a 6-digit OTP code
4. User enters the code in the app
5. User clicks "Verify Code"
6. Upon successful verification, user is authenticated and sees the home screen

## Testing

- Test with invited user email addresses (users must exist in Supabase)
- Test with non-invited email addresses (should show "User not found" error)
- Test OTP code entry (correct and incorrect codes)
- Test app restart to verify session persistence

## Code Implementation

The Flutter app uses:
- `signInWithOtp()` - Sends the OTP code to the user's email
- `verifyOTP()` - Verifies the entered code and authenticates the user

See `client-flutter/lib/providers/auth_provider.dart` for the implementation.
