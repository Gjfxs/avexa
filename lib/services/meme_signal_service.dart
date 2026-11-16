import 'dart:async';
import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/meme_signal.dart';
import 'supabase_service.dart';

class MemeSignalService {
  MemeSignalService._();

  static final MemeSignalService instance =
      MemeSignalService._();

  static const String _freeFunctionName =
      'free-meme-engine';

  static const String _proFunctionName =
      'pro-meme-engine';

  static const int _freeDailyLimit = 3;

  static const Duration _freeScanTimeout =
      Duration(minutes: 5);

  static const Duration _freeScanInterval =
      Duration(seconds: 15);

  // PRO
  static const Duration _proScanTimeout =
      Duration(seconds: 45);

  static const Duration _proScanInterval =
      Duration(seconds: 15);

  // ===============================================================
  // ACTIVE SIGNALS
  // ===============================================================

  Future<List<MemeSignal>> getActiveSignals({
    required String tier,
    int limit = 5,
  }) async {
    final now =
        DateTime.now().toUtc().toIso8601String();

    final response =
        await SupabaseService.client
            .from('signals')
            .select()
            .eq('market', 'MEME')
            .eq('tier', tier)
            .eq('status', 'ACTIVE')
            .or(
              'expires_at.is.null,expires_at.gt.$now',
            )
            .order(
              'created_at',
              ascending: false,
            )
            .limit(limit);

    return (response as List)
        .map(
          (row) => MemeSignal.fromMap(
            Map<String, dynamic>.from(row),
          ),
        )
        .where(
          (signal) => !signal.isExpired,
        )
        .toList();
  }

  Future<Duration> getFreeCooldownRemaining() async {
    final now = DateTime.now().toUtc();

    final response = await SupabaseService.client
        .from('signals')
        .select('created_at')
        .eq('market', 'MEME')
        .eq('tier', 'FREE')
        .gte(
          'created_at',
          now.subtract(const Duration(hours: 24))
              .toIso8601String(),
        )
        .order('created_at', ascending: false)
        .limit(1);

    if ((response as List).isEmpty) {
      return Duration.zero;
    }

    final createdAt = DateTime.parse(
      response.first['created_at'].toString(),
    ).toUtc();

    final availableAt =
        createdAt.add(const Duration(hours: 3));

    final remaining = availableAt.difference(now);

    return remaining.isNegative
        ? Duration.zero
        : remaining;
  }

  // ===============================================================
  // FREE
  // ===============================================================

  Future<MemeSignal?> getLatestFreeSignal() async {
    final signals =
        await getActiveSignals(
      tier: 'FREE',
      limit: 1,
    );

    if (signals.isEmpty) {
      return null;
    }

    return signals.first;
  }

  // ===============================================================
  // FREE USAGE — ROLLING 24H
  // ===============================================================

  Future<int> getFreeSignalsUsed() async {
    final since = DateTime.now()
        .toUtc()
        .subtract(
          const Duration(hours: 24),
        )
        .toIso8601String();

    final response =
        await SupabaseService.client
            .from('signals')
            .select('id')
            .eq('market', 'MEME')
            .eq('tier', 'FREE')
            .gte(
              'created_at',
              since,
            );

    return (response as List).length;
  }

  // ===============================================================
  // REQUEST FREE SIGNAL
  // ===============================================================

