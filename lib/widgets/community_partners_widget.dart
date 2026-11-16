
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../services/community_partner_service.dart';
import '../theme.dart';

class CommunityPartnersWidget extends StatefulWidget {
  const CommunityPartnersWidget({
    super.key,
  });

  @override
  State<CommunityPartnersWidget> createState() =>
      _CommunityPartnersWidgetState();
}

class _CommunityPartnersWidgetState
    extends State<CommunityPartnersWidget> {
  final CommunityPartnerService _service =
      CommunityPartnerService.instance;

  bool _isLoading = true;
  List<Map<String, dynamic>> _partners = [];

  @override
  void initState() {
    super.initState();
    _loadPartners();
  }

  Future<void> _loadPartners() async {
    try {
      final partners =
          await _service.getActivePartners();

      if (!mounted) return;

      setState(() {
        _partners = partners;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'COMMUNITY PARTNERS ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        _partners = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _openTelegram(String url) async {
    final uri = Uri.tryParse(url);

    if (uri == null) {
      return;
    }

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      final l10n = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.communityPartnersTelegramError,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<AvexaColors>()!;
    final l10n = AppLocalizations.of(context)!;

    // Nie pokazujemy pustej sekcji.
    if (!_isLoading && _partners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: neonBlue.withOpacity(.28),
        ),
        boxShadow: [
          BoxShadow(
            color: neonBlue.withOpacity(.045),
            blurRadius: 25,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: neonBlue.withOpacity(.10),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: neonBlue.withOpacity(.18),
                  ),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: neonBlue,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.communityPartnersTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: colors.primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .5,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      l10n.communityPartnersSubtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: colors.mutedText,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.telegram,
                color: neonBlue,
                size: 23,
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: neonBlue,
                  ),
                ),
              ),
            )
          else
            ..._partners.map(
              (partner) {
                final name =
                    partner['name']?.toString() ??
                        l10n.communityPartnersDefaultName;

                final description =
                    partner['description']?.toString() ??
                        '';

                final telegramUrl =
                    partner['telegram_url']?.toString() ??
                        '';

                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: colors.background,
                    borderRadius:
                        BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(16),
                      onTap: telegramUrl.isEmpty
                          ? null
                          : () => _openTelegram(
                                telegramUrl,
                              ),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(16),
                          border: Border.all(
                            color: colors.border
                                .withOpacity(.55),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration:
                                  BoxDecoration(
                                color: neonBlue
                                    .withOpacity(.09),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.telegram,
                                color: neonBlue,
                                size: 21,
                              ),
                            ),

                            const SizedBox(width: 11),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                    style:
                                        GoogleFonts.poppins(
                                      color: colors
                                          .primaryText,
                                      fontSize: 11,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),

                                  if (description
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 2),

                                    Text(
                                      description,
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                      style:
                                          GoogleFonts.poppins(
                                        color: colors
                                            .mutedText,
                                        fontSize: 8,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: neonBlue,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
