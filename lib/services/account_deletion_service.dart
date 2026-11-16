import 'package:supabase_flutter/supabase_flutter.dart';

import 'connection_service.dart';

class AccountDeletionService {
  AccountDeletionService._();

  static final instance = AccountDeletionService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Usuwa konto użytkownika wraz z danymi.
  ///
  /// Najpierw wywołuje backend.
  /// Dane lokalne czyści dopiero po potwierdzeniu sukcesu.
  /// Na końcu wykonuje lokalne wylogowanie.
  Future<void> deleteAccount() async {
    final session = _supabase.auth.currentSession;

    if (session == null || session.accessToken.isEmpty) {
      throw Exception('No active user session.');
    }

    final response = await _supabase.functions.invoke(
      'delete-account',
      headers: {
        'Authorization': 'Bearer ${session.accessToken}',
      },
      method: HttpMethod.post,
    );

    final responseData = response.data;

    if (response.status < 200 || response.status >= 300) {
      throw Exception('Account deletion request failed.');
    }

    if (responseData is! Map ||
        responseData['success'] != true) {
      throw Exception(
        responseData is Map
            ? responseData['error']?.toString() ??
                'Account deletion failed.'
            : 'Invalid server response.',
      );
    }

    // Backend potwierdził usunięcie konta.
    // Czyścimy lokalne połączenia i zapisane klucze API.
    await ConnectionService.instance.clearAll();

    // Czyścimy lokalną sesję bez ponownego żądania
    // usunięcia użytkownika z serwera.
    await _supabase.auth.signOut(
      scope: SignOutScope.local,
    );
  }
}