import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';
import '../l10n/app_localizations.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class ReportBugScreen extends StatefulWidget {
  const ReportBugScreen({super.key});

  @override
  State<ReportBugScreen> createState() => _ReportBugScreenState();
}

class _ReportBugScreenState extends State<ReportBugScreen> {
  final _descriptionController = TextEditingController();

  final supabase = Supabase.instance.client;

  String selectedCategory = 'App Bug';
  bool isSending = false;

  final List<String> categories = [
    'App Bug',
    'Signals',
    'Trading',
    'Account',
    'Subscription',
    'Notifications',
    'Other',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  
  Future<void> _submitBug() async {
    final description = _descriptionController.text.trim();

    if (description.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least 10 characters.'),
        ),
      );
      return;
    }

    if (description.length > 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Description cannot exceed 1000 characters.'),
        ),
      );
      return;
    }

    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to report a bug.'),
        ),
      );
      return;
    }

    setState(() {
      isSending = true;
    });

    try {
      final profile = await supabase
          .from('profiles')
          .select('username')
          .eq('id', user.id)
          .maybeSingle();

      final username =
          profile?['username'] ??
          user.email?.split('@').first ??
          'User';

      // Step 1: Save the report in Supabase.
      await supabase.from('support_messages').insert({
        'user_id': user.id,
        'email': user.email,
        'username': username,
        'topic': 'Bug Report',
        'custom_topic': selectedCategory,
        'message': description,
      });

      // Step 2: Send the email.
      final emailResponse = await supabase.functions.invoke(
        'contact_support_email',
        body: {
          'topic': 'Bug Report',
          'custom_topic': selectedCategory,
          'message': description,
        },
      );

      final responseData = emailResponse.data;

      if (emailResponse.status < 200 ||
          emailResponse.status >= 300 ||
          responseData is! Map ||
          responseData['success'] != true) {
        throw Exception(
          responseData is Map
              ? responseData['error'] ?? 'Email delivery failed.'
              : 'Invalid response from support server.',
        );
      }

      debugPrint('BUG REPORT: Saved and email sent successfully.');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bug report sent successfully.'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint('BUG REPORT ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send report: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSending = false;
        });
      }
    }
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: colors.primaryText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.reportBug,
          style: GoogleFonts.poppins(
            color: colors.primaryText,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colors.border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: neonBlue.withOpacity(.07),
                      blurRadius: 24,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: neonBlue.withOpacity(.10),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: neonBlue.withOpacity(.15),
                        ),
                      ),
                      child: const Icon(
                        Icons.bug_report_outlined,
                        color: neonBlue,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.bugIntroTitle,
                            style: GoogleFonts.poppins(
                              color: colors.primaryText,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            l10n.bugIntroSubtitle,
                            style: GoogleFonts.poppins(
                              color: colors.secondaryText,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // CATEGORY
              Text(
                l10n.bugCategorySection,
                style: GoogleFonts.poppins(
                  color: colors.secondaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: _showCategoryPicker,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: colors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.category_outlined,
                        color: neonBlue,
                        size: 22,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          _categoryLabel(selectedCategory, l10n),
                          style: GoogleFonts.poppins(
                            color: colors.primaryText,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: colors.secondaryText,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // DESCRIPTION
              Text(
                l10n.bugWhatHappened,
                style: GoogleFonts.poppins(
                  color: colors.secondaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.border,
                  ),
                ),
                child: TextField(
                  controller: _descriptionController,
                  minLines: 7,
                  maxLines: 12,
                  style: TextStyle(
                    color: colors.primaryText,
                    fontSize: 15,
                  ),
                  cursorColor: neonBlue,
                  decoration: InputDecoration(
                    hintText:
                        l10n.bugDescriptionHint,
                    hintStyle: TextStyle(
                      color: colors.mutedText,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.all(18),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // SEND
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isSending ? null : _submitBug,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        neonBlue.withOpacity(.4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: isSending
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.send_rounded,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              l10n.bugSendButton,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 14),

              Center(
                child: Text(
                  l10n.bugFooter,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: colors.mutedText,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryLabel(
    String category,
    AppLocalizations l10n,
  ) {
    switch (category) {
      case 'App Bug':
        return l10n.bugCategoryApp;
      case 'Signals':
        return l10n.bugCategorySignals;
      case 'Trading':
        return l10n.bugCategoryTrading;
      case 'Account':
        return l10n.bugCategoryAccount;
      case 'Subscription':
        return l10n.bugCategorySubscription;
      case 'Notifications':
        return l10n.bugCategoryNotifications;
      case 'Other':
        return l10n.bugCategoryOther;
      default:
        return category;
    }
  }

  void _showCategoryPicker() {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final colors =
            Theme.of(context).extension<AvexaColors>()!;

        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.fromLTRB(
                24,
                14,
                24,
                30,
              ),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius:
                    const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 22),

                  Text(
                    l10n.bugPickerTitle,
                    style: GoogleFonts.poppins(
                      color: colors.primaryText,
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      physics:
                          const BouncingScrollPhysics(),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category =
                            categories[index];

                        final isSelected =
                            selectedCategory ==
                                category;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory =
                                  category;
                            });

                            Navigator.pop(context);
                          },
                          child: Container(
                            width: double.infinity,
                            margin:
                                const EdgeInsets.only(
                              bottom: 10,
                            ),
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? neonBlue
                                      .withOpacity(.10)
                                  : colors
                                      .elevatedCard,
                              borderRadius:
                                  BorderRadius.circular(
                                16,
                              ),
                              border: Border.all(
                                color: isSelected
                                    ? neonBlue
                                        .withOpacity(.35)
                                    : colors.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _categoryLabel(
                                      category,
                                      AppLocalizations.of(context)!,
                                    ),
                                    style:
                                        GoogleFonts.poppins(
                                      color: colors
                                          .primaryText,
                                      fontSize: 14,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight
                                                  .w600
                                              : FontWeight
                                                  .w400,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: neonBlue,
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
            );
          },
        );
      },
    );
  }
}