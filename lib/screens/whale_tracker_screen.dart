import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';

class WhaleTrackerScreen extends StatelessWidget {
  const WhaleTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<AvexaColors>()!;

    return Scaffold(
      extendBody: true,
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Text(
          "🐋 Whale Tracker",
          style: GoogleFonts.poppins(
            color: colors.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          whaleCard(
            "Smart Wallet bought BTC",
            "+\$24M",
            neonGreen,
            "2 minutes ago",
            colors,
          ),

          whaleCard(
            "ETH transferred to Binance",
            "-\$12M",
            Colors.redAccent,
            "5 minutes ago",
            colors,
          ),

          whaleCard(
            "SOL accumulation detected",
            "+\$8.4M",
            neonBlue,
            "12 minutes ago",
            colors,
          ),

          whaleCard(
            "PEPE whale exit",
            "-\$3.1M",
            Colors.orange,
            "20 minutes ago",
            colors,
          ),
        ],
      ),
    );
  }

  Widget whaleCard(
    String title,
    String amount,
    Color color,
    String time,
    AvexaColors colors,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              color: color.withOpacity(0.10),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.25),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.water,
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
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  time,
                  style: GoogleFonts.poppins(
                    color: colors.secondaryText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Text(
            amount,
            style: GoogleFonts.poppins(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}