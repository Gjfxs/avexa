import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';
import '../services/connection_service.dart';
import '../services/wallet_service.dart';
import '../services/portfolio_service.dart';

class ProviderConnectScreen extends StatefulWidget {
  final String provider;

  const ProviderConnectScreen({
    super.key,
    required this.provider,
  });

  @override
  State<ProviderConnectScreen> createState() =>
      _ProviderConnectScreenState();
}

class _ProviderConnectScreenState
    extends State<ProviderConnectScreen> {
  final apiKeyController = TextEditingController();
  final secretController = TextEditingController();
  final walletController = TextEditingController();
  final nameController = TextEditingController();

  final connectionService = ConnectionService.instance;

  bool loading = false;

  bool get isExchange =>
      !widget.provider.toLowerCase().contains("wallet") &&
      widget.provider != "MetaMask" &&
      widget.provider != "Phantom";

  bool isValidSolanaAddress(String address) {
    return address.length >= 32 && address.length <= 44;
  }

  Future<String?> _askForAccountName() async {
    nameController.clear();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final colors =
            Theme.of(dialogContext).extension<AvexaColors>()!;

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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose a name that will help you identify this connection in Avexa.',
                style: GoogleFonts.poppins(
                  color: colors.secondaryText,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: nameController,
                autofocus: true,
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Main Trading Wallet',
                  hintStyle: GoogleFonts.poppins(
                    color: colors.mutedText,
                  ),
                  filled: true,
                  fillColor: colors.background,
                  prefixIcon: const Icon(
                    Icons.edit_outlined,
                    color: neonBlue,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colors.border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: neonBlue,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ],
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
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();

                if (name.isEmpty) {
                  return;
                }

                Navigator.pop(dialogContext, name);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: neonBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
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
  }

  Future<void> _connect() async {
    if (loading) return;

    setState(() {
      loading = true;
    });

    try {
      if (!isExchange) {
        final address = walletController.text.trim();

        if (!isValidSolanaAddress(address)) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Invalid Solana wallet address",
              ),
            ),
          );

          return;
        }

        try {
          if (widget.provider == "Phantom") {
            final assets = await WalletService.instance
                .getSolanaPortfolio(address);

            PortfolioService.instance.setAssets(assets);
          }
        } catch (e) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Failed to load wallet: ${e.toString()}",
              ),
            ),
          );

          return;
        }

        final customName = await _askForAccountName();

        if (customName == null) {
          return;
        }

        await connectionService.connect(
          widget.provider,
          walletAddress: address,
          customName: customName,
        );
      } else {
        final apiKey = apiKeyController.text.trim();
        final secretKey = secretController.text.trim();

        if (apiKey.isEmpty || secretKey.isEmpty) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Please enter your API Key and Secret Key.",
              ),
            ),
          );

          return;
        }

        final customName = await _askForAccountName();

        if (customName == null) {
          return;
        }

        await connectionService.connect(
          widget.provider,
          apiKey: apiKey,
          customName: customName,
        );
      }

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Connection failed: $e",
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
        centerTitle: true,
        title: Text(
          "Connect ${widget.provider}",
          style: GoogleFonts.poppins(
            color: colors.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 38,
                    backgroundColor: neonBlue,
                    child: Icon(
                      Icons.link,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    widget.provider,
                    style: GoogleFonts.poppins(
                      color: colors.primaryText,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    isExchange
                        ? "Read-only API access. Your funds always stay on your exchange."
                        : "Connect your wallet to analyze balances, allocation and AI insights.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: colors.secondaryText,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            if (isExchange) ...[
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
                    borderSide: BorderSide(
                      color: colors.border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: colors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: neonBlue,
                      width: 1.4,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

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
                    borderSide: BorderSide(
                      color: colors.border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: colors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: neonBlue,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ] else ...[
              TextField(
                controller: walletController,
                style: TextStyle(
                  color: colors.primaryText,
                ),
                decoration: InputDecoration(
                  labelText: widget.provider == "Phantom"
                      ? "Phantom Wallet Address"
                      : "Wallet Address",
                  hintText: widget.provider == "Phantom"
                      ? "Example: 7dHbWX..."
                      : null,
                  labelStyle: TextStyle(
                    color: colors.secondaryText,
                  ),
                  hintStyle: TextStyle(
                    color: colors.mutedText,
                  ),
                  filled: true,
                  fillColor: colors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: colors.border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: colors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: neonBlue,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: neonBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: loading ? null : _connect,
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        "CONNECT ${widget.provider.toUpperCase()}",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
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

  @override
  void dispose() {
    apiKeyController.dispose();
    secretController.dispose();
    walletController.dispose();
    nameController.dispose();
    super.dispose();
  }
}