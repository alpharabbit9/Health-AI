class SupabaseConstants {
  SupabaseConstants._();

  // ─── Credentials ─────────────────────────────────────
  // Replace with your Supabase project credentials from supabase.com/dashboard
  static const String supabaseUrl = 'https://ajilehorjyccyzzyjown.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_T8BVbmiZb6IO6t1WX16dhQ_T4YNrofk';

  // ─── Tables ──────────────────────────────────────────
  static const String usersTable = 'users';
  static const String profilesTable = 'profiles';
  static const String healthRecordsTable = 'health_records';
  static const String symptomsTable = 'symptoms';
  static const String doctorsTable = 'doctors';

  // ─── Storage Buckets ─────────────────────────────────
  static const String avatarsBucket = 'avatars';
  static const String documentsBucket = 'health_documents';

  // ─── Auth Deep Link ──────────────────────────────────
  // Configure this in your Supabase Dashboard → Authentication → URL Configuration
  static const String redirectUrl = 'io.healthai.app://auth-callback';

  // ─── Auth Providers ──────────────────────────────────
  static const String googleProvider = 'google';
  static const String appleProvider = 'apple';
}
