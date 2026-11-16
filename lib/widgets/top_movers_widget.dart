import 'dart:async';

import 'package:flutter/material.dart';

import '../services/market_service.dart';
import '../theme.dart';

class TopMoversWidget extends StatefulWidget {
  const TopMoversWidget({super.key});

  @override
  State<TopMoversWidget> createState() =>
      _TopMoversWidgetState();
}

class _TopMoversWidgetState
    extends State<TopMoversWidget> {
  final MarketService _marketService = MarketService();

  Timer? _timer;
  late Future<List<dynamic>> _moversFuture;

  @override
  void initState() {
    super.initState();

    _loadMovers();

    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadMovers(),
    );
  }

  void _loadMovers() {
    setState(() {
      _moversFuture =
          _marketService.fetchTopMovers();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<AvexaColors>()!;

    return FutureBuilder<List<dynamic>>(
      future: _moversFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(
                color: neonBlue,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Failed to load market movers.',
              style: TextStyle(
                color: neonRed,
              ),
            ),
          );
        }

        final movers = snapshot.data ?? [];

        if (movers.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'No market movers available.',
              style: TextStyle(
                color: colors.secondaryText,
              ),
            ),
          );
        }

        return Column(
          children: [
            ...movers.map(
              (coin) {
                final rawChange =
                    coin['price_change_percentage_24h'];

                final change =
                    rawChange is num
                        ? rawChange.toDouble()
                        : double.tryParse(
                              rawChange
                                      ?.toString() ??
                                  '',
                            ) ??
                            0;

                final isPositive =
                    change >= 0;

                final movementColor =
                    isPositive
                        ? neonGreen
                        : neonRed;

                return Container(
                  margin:
                      const EdgeInsets.only(
                    bottom: 14,
                  ),
                  padding:
                      const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.elevatedCard,
                    borderRadius:
                        BorderRadius.circular(22),
                    border: Border.all(
                      color: colors.border,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: neonBlue
                            .withOpacity(0.04),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration:
                                BoxDecoration(
                              color: movementColor
                                  .withOpacity(
                                0.10,
                              ),
                              shape:
                                  BoxShape.circle,
                            ),
                            child: Icon(
                              isPositive
                                  ? Icons
                                      .trending_up_rounded
                                  : Icons
                                      .trending_down_rounded,
                              color:
                                  movementColor,
                              size: 19,
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Text(
                            coin['symbol']
                                .toString()
                                .toUpperCase(),
                            style: TextStyle(
                              color:
                                  colors.primaryText,
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration:
                            BoxDecoration(
                          color: movementColor
                              .withOpacity(
                            0.10,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: Text(
                          '${isPositive ? '+' : ''}'
                          '${change.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color:
                                movementColor,
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 16,
                          ),
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
                  'LIVE • Updates every 30s',
                  style: TextStyle(
                    color: colors.mutedText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}