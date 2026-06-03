import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();

  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? '';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static String get groqApiKey =>
      dotenv.env['GROQ_API_KEY'] ?? '';

  static bool get hasGroqKey =>
      groqApiKey.isNotEmpty && groqApiKey != 'your_groq_api_key_here';
}
