import 'package:flutter/material.dart';
import '../services/market_service.dart';
import '../theme.dart';

class AiSignalsWidget extends StatelessWidget {
  const AiSignalsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AvexaColors>()!;

    return FutureBuilder(
      future: MarketService().fetchMarkets(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final coins = snapshot.data as List;

        return Column(
          children: coins.take(3).map((coin) {
            final change =
                (coin['price_change_percentage_24h'] ?? 0)
                    .toDouble();

            String signal;
            Color color;

            if (change > 5) {
              signal = "STRONG BUY";
              color = neonGreen;
            } else if (change > 2) {
              signal = "BUY";
              color = Colors.lightGreen;
            } else if (change < -5) {
              signal = "STRONG SELL";
              color = Colors.red;
            } else if (change < -2) {
              signal = "SELL";
              color = Colors.orange;
            } else {
              signal = "NEUTRAL";
              color = Colors.grey;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        coin['symbol']
                            .toString()
                            .toUpperCase(),
                        style: TextStyle(
                          color: colors.primaryText,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        signal,
                        style: TextStyle(
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "${change.toStringAsFixed(2)}%",
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}