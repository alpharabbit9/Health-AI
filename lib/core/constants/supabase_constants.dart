import '../config/env.dart';

class SupabaseConstants {
  SupabaseConstants._();

  // ─── Credentials (loaded from .env) ──────────────────
  static String get supabaseUrl => Env.supabaseUrl;
  static String get supabaseAnonKey => Env.supabaseAnonKey;

  // ─── Tables ──────────────────────────────────────────
  static const String usersTable = 'users';
  static const String profilesTable = 'profiles';
  static const String healthRecordsTable = 'health_records';
  static const String symptomAnalysesTable = 'symptom_analyses';
  static const String symptomsTable = 'symptoms';
  static const String doctorsTable = 'doctors';

  // ─── Storage Buckets ─────────────────────────────────
  static const String avatarsBucket = 'avatars';
  static const String documentsBucket = 'health_documents';

  // ─── Auth Deep Link ──────────────────────────────────
  static const String redirectUrl = 'io.healthai.app://auth-callback';

  // ─── Auth Providers ──────────────────────────────────
  static const String googleProvider = 'google';
  static const String appleProvider = 'apple';
}
