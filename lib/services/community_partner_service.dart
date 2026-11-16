import 'package:supabase_flutter/supabase_flutter.dart';

class CommunityPartnerService {
  static final CommunityPartnerService instance =
      CommunityPartnerService._internal();

  CommunityPartnerService._internal();

  final SupabaseClient _supabase =
      Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getActivePartners() async {
    final response = await _supabase
        .from('community_partners')
        .select()
        .eq('is_active', true)
        .order('sort_order', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }
}