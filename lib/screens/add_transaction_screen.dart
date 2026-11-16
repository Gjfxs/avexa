import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/transaction_model.dart';
import '../services/portfolio_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState
    extends State<AddTransactionScreen> {
  final amountController = TextEditingController();
  final priceController = TextEditingController();
  final notesController = TextEditingController();

  bool isBuy = true;

  String selectedCoin = "Bitcoin";

  final List<String> coins = [
    "Bitcoin",
    "Ethereum",
    "Solana",
    "BNB",
    "XRP",
    "Cardano",
    "Dogecoin",
    "Chainlink",
    "Avalanche",
    "Sui",
    "Pepe",
  ];

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
          "Add Transaction",
          style: GoogleFonts.poppins(
            color: colors.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "Coin",
              style: GoogleFonts.poppins(
                color: colors.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(18),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  dropdownColor: colors.card,
                  value: selectedCoin,
                  isExpanded: true,
                  style: GoogleFonts.poppins(
                    color: colors.primaryText,
                  ),
                  items: coins.map((coin) {
                    return DropdownMenuItem(
                      value: coin,
                      child: Text(coin),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      selectedCoin = value;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 26),

            Text(
              "Transaction Type",
              style: GoogleFonts.poppins(
                color: colors.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: transactionButton(
                    colors: colors,
                    title: "BUY",
                    selected: isBuy,
                    color: neonGreen,
                    onTap: () {
                      setState(() {
                        isBuy = true;
                      });
                    },
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: transactionButton(
                    colors: colors,
                    title: "SELL",
                    selected: !isBuy,
                    color: Colors.redAccent,
                    onTap: () {
                      setState(() {
                        isBuy = false;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            buildField(
              colors: colors,
              label: "Amount",
              controller: amountController,
              hint: "0.50",
            ),

            const SizedBox(height: 20),

            buildField(
              colors: colors,
              label: "Price (USD)",
              controller: priceController,
              hint: "64000",
            ),

            const SizedBox(height: 20),

            buildField(
              colors: colors,
              label: "Notes (optional)",
              controller: notesController,
              hint: "Optional...",
            ),

            const SizedBox(height: 34),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: neonGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  if (amountController.text.isEmpty ||
                      priceController.text.isEmpty) {
                    return;
                  }

                  final amount =
                      double.tryParse(amountController.text);

                  final price =
                      double.tryParse(priceController.text);

                  if (amount == null || price == null) {
                    return;
                  }

                  final symbols = {
                    "Bitcoin": "BTC",
                    "Ethereum": "ETH",
                    "Solana": "SOL",
                    "BNB": "BNB",
                    "XRP": "XRP",
                    "Cardano": "ADA",
                    "Dogecoin": "DOGE",
                    "Chainlink": "LINK",
                    "Avalanche": "AVAX",
                    "Sui": "SUI",
                    "Pepe": "PEPE",
                  };

                  final transaction = PortfolioTransaction(
                    coin: selectedCoin,
                    symbol: symbols[selectedCoin]!,
                    amount: amount,
                    price: price,
                    isBuy: isBuy,
                    date: DateTime.now(),
                  );

                  PortfolioService.instance.addTransaction(
                    transaction,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Transaction saved"),
                    ),
                  );

                  Navigator.pop(context);
                },
                child: Text(
                  "SAVE TRANSACTION",
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildField({
    required AvexaColors colors,
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: colors.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(
            color: colors.primaryText,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: colors.mutedText,
            ),
            filled: true,
            fillColor: colors.card,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget transactionButton({
    required AvexaColors colors,
    required String title,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 250),
        padding:
            const EdgeInsets.symmetric(
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: selected
              ? color
              : colors.card,
          borderRadius:
              BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: selected
                  ? Colors.black
                  : colors.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    priceController.dispose();
    notesController.dispose();
    super.dispose();
  }
}