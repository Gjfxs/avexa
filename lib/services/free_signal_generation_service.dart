import 'dart:async';

import '../models/meme_signal.dart';
import 'meme_signal_service.dart';

class FreeSignalGenerationState {
  final bool isGenerating;
  final DateTime? startedAt;
  final MemeSignal? signal;
  final int signalsUsed;
  final String? errorType;

  const FreeSignalGenerationState({
    required this.isGenerating,
    required this.startedAt,
    required this.signal,
    required this.signalsUsed,
    required this.errorType,
  });

  const FreeSignalGenerationState.idle()
      : isGenerating = false,
        startedAt = null,
        signal = null,
        signalsUsed = 0,
        errorType = null;

  FreeSignalGenerationState copyWith({
    bool? isGenerating,
    DateTime? startedAt,
    MemeSignal? signal,
    int? signalsUsed,
    String? errorType,
    bool clearStartedAt = false,
    bool clearSignal = false,
    bool clearError = false,
  }) {
    return FreeSignalGenerationState(
      isGenerating:
          isGenerating ?? this.isGenerating,
      startedAt:
          clearStartedAt
              ? null
              : startedAt ?? this.startedAt,
      signal:
          clearSignal
              ? null
              : signal ?? this.signal,
      signalsUsed:
          signalsUsed ?? this.signalsUsed,
      errorType:
          clearError
              ? null
              : errorType ?? this.errorType,
    );
  }
}

class FreeSignalGenerationService {
  FreeSignalGenerationService._();

  static final FreeSignalGenerationService instance =
      FreeSignalGenerationService._();

  final MemeSignalService _memeSignalService =
      MemeSignalService.instance;

  final StreamController<FreeSignalGenerationState>
      _stateController =
      StreamController<FreeSignalGenerationState>.broadcast();

  FreeSignalGenerationState _state =
      const FreeSignalGenerationState.idle();

  Future<MemeSignal?>? _generationFuture;

  Stream<FreeSignalGenerationState> get stream =>
      _stateController.stream;

  FreeSignalGenerationState get state => _state;

  bool get isGenerating => _state.isGenerating;

  DateTime? get startedAt => _state.startedAt;

  MemeSignal? get signal => _state.signal;

  int get signalsUsed => _state.signalsUsed;

  Duration get elapsed {
    final started = _state.startedAt;

    if (started == null) {
      return Duration.zero;
    }

    final duration =
        DateTime.now().difference(started);

    if (duration.isNegative) {
      return Duration.zero;
    }

    return duration;
  }

  Future<MemeSignal?> start() {
    if (_generationFuture != null) {
      return _generationFuture!;
    }

    if (_state.signalsUsed >= 3) {
      return Future.value(null);
    }

    final startedAt = DateTime.now();

    _setState(
      FreeSignalGenerationState(
        isGenerating: true,
        startedAt: startedAt,
        signal: null,
        signalsUsed: _state.signalsUsed,
        errorType: null,
      ),
    );

    final future = _runGeneration();

    _generationFuture = future;

    future.whenComplete(() {
      _generationFuture = null;
    });

    return future;
  }

  Future<MemeSignal?> _runGeneration() async {
    try {
      final signal =
          await _memeSignalService
              .requestFreeSignal();

      if (signal != null) {
        final used =
            await _memeSignalService
                .getFreeSignalsUsed();

        _setState(
          FreeSignalGenerationState(
            isGenerating: false,
            startedAt: null,
            signal: signal,
            signalsUsed: used.clamp(0, 3),
            errorType: null,
          ),
        );

        return signal;
      }

      _setState(
        FreeSignalGenerationState(
          isGenerating: false,
          startedAt: null,
          signal: null,
          signalsUsed: _state.signalsUsed,
          errorType: 'not_found',
        ),
      );

      return null;
    } on FreeSignalCooldownException {
      _setState(
        FreeSignalGenerationState(
          isGenerating: false,
          startedAt: null,
          signal: null,
          signalsUsed: _state.signalsUsed,
          errorType: 'cooldown',
        ),
      );

      rethrow;
    } on FreeSignalLimitException {
      _setState(
        FreeSignalGenerationState(
          isGenerating: false,
          startedAt: null,
          signal: null,
          signalsUsed: 3,
          errorType: 'limit',
        ),
      );

      rethrow;
    } catch (e) {
      _setState(
        FreeSignalGenerationState(
          isGenerating: false,
          startedAt: null,
          signal: null,
          signalsUsed: _state.signalsUsed,
          errorType: 'error',
        ),
      );

      rethrow;
    }
  }

  void setSignal(MemeSignal signal) {
    _setState(
      FreeSignalGenerationState(
        isGenerating: false,
        startedAt: null,
        signal: signal,
        signalsUsed: _state.signalsUsed,
        errorType: null,
      ),
    );
  }

  void setSignalsUsed(int used) {
    _setState(
      FreeSignalGenerationState(
        isGenerating: _state.isGenerating,
        startedAt: _state.startedAt,
        signal: _state.signal,
        signalsUsed: used.clamp(0, 3),
        errorType: _state.errorType,
      ),
    );
  }

  void clearError() {
    if (_state.errorType == null) {
      return;
    }

    _setState(
      FreeSignalGenerationState(
        isGenerating: _state.isGenerating,
        startedAt: _state.startedAt,
        signal: _state.signal,
        signalsUsed: _state.signalsUsed,
        errorType: null,
      ),
    );
  }

  void _setState(
    FreeSignalGenerationState state,
  ) {
    _state = state;

    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  void dispose() {
    _stateController.close();
  }
}