import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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

        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: colors.primaryText,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          'Privacy Policy',
          style: GoogleFonts.poppins(
            color: colors.primaryText,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            24,
            20,
            24,
            50,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

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
                      color: neonBlue.withOpacity(.05),
                      blurRadius: 22,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: neonBlue.withOpacity(.10),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: neonBlue.withOpacity(.20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: neonBlue.withOpacity(.08),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: neonBlue,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          Text(
                            'Your privacy matters',
                            style: GoogleFonts.poppins(
                              color: colors.primaryText,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'We are committed to protecting your personal information and keeping your data secure.',
                            style: GoogleFonts.poppins(
                              color: colors.secondaryText,
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  neonBlue.withOpacity(.08),
                              borderRadius:
                                  BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    neonBlue.withOpacity(.18),
                              ),
                            ),
                            child: Text(
                              'Last updated: September 2026',
                              style: GoogleFonts.poppins(
                                color: neonBlue,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              _section(
                title: '1. Introduction',
                text:
                    'This Privacy Policy explains how Avexa collects, uses, stores and protects information when you use the Avexa application and its services.',
                colors: colors,
              ),

              _section(
                title: '2. Information We Collect',
                text:
                    'Depending on how you use Avexa, we may collect information such as your email address, account information, profile information, avatar, subscription status and information you voluntarily provide when contacting our support team.',
                colors: colors,
              ),

              _section(
                title: '3. How We Use Your Information',
                text:
                    'We use collected information to provide and maintain Avexa, authenticate your account, provide access to features, manage subscriptions, respond to support requests, investigate bug reports, improve the application and maintain the security of our services.',
                colors: colors,
              ),

              _section(
                title: '4. Account Information',
                text:
                    'When you create or use an Avexa account, information associated with your account may be stored in order to provide authentication and account-related functionality. This may include your email address, username, profile information and subscription status.',
                colors: colors,
              ),

              _section(
                title: '5. Support & Bug Reports',
                text:
                    'If you contact Avexa Support or submit a bug report, we may store the information you provide, including the content of your message and information associated with your account. This information is used to respond to your request and improve the application.',
                colors: colors,
              ),

              _section(
                title: '6. App & Usage Data',
                text:
                    'We may process technical and usage information necessary to operate, secure and improve Avexa. This can include information about application functionality, errors and interactions with our services.',
                colors: colors,
              ),

              _section(
                title: '7. Data Security',
                text:
                    'We take reasonable technical and organizational measures to protect information against unauthorized access, alteration, disclosure or destruction. However, no internet-based service can guarantee absolute security.',
                colors: colors,
              ),

              _section(
                title: '8. Third-Party Services',
                text:
                    'Avexa may rely on trusted third-party services to provide certain functionality, such as authentication, cloud data storage, analytics or other application services. These providers may process information only as necessary to provide their services.',
                colors: colors,
              ),

              _section(
                title: '9. Data Retention',
                text:
                    'We retain information for as long as reasonably necessary to provide our services, maintain account functionality, comply with legal obligations, resolve disputes and enforce our agreements.',
                colors: colors,
              ),

              _section(
                title: '10. Your Rights',
                text:
                    'Depending on your location and applicable law, you may have rights regarding your personal information, including the right to request access, correction or deletion of certain information. You may contact us to exercise applicable rights.',
                colors: colors,
              ),

              _section(
                title: '11. Changes to This Policy',
                text:
                    'We may update this Privacy Policy from time to time. When changes are made, the updated version will be made available through Avexa and the updated date will be shown at the top of this policy.',
                colors: colors,
              ),

              const SizedBox(height: 8),

              Text(
                '12. Contact Us',
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'If you have questions about this Privacy Policy or how your information is handled, please contact the Avexa support team through the Contact Support section of the application.',
                style: GoogleFonts.poppins(
                  color: colors.secondaryText,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 36),

              Center(
                child: Column(
                  children: [

                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: neonBlue.withOpacity(.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: neonBlue.withOpacity(.18),
                        ),
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        color: neonBlue,
                        size: 24,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Avexa',
                      style: GoogleFonts.poppins(
                        color: colors.primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Your data. Your privacy.',
                      style: GoogleFonts.poppins(
                        color: colors.mutedText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section({
    required String title,
    required String text,
    required AvexaColors colors,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: GoogleFonts.poppins(
              color: colors.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            text,
            style: GoogleFonts.poppins(
              color: colors.secondaryText,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}