  Future<MemeSignal?> requestFreeSignal({
    Duration timeout =
        _freeScanTimeout,
  }) async {
    final startedAt =
        DateTime.now().toUtc();

    final used =
        await getFreeSignalsUsed();

    if (used >= _freeDailyLimit) {
      throw const FreeSignalLimitException();
    }

    final existing =
        await getLatestFreeSignal();

    if (existing != null) {
      return existing;
    }

    while (
      DateTime.now()
              .toUtc()
              .difference(startedAt) <
          timeout
    ) {
      final currentUsed =
          await getFreeSignalsUsed();

      if (currentUsed >= _freeDailyLimit) {
        throw const FreeSignalLimitException();
      }

      final currentSignal =
          await getLatestFreeSignal();

      if (currentSignal != null) {
        return currentSignal;
      }

      try {
        final response =
            await SupabaseService.client
                .functions
                .invoke(
          _freeFunctionName,
          body: <String, dynamic>{},
        );

        final data = response.data;

        if (data is Map) {
          final created =
              data['created'] == true;

          if (created) {
            final createdSignal =
                await getLatestFreeSignal();

            if (createdSignal != null) {
              return createdSignal;
            }
          }

          final reason =
              data['reason']
                  ?.toString()
                  .toLowerCase();

          if (reason != null) {
            if (reason.contains('cooldown')) {
              throw const FreeSignalCooldownException();
            }

            if (reason.contains('no qualifying')) {
              break;
            }

            if (reason.contains('already used')) {
              break;
            }
          }
        }
      } on FunctionException catch (e) {
        final details =
            e.details?.toString() ?? '';

        final reason =
            e.reasonPhrase ?? '';

        final message =
            '$details $reason'.toLowerCase();

        if (message.contains('cooldown')) {
          throw const FreeSignalCooldownException();
        }

        log(
          'FREE ENGINE ATTEMPT ERROR: '
          '${e.status} '
          '${e.reasonPhrase ?? ''} '
          '${e.details ?? ''}',
        );
      } catch (e) {
        if (e is FreeSignalCooldownException ||
            e is FreeSignalLimitException) {
          rethrow;
        }

        _log(
          'FREE ENGINE ATTEMPT ERROR: $e',
        );
      }

      final latest =
          await getLatestFreeSignal();

      if (latest != null) {
        return latest;
      }

      final elapsed =
          DateTime.now()
              .toUtc()
              .difference(startedAt);

      final remaining =
          timeout - elapsed;

      if (remaining <= Duration.zero) {
        break;
      }

      final waitTime =
          remaining < _freeScanInterval
              ? remaining
              : _freeScanInterval;

      await Future.delayed(
        waitTime,
      );
    }

    return null;
  }

  // ===============================================================
  // PRO
  // ===============================================================

  Future<List<MemeSignal>> getProSignals() async {
    return getActiveSignals(
      tier: 'PRO',
      limit: 5,
    );
  }

  // ===============================================================
  // REQUEST PRO SIGNAL
  // ===============================================================

  Future<MemeSignal?> requestProSignal({
    Duration timeout = _proScanTimeout,
  }) async {
    final startedAt = DateTime.now().toUtc();

    while (
        DateTime.now()
                .toUtc()
                .difference(startedAt) <
            timeout) {
      final currentSignals = await getProSignals();

      // =============================================================
      // MAX 5 ACTIVE SIGNALS
      // =============================================================

      if (currentSignals.length >= 5) {
        return currentSignals.first;
      }

      // =============================================================
      // RUN PRO ENGINE
      // =============================================================

      try {
        final response =
            await SupabaseService.client
                .functions
                .invoke(
          _proFunctionName,
          body: <String, dynamic>{},
        );

        final data = response.data;

        if (data is Map) {
          final created = data['created'] == true;

          if (created) {
            final updatedSignals =
                await getProSignals();

            if (updatedSignals.isNotEmpty) {
              return updatedSignals.first;
            }
          }

          final reason =
              data['reason']?.toString().toLowerCase();

          if (reason != null) {
            log(
              'PRO ENGINE: $reason',
            );
          }
        }
      } on FunctionException catch (e) {
        log(
          'PRO ENGINE ATTEMPT ERROR: '
          '${e.status} '
          '${e.reasonPhrase ?? ''} '
          '${e.details ?? ''}',
        );
      } catch (e) {
        log(
          'PRO ENGINE ATTEMPT ERROR: $e',
        );
      }

      // =============================================================
      // CHECK AGAIN
      // =============================================================

      final latest =
          await getProSignals();

      if (latest.length >= 5) {
        return latest.first;
      }

      // =============================================================
      // WAIT BEFORE NEXT ENGINE CALL
      // =============================================================

      final elapsed =
          DateTime.now()
              .toUtc()
              .difference(startedAt);

      final remaining =
          timeout - elapsed;

      if (remaining <= Duration.zero) {
        break;
      }

      final waitTime =
          remaining < _proScanInterval
              ? remaining
              : _proScanInterval;

      await Future.delayed(waitTime);
    }

    final finalSignals =
        await getProSignals();

    return finalSignals.isNotEmpty
        ? finalSignals.first
        : null;
  }

  // ===============================================================
  // LOG
  // ===============================================================

  void _log(String message) {
    // ignore: avoid_print
    print(
      'MEME SIGNAL SERVICE → $message',
    );
  }
}

// ===============================================================
// EXCEPTIONS
// ===============================================================

class FreeSignalLimitException
    implements Exception {
  const FreeSignalLimitException();

  @override
  String toString() {
    return 'Free signal limit reached.';
  }
}

class FreeSignalCooldownException
    implements Exception {
  const FreeSignalCooldownException();

  @override
  String toString() {
    return 'Free signal cooldown is active.';
  }
}