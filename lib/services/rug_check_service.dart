import 'package:supabase_flutter/supabase_flutter.dart';

class RugCheckService {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  Future<Map<String, dynamic>> scanToken(
    String mint,
  ) async {
    final response =
        await _supabase.functions.invoke(
      'rug-check',
      body: {
        'mint': mint.trim(),
      },
    );

    final data = response.data;

    if (data is! Map) {
      throw Exception(
        'Invalid Rug Check response.',
      );
    }

    final result =
        Map<String, dynamic>.from(data);

    if (result['success'] != true) {
      throw Exception(
        result['error']?.toString() ??
            'Unable to analyze token.',
      );
    }

    return result;
  }
}