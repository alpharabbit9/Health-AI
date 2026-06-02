# Debug Logging for Login Errors

## Changes Made

I've added comprehensive debug logging throughout the authentication flow to help identify the exact error:

### 1. **AuthNotifier (auth_provider.dart)**
```dart
debugPrint('[AUTH ERROR] Sign in failed: $e');
debugPrint('[AUTH ERROR] Error type: ${e.runtimeType}');
```
- Logs when sign in fails and the error type

### 2. **AuthRemoteDatasourceImpl (auth_remote_datasource.dart)**
```dart
debugPrint('[DATASOURCE] Sign in successful for $email');
debugPrint('[DATASOURCE] Profile not found, upserting for user ${user.id}');
debugPrint('[DATASOURCE] Sign in error: $e');
```
- Logs each step of the sign in process
- Shows where exactly it's failing

### 3. **UserProfileDatasourceImpl (user_profile_datasource.dart)**
```dart
debugPrint('[PROFILE] Fetching profile for user: $userId');
debugPrint('[PROFILE] Profile fetched: found/not found');
debugPrint('[PROFILE] Error fetching profile: $e');
```
- Shows profile database operations

### 4. **Error Parser (_parseError method)**
- Enhanced with more specific error types and conditions
- Returns better error messages

## How to Debug

### Step 1: Try to Login
1. Open the app in Chrome browser
2. Press F12 to open Developer Tools
3. Click **Console** tab
4. Try to login with an existing email/password

### Step 2: Check Console Output
Look for logs that start with:
- `[AUTH ERROR]` - Auth provider layer
- `[DATASOURCE]` - Sign in/up layer
- `[PROFILE]` - Database profile operations
- `[AUTH PARSER]` - Error parsing

### Example Debug Output

**Successful Flow:**
```
[DATASOURCE] Attempting signup for email: test@example.com
[DATASOURCE] Auth user created: abc123...
[PROFILE] Creating profile for user: abc123...
[DATASOURCE] Profile created successfully
```

**With Error:**
```
[DATASOURCE] Sign in successful for test@example.com
[PROFILE] Fetching profile for user: abc123...
[PROFILE] Error fetching profile: <actual error message>
[AUTH ERROR] Sign in failed: <full error>
[AUTH ERROR] Error type: PostgrestException
[AUTH PARSER] Parsing error: <error details>
```

## Common Issues & Solutions

### Issue 1: "Permission denied" / RLS Violation
```
[PROFILE] Error fetching profile: PostgrestException: 42501 
```
**Solution:** Your Supabase RLS policies might be blocking user access to the users table.

**Fix:** Check your `users` table RLS policies. You need:
- Enable RLS
- Add policy to allow authenticated users to read/update their own row

```sql
-- READ policy
CREATE POLICY "Users can read own profile"
ON public.users FOR SELECT
USING (auth.uid() = id);

-- UPDATE policy  
CREATE POLICY "Users can update own profile"
ON public.users FOR UPDATE
USING (auth.uid() = id);
```

### Issue 2: "Email not confirmed"
```
[AUTH ERROR] Sign in failed: AuthException: Invalid login credentials or email not confirmed
```
**Solution:** Email verification is required. User must verify email before signing in.

### Issue 3: "Table does not exist"
```
[PROFILE] Error fetching profile: PostgrestException: 42P01
```
**Solution:** The `users` table doesn't exist in Supabase.

**Fix:** 
1. Go to Supabase Dashboard
2. Create table `users` with columns:
   - `id` (UUID, primary key)
   - `email` (text, unique)
   - `full_name` (text, nullable)
   - `age` (bigint, nullable)
   - `gender` (text, nullable)
   - `avatar_url` (text, nullable)
   - `created_at` (timestamp)

### Issue 4: "Row level security" error  
```
[PROFILE] Error fetching profile: PostgrestException: 42501
```
**Solution:** RLS policies are too restrictive or not set correctly.

## Next Steps

1. **Try Login and Report:**
   - Attempt to login
   - Take a screenshot of the Console tab logs
   - Share what the `[AUTH ERROR]`, `[PROFILE]`, and `[AUTH PARSER]` logs show

2. **Check Supabase:**
   - Verify the `users` table exists
   - Check RLS policies are enabled and correct
   - Confirm email verification is working

3. **Verify Email:**
   - After signing up, check email for verification link
   - Click the link to verify
   - Then try signing in

## File Changes Summary

- `lib/features/auth/presentation/providers/auth_provider.dart` - Added debugPrint import and logs
- `lib/features/auth/data/datasources/auth_remote_datasource.dart` - Added comprehensive datasource logging
- `lib/features/auth/data/datasources/user_profile_datasource.dart` - Added profile operation logging

All logging is production-safe and will be removed in release builds automatically by Flutter.
