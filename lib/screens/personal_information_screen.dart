import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme.dart';
import '../l10n/app_localizations.dart';
import '../services/avatar_service.dart';
import '../widgets/avatar_picker_sheet.dart';
import '../services/account_deletion_service.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState
    extends State<PersonalInformationScreen> {
  final supabase = Supabase.instance.client;

  final nameController = TextEditingController();
  final usernameController = TextEditingController();

  String email = '';
  String? avatarUrl;
  String userPlan = 'Free';

  bool loading = true;
  bool saving = false;
  bool avatarSaving = false;
  bool deletingAccount = false;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // LOAD PROFILE

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => loading = false);
      return;
    }

    try {
      email = user.email ?? '';

      final profile = await supabase
          .from('profiles')
          .select('username, avatar_url, plan')
          .eq('id', user.id)
          .maybeSingle();

      final fullName =
          user.userMetadata?['full_name'] ??
          user.userMetadata?['name'] ??
          user.email?.split('@').first ??
          l10n.personalInfoDefaultUser;

      if (!mounted) return;

      setState(() {
        nameController.text = fullName.toString();
        usernameController.text =
            profile?['username']?.toString() ??
            user.email?.split('@').first ??
            '';
        avatarUrl = profile?['avatar_url']?.toString();
        userPlan = profile?['plan']?.toString() ?? 'Free';
        loading = false;
      });
    } catch (e) {
      debugPrint('PERSONAL PROFILE LOAD ERROR: $e');

      if (!mounted) return;

      setState(() => loading = false);
      _showMessage(l10n.personalInfoLoadError);
    }
  }

  // AVATAR

  Future<void> _openAvatarPicker() async {
    if (avatarSaving) return;

    final selectedAvatar = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AvatarPickerSheet(
        isPremium: userPlan.toLowerCase() == 'pro',
      ),
    );

    if (selectedAvatar == null || !mounted) return;

    setState(() => avatarSaving = true);

    try {
      debugPrint('PERSONAL SELECTED AVATAR: $selectedAvatar');

      final savedAvatar = await AvatarService.saveAvatar(
        selectedAvatar,
      );

      debugPrint('PERSONAL SAVED AVATAR: $savedAvatar');

      if (savedAvatar == null) {
        if (!mounted) return;
        _showMessage(l10n.personalInfoAvatarSaveError);
        return;
      }

      if (!mounted) return;

      setState(() => avatarUrl = savedAvatar);
      _showMessage(l10n.personalInfoAvatarUpdated);
    } catch (e) {
      debugPrint('PERSONAL AVATAR ERROR: $e');

      if (!mounted) return;
      _showMessage(l10n.personalInfoAvatarUpdateError);
    } finally {
      if (mounted) {
        setState(() => avatarSaving = false);
      }
    }
  }

  // SAVE PROFILE

  Future<void> _saveProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final name = nameController.text.trim();
    final username = usernameController.text.trim();

    if (name.isEmpty) {
      _showMessage(l10n.personalInfoNameRequired);
      return;
    }

    if (username.isEmpty) {
      _showMessage(l10n.personalInfoUsernameRequired);
      return;
    }

    if (username.length < 3) {
      _showMessage(l10n.personalInfoUsernameLengthError);
      return;
    }

    setState(() => saving = true);

    try {
      await supabase
          .from('profiles')
          .update({'username': username})
          .eq('id', user.id);

      await supabase.auth.updateUser(
        UserAttributes(
          data: {'full_name': name},
        ),
      );

      if (!mounted) return;

      Navigator.pop(context, username);
    } catch (e) {
      debugPrint('PROFILE UPDATE ERROR: $e');

      if (!mounted) return;
      _showMessage(l10n.personalInfoUpdateError);
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  // DELETE ACCOUNT

  Future<void> _deleteAccount() async {
    if (deletingAccount || saving || avatarSaving) return;

    final colors = Theme.of(context).extension<AvexaColors>()!;

    // FIRST CONFIRMATION

    final firstConfirmation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: colors.border),
        ),
        title: Text(
          l10n.deleteAccountWarningTitle,
          style: GoogleFonts.poppins(
            color: colors.primaryText,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.deleteAccountWarningDescription,
              style: GoogleFonts.poppins(
                color: colors.secondaryText,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            if (userPlan.toLowerCase() == 'pro') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withOpacity(.25),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Colors.redAccent,
                      size: 19,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.deleteAccountSubscriptionWarning,
                        style: GoogleFonts.poppins(
                          color: colors.secondaryText,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: Text(
              l10n.deleteAccountCancel,
              style: GoogleFonts.poppins(
                color: colors.secondaryText,
              ),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: Text(
              l10n.deleteAccountButton,
              style: GoogleFonts.poppins(
                color: Colors.redAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (firstConfirmation != true || !mounted) return;

    // SECOND CONFIRMATION

    final confirmationController = TextEditingController();
    bool canConfirm = false;

    final secondConfirmation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, updateDialog) => AlertDialog(
          backgroundColor: colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: colors.border),
          ),
          title: Text(
            l10n.deleteAccountConfirmTitle,
            style: GoogleFonts.poppins(
              color: colors.primaryText,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.deleteAccountConfirmDescription,
                style: GoogleFonts.poppins(
                  color: colors.secondaryText,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: confirmationController,
                autofocus: true,
                cursorColor: neonBlue,
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: l10n.deleteAccountConfirmHint,
                  hintStyle: GoogleFonts.poppins(
                    color: colors.mutedText,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: colors.elevatedCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Colors.redAccent,
                    ),
                  ),
                ),
                onChanged: (value) {
                  updateDialog(() {
                    canConfirm = value == 'DELETE';
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: Text(
                l10n.deleteAccountCancel,
                style: GoogleFonts.poppins(
                  color: colors.secondaryText,
                ),
              ),
            ),
            TextButton(
              onPressed: canConfirm
                  ? () => Navigator.pop(dialogContext, true)
                  : null,
              child: Text(
                l10n.deleteAccountConfirmButton,
                style: GoogleFonts.poppins(
                  color: canConfirm
                      ? Colors.redAccent
                      : colors.mutedText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    confirmationController.dispose();

    if (secondConfirmation != true || !mounted) return;

    // DELETE ACCOUNT

    setState(() => deletingAccount = true);

    bool deletionSucceeded = false;

    try {
      await AccountDeletionService.instance.deleteAccount();

      deletionSucceeded = true;

      if (!mounted) return;

      debugPrint(
        'ACCOUNT DELETION: SUCCESS - CLEARING NAVIGATION STACK',
      );

      // Return to the root route.
      // AuthGate will display LoginScreen because
      // the local Supabase session has been removed.

      Navigator.of(
        context,
        rootNavigator: true,
      ).popUntil((route) => route.isFirst);

    } catch (e) {
      debugPrint('ACCOUNT DELETION ERROR: $e');

      if (!mounted) return;

      _showMessage(l10n.deleteAccountError);

    } finally {
      // Do not update state after successful navigation.
      if (mounted && !deletionSucceeded) {
        setState(() => deletingAccount = false);
      }
    }
  }


  // MESSAGE

  void _showMessage(String message) {
    final colors = Theme.of(context).extension<AvexaColors>()!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(
            color: colors.primaryText,
            fontSize: 13,
          ),
        ),
        backgroundColor: colors.elevatedCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colors.border),
        ),
      ),
    );
  }

  // DISPOSE

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  // BUILD

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AvexaColors>()!;

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
          l10n.personalInfoTitle,
          style: GoogleFonts.poppins(
            color: colors.primaryText,
            fontWeight: FontWeight.w600,
            fontSize: 19,
          ),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: neonBlue),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PROFILE HEADER

                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: avatarSaving ? null : _openAvatarPicker,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: neonBlue.withOpacity(.20),
                                  blurRadius: 35,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  width: 112,
                                  height: 112,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: neonBlue.withOpacity(.40),
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: _buildAvatar(colors),
                                  ),
                                ),
                                Positioned(
                                  right: 1,
                                  bottom: 1,
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: neonBlue,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: colors.background,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: neonBlue.withOpacity(.30),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: avatarSaving
                                        ? const Padding(
                                            padding: EdgeInsets.all(8),
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.photo_camera_rounded,
                                            color: Colors.white,
                                            size: 17,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.personalInfoTitle,
                          style: GoogleFonts.poppins(
                            color: colors.primaryText,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.personalInfoDescription,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: colors.secondaryText,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 38),

                  // PERSONAL DETAILS CARD

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: colors.border),
                      boxShadow: [
                        BoxShadow(
                          color: neonBlue.withOpacity(.035),
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle(
                          l10n.personalInfoDetailsSection,
                          colors,
                        ),
                        const SizedBox(height: 20),
                        _label(l10n.personalInfoDisplayName, colors),
                        const SizedBox(height: 10),
                        _textField(
                          colors: colors,
                          controller: nameController,
                          icon: Icons.person_outline_rounded,
                          hint: l10n.personalInfoNameHint,
                        ),
                        const SizedBox(height: 22),
                        _label(l10n.personalInfoUsername, colors),
                        const SizedBox(height: 10),
                        _textField(
                          colors: colors,
                          controller: usernameController,
                          icon: Icons.alternate_email_rounded,
                          hint: l10n.personalInfoUsernameHint,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.personalInfoUsernameDescription,
                          style: GoogleFonts.poppins(
                            color: colors.mutedText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // EMAIL CARD

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle(
                          l10n.personalInfoEmailSection,
                          colors,
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: colors.elevatedCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: colors.mutedText.withOpacity(.08),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: Icon(
                                  Icons.email_outlined,
                                  color: colors.secondaryText,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      email,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        color: colors.secondaryText,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      l10n.personalInfoVerifiedEmail,
                                      style: GoogleFonts.poppins(
                                        color: colors.mutedText,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.lock_outline_rounded,
                                color: colors.mutedText,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.personalInfoEmailCannotChange,
                          style: GoogleFonts.poppins(
                            color: colors.mutedText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // SAVE BUTTON

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: saving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: neonBlue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            neonBlue.withOpacity(.40),
                        elevation: 0,
                        shadowColor: neonBlue.withOpacity(.30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_rounded, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.personalInfoSaveChanges,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: .5,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Center(
                    child: Text(
                      l10n.personalInfoSecureSaveNotice,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: colors.mutedText,
                        fontSize: 10,
                      ),
                    ),
                  ),


                  const SizedBox(height: 42),

                  // DANGER ZONE

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(.035),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.red.withOpacity(.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.redAccent,
                              size: 17,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.deleteAccountSection,
                              style: GoogleFonts.poppins(
                                color: Colors.redAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        Text(
                          l10n.deleteAccountTitle,
                          style: GoogleFonts.poppins(
                            color: colors.primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 7),

                        Text(
                          l10n.deleteAccountDescription,
                          style: GoogleFonts.poppins(
                            color: colors.secondaryText,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: deletingAccount ||
                                    saving ||
                                    avatarSaving
                                ? null
                                : _deleteAccount,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              disabledForegroundColor:
                                  Colors.redAccent.withOpacity(.4),
                              side: BorderSide(
                                color: Colors.redAccent.withOpacity(.65),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: deletingAccount
                                ? const SizedBox(
                                    width: 21,
                                    height: 21,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.redAccent,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.delete_outline_rounded,
                                        size: 19,
                                      ),
                                      const SizedBox(width: 9),
                                      Text(
                                        l10n.deleteAccountButton,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: .4,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // AVATAR WIDGET

  Widget _buildAvatar(AvexaColors colors) {
    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return Container(
        color: colors.elevatedCard,
        child: Icon(
          Icons.person_rounded,
          color: colors.primaryText,
          size: 58,
        ),
      );
    }

    if (avatarUrl!.startsWith('http')) {
      return Image.network(
        avatarUrl!,
        width: 112,
        height: 112,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: colors.elevatedCard,
          child: Icon(
            Icons.person_rounded,
            color: colors.primaryText,
            size: 58,
          ),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return Container(
            color: colors.elevatedCard,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: neonBlue,
              ),
            ),
          );
        },
      );
    }

    return Image.asset(
      avatarUrl!,
      width: 112,
      height: 112,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: colors.elevatedCard,
        child: Icon(
          Icons.person_rounded,
          color: colors.primaryText,
          size: 58,
        ),
      ),
    );
  }

  // SECTION TITLE

  Widget _sectionTitle(String text, AvexaColors colors) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: colors.primaryText,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
    );
  }

  // LABEL

  Widget _label(String text, AvexaColors colors) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: colors.secondaryText,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }

  // TEXT FIELD

  Widget _textField({
    required AvexaColors colors,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      cursorColor: neonBlue,
      style: GoogleFonts.poppins(
        color: colors.primaryText,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: neonBlue, size: 21),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: colors.mutedText,
          fontSize: 14,
        ),
        filled: true,
        fillColor: colors.elevatedCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: neonBlue,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}