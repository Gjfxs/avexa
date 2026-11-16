import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme.dart';

class FearGreedWidget extends StatelessWidget {
  const FearGreedWidget({super.key});

  Future<Map<String, dynamic>> fetchFearGreed() async {
    final response = await http.get(
      Uri.parse('https://api.alternative.me/fng/'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load Fear & Greed');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AvexaColors>()!;

    return FutureBuilder(
      future: fetchFearGreed(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              color: neonBlue,
            ),
          );
        }

        final data = snapshot.data!['data'][0];

        final value = data['value'];
        final classification = data['value_classification'];

        Color color = neonBlue;

        if (classification.contains('Greed')) {
          color = neonGreen;
        } else if (classification.contains('Fear')) {
          color = neonBlue;
        }

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.elevatedCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colors.border,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "Fear & Greed Index",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: color.withOpacity(0.20),
                  ),
                ),
                child: Text(
                  "$value",
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Flexible(
                child: Text(
                  classification,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}