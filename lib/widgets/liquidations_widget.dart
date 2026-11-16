import 'dart:async';

import 'package:flutter/material.dart';

import '../services/market_service.dart';
import '../theme.dart';

class LiquidationsWidget extends StatefulWidget {
  const LiquidationsWidget({super.key});

  @override
  State<LiquidationsWidget> createState() =>
      _LiquidationsWidgetState();
}

class _LiquidationsWidgetState
    extends State<LiquidationsWidget> {
  final MarketService _marketService =
      MarketService();

  StreamSubscription<List<dynamic>>? _subscription;

  final List<Map<String, dynamic>> _liquidations = [];

  @override
  void initState() {
    super.initState();

    _subscription =
        _marketService.liquidationStream().listen(
      (events) {
        if (!mounted || events.isEmpty) return;

        final liquidation =
            Map<String, dynamic>.from(events.first);

        setState(() {
          _liquidations.insert(
            0,
            liquidation,
          );

          // Keep only the latest 3 events.
          if (_liquidations.length > 3) {
            _liquidations.removeLast();
          }
        });
      },
      onError: (_) {
        // Connection errors are handled by the UI
        // through the empty/loading state.
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  String _formatValue(double value) {
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(2)}M';
    }

    if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(1)}K';
    }

    return '\$${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<AvexaColors>()!;

    if (_liquidations.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: neonBlue,
                strokeWidth: 2.5,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              'Waiting for live liquidations...',
              style: TextStyle(
                color: colors.secondaryText,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration:
                      const BoxDecoration(
                    color: neonGreen,
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 6),

                Text(
                  'LIVE • Binance Futures',
                  style: TextStyle(
                    color: colors.mutedText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        ..._liquidations.map(
          (liquidation) {
            final symbol =
                liquidation['symbol']
                    ?.toString() ??
                    'UNKNOWN';

            final side =
                liquidation['side']
                    ?.toString() ??
                    '';

            final value =
                liquidation['value'] is num
                    ? (liquidation['value']
                            as num)
                        .toDouble()
                    : 0.0;

            // Binance:
            // SELL = long position liquidated
            // BUY  = short position liquidated
            final isLong =
                side.toUpperCase() == 'SELL';

            final position =
                isLong ? 'LONG' : 'SHORT';

            final statusColor =
                isLong
                    ? neonRed
                    : neonYellow;

            return Container(
              margin:
                  const EdgeInsets.only(
                bottom: 14,
              ),
              padding:
                  const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color:
                    colors.elevatedCard,
                borderRadius:
                    BorderRadius.circular(22),
                border: Border.all(
                  color: colors.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: statusColor
                        .withOpacity(0.05),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration:
                        BoxDecoration(
                      color: statusColor
                          .withOpacity(0.10),
                      shape:
                          BoxShape.circle,
                      border: Border.all(
                        color: statusColor
                            .withOpacity(
                          0.18,
                        ),
                      ),
                    ),
                    child: Icon(
                      Icons.warning_rounded,
                      color: statusColor,
                      size: 23,
                    ),
                  ),

                  const SizedBox(
                    width: 14,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          '$symbol $position',
                          style: TextStyle(
                            color:
                                colors.primaryText,
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        Text(
                          'Position liquidated',
                          style: TextStyle(
                            color:
                                colors.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    _formatValue(value),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 2),

        Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration:
                  const BoxDecoration(
                color: neonGreen,
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 6),

            Text(
              'LIVE • Binance Futures',
              style: TextStyle(
                color: colors.mutedText,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}