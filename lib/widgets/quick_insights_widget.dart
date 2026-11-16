import 'package:flutter/material.dart';
import '../theme.dart';

class QuickInsightsWidget extends StatelessWidget {
  const QuickInsightsWidget({super.key});

  Widget insightCard(
    String title,
    String value,
    IconData icon,
    Color color,
    AvexaColors colors,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.18),
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AvexaColors>()!;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        insightCard(
          "AI Signal",
          "BUY",
          Icons.auto_graph,
          neonGreen,
          colors,
        ),

        insightCard(
          "Fear & Greed",
          "72",
          Icons.psychology,
          Colors.orange,
          colors,
        ),

        insightCard(
          "Top Mover",
          "+18%",
          Icons.rocket_launch,
          neonBlue,
          colors,
        ),

        insightCard(
          "Whale Activity",
          "HIGH",
          Icons.water,
          Colors.purpleAccent,
          colors,
        ),
      ],
    );
  }
}