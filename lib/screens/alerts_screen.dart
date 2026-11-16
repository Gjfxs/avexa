import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<AvexaColors>()!;

    return Scaffold(
      extendBody: true,
      backgroundColor: colors.background,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            "Alerts",
            style: GoogleFonts.poppins(
              color: colors.primaryText,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Stay informed about market activity",
            style: GoogleFonts.poppins(
              color: colors.secondaryText,
            ),
          ),

          const SizedBox(height: 24),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                filterChip("All", true, colors),
                filterChip("AI Signals", false, colors),
                filterChip("Whales", false, colors),
                filterChip("Risk", false, colors),
                filterChip("Memecoins", false, colors),
              ],
            ),
          ),

          const SizedBox(height: 24),

          alertCard(
            "Whale Movement",
            "A whale transferred \$24M USDT to Binance.",
            "18 min ago",
            neonBlue,
            Icons.water,
            colors,
          ),

          alertCard(
            "Whale Movement",
            "A whale transferred \$24M USDT to Binance.",
            "18 min ago",
            neonBlue,
            Icons.water,
            colors,
          ),

          alertCard(
            "Liquidation Spike",
            "Massive short liquidations detected on ETH.",
            "42 min ago",
            Colors.redAccent,
            Icons.warning_rounded,
            colors,
          ),

          alertCard(
            "Memecoin Momentum",
            "PEPE social activity increased by 340%.",
            "1 hour ago",
            Colors.orange,
            Icons.local_fire_department,
            colors,
          ),

          alertCard(
            "AI Signal Triggered",
            "SOL LONG signal confidence reached 96%.",
            "2 hours ago",
            neonGreen,
            Icons.auto_awesome,
            colors,
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget alertCard(
    String title,
    String subtitle,
    String time,
    Color color,
    IconData icon,
    AvexaColors colors,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withOpacity(0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.22),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.35),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: colors.primaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: colors.secondaryText,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  time,
                  style: GoogleFonts.poppins(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget filterChip(
    String title,
    bool active,
    AvexaColors colors,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: active
            ? neonGreen.withOpacity(0.15)
            : colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active
              ? neonGreen
              : colors.border,
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: active
              ? neonGreen
              : colors.secondaryText,
        ),
      ),
    );
  }
}