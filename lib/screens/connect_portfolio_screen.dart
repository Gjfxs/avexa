
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';
import '../services/connection_service.dart';
import '../l10n/app_localizations.dart';

class PortfolioNetwork {
  final String id;
  final String name;
  final String description;
  final String symbol;
  final Color color;

  const PortfolioNetwork({
    required this.id,
    required this.name,
    required this.description,
    required this.symbol,
    required this.color,
  });
}

class ConnectPortfolioScreen extends StatefulWidget {
  const ConnectPortfolioScreen({super.key});

  @override
  State<ConnectPortfolioScreen> createState() =>
      _ConnectPortfolioScreenState();
}

class _ConnectPortfolioScreenState
    extends State<ConnectPortfolioScreen> {
  final connectionService = ConnectionService.instance;

  final addressController = TextEditingController();
  final nameController = TextEditingController();

  bool loading = false;

  int selectedNetworkIndex = 0;

  static const String mascotAsset =
      'assets/images/ax_wallet.png';

  final List<PortfolioNetwork> networks = const [
    PortfolioNetwork(
      id: 'solana',
      name: 'Solana',
      description: 'Solana blockchain',
      symbol: 'SOL',
      color: Color(0xFF9945FF),
    ),
    PortfolioNetwork(
      id: 'ethereum',
      name: 'Ethereum',
      description: 'Ethereum mainnet',
      symbol: 'ETH',
      color: Color(0xFF627EEA),
    ),
    PortfolioNetwork(
      id: 'base',
      name: 'Base',
      description: 'Base network',
      symbol: 'BASE',
      color: Color(0xFF0052FF),
    ),
    PortfolioNetwork(
      id: 'arbitrum',
      name: 'Arbitrum',
      description: 'Arbitrum One',
      symbol: 'ARB',
      color: Color(0xFF28A0F0),
    ),
    PortfolioNetwork(
      id: 'polygon',
      name: 'Polygon',
      description: 'Polygon PoS',
      symbol: 'POL',
      color: Color(0xFF8247E5),
    ),
  ];

  PortfolioNetwork get selectedNetwork =>
      networks[selectedNetworkIndex];

  String _networkDescription(
    AppLocalizations l10n,
    PortfolioNetwork network,
  ) {
    switch (network.id) {
      case 'solana':
        return l10n.connectPortfolioSolanaDescription;
      case 'ethereum':
        return l10n.connectPortfolioEthereumDescription;
      case 'base':
        return l10n.connectPortfolioBaseDescription;
      case 'arbitrum':
        return l10n.connectPortfolioArbitrumDescription;
      case 'polygon':
        return l10n.connectPortfolioPolygonDescription;
      default:
        return network.description;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadConnections();
  }

  Future<void> _loadConnections() async {
    await connectionService.load();

    if (mounted) {
      setState(() {});
    }
  }

  bool _isValidAddress(String address, String network) {
    final value = address.trim();

    if (network == 'solana') {
      if (value.length < 32 || value.length > 44) {
        return false;
      }

      return RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$')
          .hasMatch(value);
    }

    return RegExp(r'^0x[a-fA-F0-9]{40}$')
        .hasMatch(value);
  }

  Future<void> _connect() async {
    if (loading) return;

    final l10n = AppLocalizations.of(context)!;

    final address = addressController.text.trim();
    final customName = nameController.text.trim();
    final network = selectedNetwork;

    if (address.isEmpty) {
      _showMessage(l10n.connectPortfolioEnterAddress);
      return;
    }

    if (!_isValidAddress(address, network.id)) {
      _showMessage(
        network.id == 'solana'
            ? l10n.connectPortfolioInvalidSolanaAddress
            : l10n.connectPortfolioInvalidNetworkAddress(
                network.name,
              ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await connectionService.load();

      final alreadyConnected =
          connectionService.isWalletConnected(
        network: network.id,
        address: address,
      );

      if (alreadyConnected) {
        if (!mounted) return;

        _showMessage(
          l10n.connectPortfolioAlreadyConnected(
            network.name,
          ),
        );
        return;
      }

      await connectionService.connectWallet(
        network: network.id,
        address: address,
        customName: customName.isEmpty ? null : customName,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: neonGreen,
          behavior: SnackBarBehavior.floating,
          content: Text(
            l10n.connectPortfolioSuccess(network.name),
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      _showMessage(l10n.connectPortfolioError);
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context)
            .extension<AvexaColors>()!
            .elevatedCard,
        content: Text(
          message,
          style: GoogleFonts.poppins(
            color: Theme.of(context)
                .extension<AvexaColors>()!
                .primaryText,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Future<void> _openNetworkPicker() async {
    if (loading) return;

    final l10n = AppLocalizations.of(context)!;

    final colors =
        Theme.of(context).extension<AvexaColors>()!;

    final selected = await showModalBottomSheet<PortfolioNetwork>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(sheetContext).size.height * 0.58,
          decoration: BoxDecoration(
            color: colors.elevatedCard,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(26),
            ),
            border: Border.all(
              color: colors.border,
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 12),

                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.mutedText.withOpacity(.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    22,
                    20,
                    16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.connectPortfolioSelectNetwork,
                              style: GoogleFonts.poppins(
                                color: colors.primaryText,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.connectPortfolioChooseNetwork,
                              style: GoogleFonts.poppins(
                                color: colors.secondaryText,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                        },
                        icon: Icon(
                          Icons.close_rounded,
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(
                  height: 1,
                  color: colors.border,
                ),

                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: networks.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 9),
                    itemBuilder: (context, index) {
                      final network = networks[index];
                      final isSelected =
                          network.id == selectedNetwork.id;

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.pop(
                            sheetContext,
                            network,
                          );
                        },
                        child: AnimatedContainer(
                          duration:
                              const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? network.color.withOpacity(.12)
                                : colors.card,
                            borderRadius:
                                BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? network.color.withOpacity(.65)
                                  : colors.border,
                              width: isSelected ? 1.3 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: network.color
                                      .withOpacity(.15),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  network.symbol.substring(0, 1),
                                  style: GoogleFonts.poppins(
                                    color: network.color,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 13),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      network.name,
                                      style: GoogleFonts.poppins(
                                        color: colors.primaryText,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _networkDescription(
                                        l10n,
                                        network,
                                      ),
                                      style: GoogleFonts.poppins(
                                        color: colors.mutedText,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: network.color,
                                  size: 21,
                                )
                              else
                                Icon(
                                  Icons.circle_outlined,
                                  color: colors.mutedText,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null || !mounted) return;

    setState(() {
      selectedNetworkIndex =
          networks.indexWhere((item) => item.id == selected.id);
    });
  }

  Widget _buildSectionTitle(
    String title,
    String subtitle,
    AvexaColors colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: colors.primaryText,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            color: colors.mutedText,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkSelector(
    AvexaColors colors,
    AppLocalizations l10n,
  ) {
    final network = selectedNetwork;

    return InkWell(
      onTap: loading ? null : _openNetworkPicker,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: network.color.withOpacity(.45),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: network.color.withOpacity(.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                network.symbol.substring(0, 1),
                style: GoogleFonts.poppins(
                  color: network.color,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    network.name,
                    style: GoogleFonts.poppins(
                      color: colors.primaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _networkDescription(l10n, network),
                    style: GoogleFonts.poppins(
                      color: colors.mutedText,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: colors.secondaryText,
              size: 25,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required AvexaColors colors,
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      enabled: !loading,
      style: GoogleFonts.poppins(
        color: colors.primaryText,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.poppins(
          color: colors.secondaryText,
          fontSize: 12,
        ),
        hintStyle: GoogleFonts.poppins(
          color: colors.mutedText,
          fontSize: 11,
        ),
        prefixIcon: icon != null
            ? Icon(
                icon,
                color: colors.mutedText,
                size: 19,
              )
            : null,
        filled: true,
        fillColor: colors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: neonBlue,
            width: 1.3,
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityInfo(
    AvexaColors colors,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: neonBlue.withOpacity(.055),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: neonBlue.withOpacity(.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_outlined,
            color: neonBlue,
            size: 23,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.connectPortfolioSecurityTitle,
                  style: GoogleFonts.poppins(
                    color: colors.primaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.connectPortfolioSecurityDescription,
                  style: GoogleFonts.poppins(
                    color: colors.secondaryText,
                    fontSize: 10,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMascotHeader(
    AvexaColors colors,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 158,
            width: 190,
            child: Image.asset(
              mascotAsset,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: neonBlue.withOpacity(.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: neonBlue,
                    size: 36,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          Text(
            l10n.connectPortfolioHeader,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: colors.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            l10n.connectPortfolioSubtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: colors.secondaryText,
              fontSize: 11,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<AvexaColors>()!;

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.portfolioConnectTitle,
          style: GoogleFonts.poppins(
            color: colors.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMascotHeader(colors, l10n),

              const SizedBox(height: 28),

              _buildSectionTitle(
                l10n.connectPortfolioSectionNetwork,
                l10n.connectPortfolioSectionNetworkSubtitle,
                colors,
              ),

              const SizedBox(height: 13),

              _buildNetworkSelector(colors, l10n),

              const SizedBox(height: 27),

              _buildSectionTitle(
                l10n.connectPortfolioSectionAddress,
                l10n.connectPortfolioSectionAddressSubtitle,
                colors,
              ),

              const SizedBox(height: 12),

              _buildTextField(
                controller: addressController,
                label: l10n.connectPortfolioAddressLabel(
                  selectedNetwork.name,
                ),
                hint: selectedNetwork.id == 'solana'
                    ? l10n.connectPortfolioSolanaAddressHint
                    : '0x...',
                colors: colors,
                icon: Icons.link,
              ),

              const SizedBox(height: 20),

              _buildSectionTitle(
                l10n.connectPortfolioSectionWalletName,
                l10n.connectPortfolioSectionWalletNameSubtitle,
                colors,
              ),

              const SizedBox(height: 12),

              _buildTextField(
                controller: nameController,
                label: l10n.connectPortfolioCustomNameLabel,
                hint: l10n.connectPortfolioCustomNameHint,
                colors: colors,
                icon: Icons.edit_outlined,
              ),

              const SizedBox(height: 24),

              _buildSecurityInfo(colors, l10n),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: loading ? null : _connect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.3,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_link,
                              size: 19,
                            ),
                            const SizedBox(width: 9),
                            Text(
                              l10n.connectPortfolioButton,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                letterSpacing: .5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    addressController.dispose();
    nameController.dispose();
    super.dispose();
  }
}
