import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../theme.dart';
import '../services/connection_service.dart';

class BinanceConnectScreen extends StatefulWidget {
  const BinanceConnectScreen({super.key});

  @override
  State<BinanceConnectScreen> createState() =>
      _BinanceConnectScreenState();
}

class _BinanceConnectScreenState
    extends State<BinanceConnectScreen> {
  final apiKeyController = TextEditingController();
  final secretController = TextEditingController();

  bool loading = false;

  static const functionUrl =
      'https://mbwvfjoayhfnsiabrgcf.supabase.co/functions/v1/binance-connect';

  static const anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1id3Zmam9heWhmbnNpYWJyZ2NmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI1ODIwNTksImV4cCI6MjA5ODE1ODA1OX0.Fi9N-Jh8e3QwevUXr-ZQlPIrdhFuyyZM8UgL0iMQRnw';

  @override
  void dispose() {
    apiKeyController.dispose();
    secretController.dispose();
    super.dispose();
  }

  Future<void> connect() async {
    setState(() {
      loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(functionUrl),
        headers: {
          "Content-Type": "application/json",
          "apikey": anonKey,
          "Authorization": "Bearer $anonKey",
        },
        body: jsonEncode({
          "apiKey": apiKeyController.text.trim(),
          "apiSecret": secretController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {
        if (!mounted) return;

        final nameController = TextEditingController();

        final customName = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            final colors =
                Theme.of(dialogContext)
                    .extension<AvexaColors>()!;

            return AlertDialog(
              backgroundColor: colors.elevatedCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: colors.border,
                ),
              ),
              title: Text(
                'Name your account',
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: TextField(
                controller: nameController,
                autofocus: true,
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Main Binance',
                  hintStyle: GoogleFonts.poppins(
                    color: colors.mutedText,
                  ),
                  filled: true,
                  fillColor: colors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: neonBlue,
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    'CANCEL',
                    style: GoogleFonts.poppins(
                      color: colors.mutedText,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name =
                        nameController.text.trim();

                    if (name.isEmpty) return;

                    Navigator.pop(
                      dialogContext,
                      name,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'SAVE',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            );
          },
        );

        nameController.dispose();

        if (customName == null ||
            customName.trim().isEmpty) {
          return;
        }

        await ConnectionService.instance.connect(
          "Binance",
          apiKey: apiKeyController.text.trim(),
          customName: customName.trim(),
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Connected successfully • ${data["accountType"]}",
            ),
          ),
        );

        Navigator.pop(context);
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data["message"] ??
                  data["error"] ??
                  "Connection failed.",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<AvexaColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Text(
          "Connect Binance",
          style: GoogleFonts.poppins(
            color: colors.primaryText,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: apiKeyController,
              style: TextStyle(
                color: colors.primaryText,
              ),
              decoration: InputDecoration(
                labelText: "API Key",
                labelStyle: TextStyle(
                  color: colors.secondaryText,
                ),
                filled: true,
                fillColor: colors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: secretController,
              obscureText: true,
              style: TextStyle(
                color: colors.primaryText,
              ),
              decoration: InputDecoration(
                labelText: "Secret Key",
                labelStyle: TextStyle(
                  color: colors.secondaryText,
                ),
                filled: true,
                fillColor: colors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed:
                    loading ? null : connect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: neonGreen,
                ),
                child: loading
                    ? const CircularProgressIndicator()
                    : Text(
                        "CONNECT",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}