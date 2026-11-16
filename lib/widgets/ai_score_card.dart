import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class AiScoreCard extends StatelessWidget {
  final String coin;
  final String score;
  final String signal;
  final String confidence;
  final bool bullish;

  const AiScoreCard({
    super.key,
    required this.coin,
    required this.score,
    required this.signal,
    required this.confidence,
    required this.bullish,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AvexaColors>()!;
    final statusColor = bullish ? neonGreen : neonRed;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: statusColor.withOpacity(0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.07),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                coin,
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: statusColor.withOpacity(0.25),
                  ),
                ),
                child: Text(
                  score,
                  style: GoogleFonts.poppins(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            signal,
            style: GoogleFonts.poppins(
              color: statusColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: neonBlue.withOpacity(0.10),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: neonBlue.withOpacity(0.20),
                  ),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: neonBlue,
                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              Text(
                "Confidence: $confidence",
                style: GoogleFonts.poppins(
                  color: colors.secondaryText,
                  fontSize: 15,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: double.parse(score) / 100,
              minHeight: 12,
              backgroundColor: colors.elevatedCard,
              valueColor: AlwaysStoppedAnimation<Color>(
                statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}