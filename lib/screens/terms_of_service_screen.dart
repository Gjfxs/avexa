import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<AvexaColors>()!;

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
          'Terms of Service',
          style: GoogleFonts.poppins(
            color: textPrimary,
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

              // =========================================================
              // HEADER
              // =========================================================

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
                        Icons.description_outlined,
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
                            'Terms of Service',
                            style: GoogleFonts.poppins(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'Please read these terms before using Avexa.',
                            style: GoogleFonts.poppins(
                              color: textSecondary,
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

              // =========================================================
              // 1
              // =========================================================

              _section(
                title: '1. Acceptance of Terms',
                text:
                    'By creating an account or using Avexa, you agree to these Terms of Service. If you do not agree with these terms, you should not use the application or its services.',
              ),

              // =========================================================
              // 2
              // =========================================================

              _section(
                title: '2. About Avexa',
                text:
                    'Avexa is a cryptocurrency market intelligence platform that provides market data, trading signals, AI-powered analysis, market insights and other tools designed to help users analyze cryptocurrency markets.',
              ),

              // =========================================================
              // 3
              // =========================================================

              _section(
                title: '3. User Accounts',
                text:
                    'You are responsible for maintaining the security of your account and login credentials. You should not share your account credentials with other people or use another person’s account without authorization.',
              ),

              // =========================================================
              // 4
              // =========================================================

              _section(
                title: '4. Avexa PRO',
                text:
                    'Avexa may offer premium features through a paid subscription known as Avexa PRO. PRO may provide access to additional signals, market intelligence, wallet tracking and other premium functionality.',
              ),

              // =========================================================
              // 5
              // =========================================================

              _section(
                title: '5. Subscriptions & Payments',
                text:
                    'Paid subscriptions may automatically renew according to the subscription period selected by the user unless cancelled before the applicable renewal date. Subscription prices, billing periods and available plans are presented at the time of purchase.',
              ),

              // =========================================================
              // 6
              // =========================================================

              _section(
                title: '6. Cancellation',
                text:
                    'You may cancel your subscription according to the cancellation options provided by the platform through which the subscription was purchased. Cancellation does not necessarily provide a refund for a billing period that has already started, except where required by applicable law or the applicable platform’s policies.',
              ),

              // =========================================================
              // 7
              // =========================================================

              _section(
                title: '7. Trading Signals & Market Information',
                text:
                    'Avexa may provide trading signals, entry levels, take-profit levels, stop-loss levels, market forecasts, AI-generated analysis and other cryptocurrency-related information. This information is provided for informational and educational purposes only.',
              ),

              // =========================================================
              // INVESTMENT DISCLAIMER
              // =========================================================

              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 28),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: neonYellow.withOpacity(.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: neonYellow.withOpacity(.20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [

                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color:
                                neonYellow.withOpacity(.10),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  neonYellow.withOpacity(.20),
                            ),
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            color: neonYellow,
                            size: 21,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Text(
                          'IMPORTANT',
                          style: GoogleFonts.poppins(
                            color: neonYellow,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Avexa does not guarantee profits or the accuracy of any signal, forecast or analysis. Cryptocurrency trading involves significant risk, including the possible loss of some or all of your capital.',
                      style: GoogleFonts.poppins(
                        color: textSecondary,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Nothing provided through Avexa should be considered personalized investment, financial or trading advice. Users are responsible for their own trading and investment decisions.',
                      style: GoogleFonts.poppins(
                        color: textSecondary,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              // =========================================================
              // 8
              // =========================================================

              _section(
                title: '8. AI-Generated Information',
                text:
                    'Some information provided by Avexa may be generated or assisted by artificial intelligence. AI-generated information may contain errors, omissions or inaccuracies. Users should independently evaluate information before making any financial or trading decision.',
              ),

              // =========================================================
              // 9
              // =========================================================

              _section(
                title: '9. Cryptocurrency Risk',
                text:
                    'Cryptocurrency markets can be highly volatile and unpredictable. Market prices may change rapidly and trading may result in substantial losses. Past performance does not guarantee future results.',
              ),

              // =========================================================
              // 10
              // =========================================================

              _section(
                title: '10. Prohibited Use',
                text:
                    'You may not use Avexa for unlawful activities, attempt to gain unauthorized access to the application or its systems, interfere with the operation of the service, abuse or manipulate the service, or use the platform in a way that may harm Avexa or other users.',
              ),

              // =========================================================
              // 11
              // =========================================================

              _section(
                title: '11. Intellectual Property',
                text:
                    'The Avexa application, brand, design, software, content and related materials are protected by applicable intellectual property laws. You may not copy, reproduce, distribute, modify or commercially exploit Avexa content without appropriate authorization.',
              ),

              // =========================================================
              // 12
              // =========================================================

              _section(
                title: '12. Service Availability',
                text:
                    'We aim to keep Avexa available and reliable, but we do not guarantee uninterrupted or error-free operation. The service may occasionally be unavailable due to maintenance, technical problems, third-party services or circumstances outside our control.',
              ),

              // =========================================================
              // 13
              // =========================================================

              _section(
                title: '13. Limitation of Liability',
                text:
                    'To the maximum extent permitted by applicable law, Avexa and its operators shall not be responsible for losses resulting from trading decisions, market movements, inaccurate information, service interruptions, technical failures or reliance on information provided through the application.',
              ),

              // =========================================================
              // 14
              // =========================================================

              _section(
                title: '14. Changes to the Service',
                text:
                    'We may modify, add or remove features of Avexa from time to time. We may also change the availability of particular features or services. Where appropriate, significant changes will be communicated through the application or other available channels.',
              ),

              // =========================================================
              // 15
              // =========================================================

              _section(
                title: '15. Changes to These Terms',
                text:
                    'We may update these Terms of Service from time to time. Updated terms will be made available through Avexa and the updated date will be shown at the top of this document.',
              ),

              // =========================================================
              // 16
              // =========================================================

              _section(
                title: '16. Termination',
                text:
                    'We may suspend or terminate access to Avexa if a user violates these Terms of Service, abuses the service or engages in activity that may harm the application, its users or its infrastructure.',
              ),

              // =========================================================
              // 17
              // =========================================================

              _section(
                title: '17. Contact',
                text:
                    'If you have questions regarding these Terms of Service, you can contact the Avexa support team through the Contact Support section of the application.',
              ),

              const SizedBox(height: 10),

              // =========================================================
              // FOOTER
              // =========================================================

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
                        Icons.verified_user_outlined,
                        color: neonBlue,
                        size: 24,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Avexa',
                      style: GoogleFonts.poppins(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Trade smarter. Stay informed.',
                      style: GoogleFonts.poppins(
                        color: textMuted,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      '© 2026 Avexa',
                      style: GoogleFonts.poppins(
                        color: textMuted,
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

  // ===============================================================
  // SECTION
  // ===============================================================

  Widget _section({
    required String title,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: GoogleFonts.poppins(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            text,
            style: GoogleFonts.poppins(
              color: textSecondary,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}