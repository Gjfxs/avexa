import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme.dart';
import '../l10n/app_localizations.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() =>
      _ContactSupportScreenState();
}

class _ContactSupportScreenState
    extends State<ContactSupportScreen> {
  final supabase = Supabase.instance.client;

  final TextEditingController messageController =
      TextEditingController();

  final TextEditingController customTopicController =
      TextEditingController();

  final List<String> topics = [
    'Account',
    'Subscription & Billing',
    'Trading Signals',
    'Technical Issue',
    'Bug Report',
    'Feature Request',
    'Other',
  ];

  String? selectedTopic;

  bool isSending = false;

  @override
  void dispose() {
    messageController.dispose();
    customTopicController.dispose();
    super.dispose();
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> _sendMessage() async {
    final l10n = AppLocalizations.of(context)!;

    final user = supabase.auth.currentUser;

    if (user == null) {
      _showMessage(
        l10n.supportLoginRequired,
      );
      return;
    }

    if (selectedTopic == null) {
      _showMessage(
        l10n.supportSelectTopicError,
      );
      return;
    }

    if (selectedTopic == 'Other' &&
        customTopicController.text.trim().isEmpty) {
      _showMessage(
        l10n.supportEnterTopicError,
      );
      return;
    }

    final message = messageController.text.trim();

    if (message.isEmpty) {
      _showMessage(
        l10n.supportEnterMessageError,
      );
      return;
    }

    if (message.length < 10) {
      _showMessage(
        l10n.supportMessageMinLengthError,
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

      await supabase
          .from('support_messages')
          .insert({
        'user_id': user.id,
        'email': user.email,
        'username': username,
        'topic': selectedTopic,
        'custom_topic':
            selectedTopic == 'Other'
                ? customTopicController.text.trim()
                : null,
        'message': message,
      });


      final emailResponse = await supabase.functions.invoke(
        'contact_support_email',
        body: {
          'topic': selectedTopic!,
          'custom_topic': selectedTopic == 'Other'
              ? customTopicController.text.trim()
              : '',
          'message': message,
        },
      );

      if (emailResponse.status < 200 ||
          emailResponse.status >= 300 ||
          emailResponse.data is! Map ||
          emailResponse.data['success'] != true) {
        throw Exception(
          'Support email failed: ${emailResponse.data}',
        );
      }

      debugPrint('SUPPORT EMAIL: Sent successfully.');


      if (!mounted) return;

      setState(() {
        isSending = false;
      });

      await _showSuccessDialog();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isSending = false;
      });

      _showMessage(
        l10n.supportSendError,
      );

      debugPrint(
        'SUPPORT MESSAGE ERROR: $error',
      );
    }
  }

  // ============================================================
  // SUCCESS DIALOG
  // ============================================================

  Future<void> _showSuccessDialog() async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: borderColor,
            ),
          ),
          contentPadding: const EdgeInsets.all(28),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: neonBlue.withOpacity(.10),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: neonBlue.withOpacity(.22),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: neonBlue.withOpacity(.10),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: neonBlue,
                  size: 34,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                l10n.supportMessageSent,
                style: GoogleFonts.poppins(
                  color: textPrimary,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                l10n.supportSuccessDescription,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor:
                        neonBlue.withOpacity(.30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n.supportDone,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(
            color: textPrimary,
          ),
        ),
        backgroundColor: cardElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: borderColor,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: textPrimary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          l10n.contactSupport,
          style: GoogleFonts.poppins(
            color: textPrimary,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            24,
            16,
            24,
            40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ========================================================
              // INTRO
              // ========================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: cardDark,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: borderColor,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: neonBlue.withOpacity(.05),
                      blurRadius: 22,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [

                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: neonBlue.withOpacity(.10),
                        borderRadius:
                            BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              neonBlue.withOpacity(.20),
                        ),
                      ),
                      child: const Icon(
                        Icons.mail_outline_rounded,
                        color: neonBlue,
                        size: 27,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          Text(
                            l10n.supportIntroTitle,
                            style: GoogleFonts.poppins(
                              color: textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            l10n.supportIntroSubtitle,
                            style: GoogleFonts.poppins(
                              color: textSecondary,
                              fontSize: 12,
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

              // ========================================================
              // TOPIC
              // ========================================================

              _sectionTitle(l10n.supportTopicQuestion),

              const SizedBox(height: 14),

              GestureDetector(
                onTap: _showTopicPicker,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 19,
                  ),
                  decoration: BoxDecoration(
                    color: cardDark,
                    borderRadius:
                        BorderRadius.circular(20),
                    border: Border.all(
                      color: selectedTopic != null
                          ? neonBlue.withOpacity(.35)
                          : borderColor,
                    ),
                    boxShadow: selectedTopic != null
                        ? [
                            BoxShadow(
                              color:
                                  neonBlue.withOpacity(.05),
                              blurRadius: 16,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [

                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: neonBlue.withOpacity(.10),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                neonBlue.withOpacity(.18),
                          ),
                        ),
                        child: const Icon(
                          Icons.help_outline_rounded,
                          color: neonBlue,
                          size: 22,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            Text(
                              selectedTopic == null ?
                              l10n.supportSelectTopic :
                              _topicLabel(selectedTopic!,
                              l10n),
                              style: GoogleFonts.poppins(
                                color: selectedTopic != null
                                    ? textPrimary
                                    : textSecondary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            if (selectedTopic != null &&
                                selectedTopic != 'Other')
                              const SizedBox(height: 3),

                            if (selectedTopic != null &&
                                selectedTopic != 'Other')
                              Text(
                                l10n.supportTapToChange,
                                style: GoogleFonts.poppins(
                                  color: textMuted,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.chevron_right_rounded,
                        color: textMuted,
                        size: 27,
                      ),
                    ],
                  ),
                ),
              ),

              // ========================================================
              // CUSTOM TOPIC
              // ========================================================

              if (selectedTopic == 'Other') ...[
                const SizedBox(height: 16),

                _sectionTitle(l10n.supportYourTopic),

                const SizedBox(height: 12),

                _textField(
                  controller: customTopicController,
                  hint: l10n.supportCustomTopicHint,
                  maxLines: 1,
                ),
              ],

              const SizedBox(height: 32),

              // ========================================================
              // MESSAGE
              // ========================================================

              _sectionTitle(l10n.supportMessage),

              const SizedBox(height: 14),

              _textField(
                controller: messageController,
                hint: l10n.supportMessageHint,
                maxLines: 7,
              ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: ValueListenableBuilder(
                  valueListenable: messageController,
                  builder: (context, value, child) {
                    return Text(
                      '${messageController.text.length} / 1000',
                      style: GoogleFonts.poppins(
                        color: textMuted,
                        fontSize: 11,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              // ========================================================
              // SEND
              // ========================================================

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      isSending ? null : _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonBlue,
                    disabledBackgroundColor:
                        neonBlue.withOpacity(.30),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor:
                        neonBlue.withOpacity(.25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: isSending
                      ? Text(
                          l10n.supportSending,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : Text(
                          l10n.supportSendMessage,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .4,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: Text(
                  l10n.supportResponseTime,
                  style: GoogleFonts.poppins(
                    color: textMuted,
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

  // ============================================================
  // SECTION TITLE
  // ============================================================

  String _topicLabel(String topic, AppLocalizations l10n) {
    switch (topic) {
      case 'Account':
        return l10n.supportAccount;
      case 'Subscription & Billing':
        return l10n.supportSubscriptionBilling;
      case 'Trading Signals':
        return l10n.supportTradingSignals;
      case 'Technical Issue':
        return l10n.supportTechnicalIssue;
      case 'Bug Report':
        return l10n.supportBugReport;
      case 'Feature Request':
        return l10n.supportFeatureRequest;
      case 'Other':
        return l10n.supportOther;
      default:
        return topic;
    }
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.3,
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLines > 1 ? 1000 : null,
      style: GoogleFonts.poppins(
        color: textPrimary,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: textMuted,
          fontSize: 14,
        ),
        counterText: '',
        filled: true,
        fillColor: cardDark,
        contentPadding: const EdgeInsets.all(18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: neonBlue.withOpacity(.45),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TOPIC PICKER
  // ============================================================

  void _showTopicPicker() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            24,
            14,
            24,
            30,
          ),
          decoration: const BoxDecoration(
            color: Color(0xff10151F),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 22),

              Text(
                l10n.supportTopicQuestion,
                style: GoogleFonts.poppins(
                  color: textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              ...topics.map(
                (topic) => _topicOption(topic),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // TOPIC OPTION
  // ============================================================

  Widget _topicOption(String topic) {
    final selected = selectedTopic == topic;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTopic = topic;
        });

        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: selected
              ? neonBlue.withOpacity(.10)
              : cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? neonBlue.withOpacity(.35)
                : borderColor,
          ),
        ),
        child: Row(
          children: [

            Expanded(
              child: Text(
                _topicLabel(
                  topic,
                  AppLocalizations.of(context)!,
                ),
                style: GoogleFonts.poppins(
                  color: textPrimary,
                  fontSize: 14,
                  fontWeight: selected
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),

            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: neonBlue,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}