
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'contact_support_screen.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_HelpCategory> _categories(AppLocalizations l10n) => [
        _HelpCategory(
          title: l10n.helpSignals,
          subtitle: l10n.helpSignalsSubtitle,
          icon: Icons.bolt_rounded,
          questions: [
            _FaqItem(l10n.faqSignalsQ1, l10n.faqSignalsA1),
            _FaqItem(l10n.faqSignalsQ2, l10n.faqSignalsA2),
            _FaqItem(l10n.faqSignalsQ3, l10n.faqSignalsA3),
            _FaqItem(l10n.faqSignalsQ4, l10n.faqSignalsA4),
            _FaqItem(l10n.faqSignalsQ5, l10n.faqSignalsA5),
          ],
        ),
        _HelpCategory(
          title: l10n.helpPro,
          subtitle: l10n.helpProSubtitle,
          icon: Icons.auto_awesome,
          questions: [
            _FaqItem(l10n.faqProQ1, l10n.faqProA1),
            _FaqItem(l10n.faqProQ2, l10n.faqProA2),
            _FaqItem(l10n.faqProQ3, l10n.faqProA3),
            _FaqItem(l10n.faqProQ4, l10n.faqProA4),
            _FaqItem(l10n.faqProQ5, l10n.faqProA5),
          ],
        ),
        _HelpCategory(
          title: l10n.helpTrading,
          subtitle: l10n.helpTradingSubtitle,
          icon: Icons.show_chart_rounded,
          questions: [
            _FaqItem(l10n.faqTradingQ1, l10n.faqTradingA1),
            _FaqItem(l10n.faqTradingQ2, l10n.faqTradingA2),
            _FaqItem(l10n.faqTradingQ3, l10n.faqTradingA3),
            _FaqItem(l10n.faqTradingQ4, l10n.faqTradingA4),
            _FaqItem(l10n.faqTradingQ5, l10n.faqTradingA5),
          ],
        ),
        _HelpCategory(
          title: l10n.helpAccount,
          subtitle: l10n.helpAccountSubtitle,
          icon: Icons.person_outline_rounded,
          questions: [
            _FaqItem(l10n.faqAccountQ1, l10n.faqAccountA1),
            _FaqItem(l10n.faqAccountQ2, l10n.faqAccountA2),
            _FaqItem(l10n.faqAccountQ3, l10n.faqAccountA3),
            _FaqItem(l10n.faqAccountQ4, l10n.faqAccountA4),
            _FaqItem(l10n.faqAccountQ5, l10n.faqAccountA5),
          ],
        ),
        _HelpCategory(
          title: l10n.helpNotifications,
          subtitle: l10n.helpNotificationsSubtitle,
          icon: Icons.notifications_none_rounded,
          questions: [
            _FaqItem(l10n.faqNotificationsQ1, l10n.faqNotificationsA1),
            _FaqItem(l10n.faqNotificationsQ2, l10n.faqNotificationsA2),
            _FaqItem(l10n.faqNotificationsQ3, l10n.faqNotificationsA3),
            _FaqItem(l10n.faqNotificationsQ4, l10n.faqNotificationsA4),
          ],
        ),
      ];

  List<_HelpCategory> _filteredCategories(
    AppLocalizations l10n,
  ) {
    final categories = _categories(l10n);

    if (searchQuery.isEmpty) return categories;

    return categories.where((category) {
      final categoryMatch =
          category.title.toLowerCase().contains(searchQuery) ||
          category.subtitle.toLowerCase().contains(searchQuery);

      final questionMatch = category.questions.any(
        (faq) =>
            faq.question.toLowerCase().contains(searchQuery) ||
            faq.answer.toLowerCase().contains(searchQuery),
      );

      return categoryMatch || questionMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AvexaColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final categories = _categories(l10n);
    final filteredCategories = _filteredCategories(l10n);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: colors.primaryText,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.helpCenter,
          style: GoogleFonts.poppins(
            color: colors.primaryText,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  l10n.helpMainTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: colors.primaryText,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  l10n.helpMainSubtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: colors.secondaryText,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.border),
                  boxShadow: [
                    BoxShadow(
                      color: neonBlue.withOpacity(.04),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.trim().toLowerCase();
                    });
                  },
                  style: TextStyle(color: colors.primaryText),
                  cursorColor: neonBlue,
                  decoration: InputDecoration(
                    hintText: l10n.helpSearchHint,
                    hintStyle: TextStyle(color: colors.mutedText),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: neonBlue,
                    ),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              color: colors.mutedText,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 17,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              if (searchQuery.isEmpty) ...[
                _sectionTitle(l10n.helpPopularTopics, colors),
                const SizedBox(height: 14),
                ...categories.map(
                  (category) => _topicTile(
                    context,
                    category: category,
                    colors: colors,
                  ),
                ),
              ] else ...[
                _sectionTitle(l10n.helpSearchResults, colors),
                const SizedBox(height: 14),
                if (filteredCategories.isEmpty)
                  _emptySearch(l10n, colors)
                else
                  ...filteredCategories.map(
                    (category) => _topicTile(
                      context,
                      category: category,
                      colors: colors,
                    ),
                  ),
              ],
              const SizedBox(height: 28),
              _sectionTitle(l10n.helpNeedMore, colors),
              const SizedBox(height: 14),
              _supportTile(
                icon: Icons.mail_outline_rounded,
                title: l10n.contactSupport,
                subtitle: l10n.helpSupportSubtitle,
                colors: colors,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ContactSupportScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, AvexaColors colors) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: colors.secondaryText,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.3,
      ),
    );
  }

  Widget _topicTile(
    BuildContext context, {
    required _HelpCategory category,
    required AvexaColors colors,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HelpCategoryScreen(
                  category: category,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: neonBlue.withOpacity(.10),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: neonBlue.withOpacity(.12),
                    ),
                  ),
                  child: Icon(
                    category.icon,
                    color: neonBlue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        style: GoogleFonts.poppins(
                          color: colors.primaryText,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        category.subtitle,
                        style: GoogleFonts.poppins(
                          color: colors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.mutedText,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptySearch(
    AppLocalizations l10n,
    AvexaColors colors,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 35,
      ),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            color: colors.mutedText,
            size: 42,
          ),
          const SizedBox(height: 14),
          Text(
            l10n.helpNoResults,
            style: GoogleFonts.poppins(
              color: colors.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.helpTryAnotherSearch,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: colors.secondaryText,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _supportTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required AvexaColors colors,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: neonBlue.withOpacity(.04),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: neonBlue.withOpacity(.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: neonBlue, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          color: colors.primaryText,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          color: colors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.mutedText,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===================================================================
// FAQ CATEGORY SCREEN
// ===================================================================

class HelpCategoryScreen extends StatefulWidget {
  final _HelpCategory category;

  const HelpCategoryScreen({
    super.key,
    required this.category,
  });

  @override
  State<HelpCategoryScreen> createState() =>
      _HelpCategoryScreenState();
}

class _HelpCategoryScreenState extends State<HelpCategoryScreen> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AvexaColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: colors.primaryText,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.category.title,
          style: GoogleFonts.poppins(
            color: colors.primaryText,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: neonBlue.withOpacity(.10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: neonBlue.withOpacity(.12),
                      ),
                    ),
                    child: Icon(
                      widget.category.icon,
                      color: neonBlue,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.category.subtitle,
                      style: GoogleFonts.poppins(
                        color: colors.secondaryText,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                l10n.helpFaqTitle,
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(
                widget.category.questions.length,
                (index) {
                  final faq = widget.category.questions[index];
                  final expanded = expandedIndex == index;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: expanded
                            ? neonBlue.withOpacity(.25)
                            : colors.border,
                      ),
                      boxShadow: expanded
                          ? [
                              BoxShadow(
                                color: neonBlue.withOpacity(.035),
                                blurRadius: 18,
                              ),
                            ]
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          setState(() {
                            expandedIndex = expanded ? null : index;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 17,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      faq.question,
                                      style: GoogleFonts.poppins(
                                        color: colors.primaryText,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    expanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    color: expanded
                                        ? neonBlue
                                        : colors.mutedText,
                                  ),
                                ],
                              ),
                              if (expanded) ...[
                                const SizedBox(height: 14),
                                Divider(color: colors.border),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    faq.answer,
                                    style: GoogleFonts.poppins(
                                      color: colors.secondaryText,
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 22),
              Text(
                l10n.helpStillNeed,
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.helpContactPrompt,
                style: GoogleFonts.poppins(
                  color: colors.secondaryText,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ContactSupportScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.mail_outline_rounded,
                    size: 20,
                  ),
                  label: Text(
                    l10n.contactSupport,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================================================================
// MODELS
// ===================================================================

class _HelpCategory {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<_FaqItem> questions;

  const _HelpCategory({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.questions,
  });
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem(this.question, this.answer);
}
