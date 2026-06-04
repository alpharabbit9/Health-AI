import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/supabase_constants.dart';

abstract class AdminDatasource {
  Future<Map<String, dynamic>> fetchStats();
  Future<List<Map<String, dynamic>>> fetchUsers({String? search});
  Future<void> updateUserRole(String userId, String role);
  Future<void> updateUserStatus(String userId, String status);
  Future<void> deleteUser(String userId);
  Future<List<Map<String, dynamic>>> fetchAnalyses({String? filter});
  Future<List<Map<String, dynamic>>> fetchDoctors();
  Future<void> createDoctor(Map<String, dynamic> data);
  Future<void> updateDoctor(String id, Map<String, dynamic> data);
  Future<void> deleteDoctor(String id);
  Future<List<Map<String, dynamic>>> fetchHealthTips();
  Future<void> createHealthTip(Map<String, dynamic> data);
  Future<void> updateHealthTip(String id, Map<String, dynamic> data);
  Future<void> deleteHealthTip(String id);
  Future<List<Map<String, dynamic>>> fetchFeedback();
  Future<void> markFeedbackResolved(String id);
  Future<void> deleteFeedback(String id);
  Future<void> submitFeedback(Map<String, dynamic> data);
}

class AdminDatasourceImpl implements AdminDatasource {
  final SupabaseClient _client;

  const AdminDatasourceImpl(this._client);

  // ── Stats ────────────────────────────────────────────────────
  @override
  Future<Map<String, dynamic>> fetchStats() async {
    final weekAgo =
        DateTime.now().subtract(const Duration(days: 7)).toIso8601String();

    // Fetch each count by selecting minimal columns; count list length in Dart.
    final results = await Future.wait([
      _client.from(SupabaseConstants.usersTable).select('id'),
      _client.from(SupabaseConstants.symptomAnalysesTable).select('id'),
      _client.from(SupabaseConstants.doctorsTable).select('id'),
      _client.from(SupabaseConstants.healthTipsTable).select('id'),
      _client
          .from(SupabaseConstants.usersTable)
          .select('id')
          .gte('created_at', weekAgo),
      _client
          .from(SupabaseConstants.symptomAnalysesTable)
          .select('risk_level'),
    ]);

    final riskRows = results[5] as List<dynamic>;
    int low = 0, moderate = 0, high = 0;
    for (final row in riskRows) {
      final level =
          ((row as Map<String, dynamic>)['risk_level'] as String? ?? '')
              .toLowerCase();
      if (level.contains('low')) {
        low++;
      } else if (level.contains('moderate') || level.contains('medium')) {
        moderate++;
      } else if (level.contains('high')) {
        high++;
      }
    }

    return {
      'total_users': (results[0] as List).length,
      'total_analyses': (results[1] as List).length,
      'total_doctors': (results[2] as List).length,
      'total_health_tips': (results[3] as List).length,
      'new_users_this_week': (results[4] as List).length,
      'low_risk': low,
      'moderate_risk': moderate,
      'high_risk': high,
    };
  }

  // ── Users ────────────────────────────────────────────────────
  @override
  Future<List<Map<String, dynamic>>> fetchUsers({String? search}) async {
    final base = _client
        .from(SupabaseConstants.usersTable)
        .select('id, email, full_name, role, status, created_at');

    final List rows;
    if (search != null && search.isNotEmpty) {
      rows = await base
          .or('email.ilike.%$search%,full_name.ilike.%$search%')
          .order('created_at', ascending: false);
    } else {
      rows = await base.order('created_at', ascending: false);
    }

    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  Future<void> updateUserRole(String userId, String role) async {
    await _client
        .from(SupabaseConstants.usersTable)
        .update({'role': role}).eq('id', userId);
  }

  @override
  Future<void> updateUserStatus(String userId, String status) async {
    await _client
        .from(SupabaseConstants.usersTable)
        .update({'status': status}).eq('id', userId);
  }

  @override
  Future<void> deleteUser(String userId) async {
    await _client
        .from(SupabaseConstants.usersTable)
        .delete()
        .eq('id', userId);
  }

  // ── Analyses ─────────────────────────────────────────────────
  @override
  Future<List<Map<String, dynamic>>> fetchAnalyses({String? filter}) async {
    final now = DateTime.now();
    final base = _client
        .from(SupabaseConstants.symptomAnalysesTable)
        .select('id, user_id, symptoms, risk_level, severity, created_at, '
            'users(full_name, email)');

    final List rows;
    if (filter == 'today') {
      final start = DateTime(now.year, now.month, now.day).toIso8601String();
      rows = await base
          .gte('created_at', start)
          .order('created_at', ascending: false)
          .limit(200);
    } else if (filter == 'week') {
      final start = now.subtract(const Duration(days: 7)).toIso8601String();
      rows = await base
          .gte('created_at', start)
          .order('created_at', ascending: false)
          .limit(200);
    } else if (filter == 'month') {
      final start = now.subtract(const Duration(days: 30)).toIso8601String();
      rows = await base
          .gte('created_at', start)
          .order('created_at', ascending: false)
          .limit(200);
    } else {
      rows = await base.order('created_at', ascending: false).limit(200);
    }

    return List<Map<String, dynamic>>.from(rows);
  }

  // ── Doctors ──────────────────────────────────────────────────
  @override
  Future<List<Map<String, dynamic>>> fetchDoctors() async {
    final rows = await _client
        .from(SupabaseConstants.doctorsTable)
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  Future<void> createDoctor(Map<String, dynamic> data) async {
    await _client.from(SupabaseConstants.doctorsTable).insert(data);
  }

  @override
  Future<void> updateDoctor(String id, Map<String, dynamic> data) async {
    await _client
        .from(SupabaseConstants.doctorsTable)
        .update({...data, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }

  @override
  Future<void> deleteDoctor(String id) async {
    await _client
        .from(SupabaseConstants.doctorsTable)
        .delete()
        .eq('id', id);
  }

  // ── Health Tips ───────────────────────────────────────────────
  @override
  Future<List<Map<String, dynamic>>> fetchHealthTips() async {
    final rows = await _client
        .from(SupabaseConstants.healthTipsTable)
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  Future<void> createHealthTip(Map<String, dynamic> data) async {
    await _client.from(SupabaseConstants.healthTipsTable).insert(data);
  }

  @override
  Future<void> updateHealthTip(String id, Map<String, dynamic> data) async {
    await _client
        .from(SupabaseConstants.healthTipsTable)
        .update({...data, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }

  @override
  Future<void> deleteHealthTip(String id) async {
    await _client
        .from(SupabaseConstants.healthTipsTable)
        .delete()
        .eq('id', id);
  }

  // ── Feedback ─────────────────────────────────────────────────
  @override
  Future<List<Map<String, dynamic>>> fetchFeedback() async {
    try {
      final rows = await _client
          .from(SupabaseConstants.feedbackTable)
          .select('*, users(full_name, email)')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      debugPrint('[ADMIN] fetchFeedback join failed, falling back: $e');
      final rows = await _client
          .from(SupabaseConstants.feedbackTable)
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(rows);
    }
  }

  @override
  Future<void> markFeedbackResolved(String id) async {
    await _client
        .from(SupabaseConstants.feedbackTable)
        .update({'status': 'resolved'}).eq('id', id);
  }

  @override
  Future<void> deleteFeedback(String id) async {
    await _client
        .from(SupabaseConstants.feedbackTable)
        .delete()
        .eq('id', id);
  }

  @override
  Future<void> submitFeedback(Map<String, dynamic> data) async {
    await _client.from(SupabaseConstants.feedbackTable).insert(data);
  }
}
