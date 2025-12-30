import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
// IMPORT your new theme provider here
import '../../../../core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  bool _notificationsEnabled = true;
  bool _biometricsEnabled = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimations = List.generate(4, (index) {
      return Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(index * 0.15, 1.0, curve: Curves.easeOutCubic),
        ),
      );
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(authStateProvider.notifier).logout();
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    // Watch the global theme mode
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAnimatedSection(index: 0, child: _buildProfileSection(user)),
              const SizedBox(height: AppSpacing.lg),
              _buildAnimatedSection(index: 1, child: _buildPreferencesSection(themeMode)),
              const SizedBox(height: AppSpacing.lg),
              _buildAnimatedSection(index: 2, child: _buildSecuritySection()),
              const SizedBox(height: AppSpacing.lg),
              _buildAnimatedSection(index: 3, child: _buildAccountSection()),
              const SizedBox(height: AppSpacing.xl),
              Center(child: Text('Version 1.0.0', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary))),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSection({required int index, required Widget child}) {
    return SlideTransition(position: _slideAnimations[index], child: child);
  }

  Widget _buildProfileSection(user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle
              ),
              child: const Icon(Icons.person, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(user?.fullName ?? 'User', style: AppTextStyles.headingMedium),
            Text(
                user?.email ?? 'email@example.com',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection(ThemeMode currentMode) {
    return _buildSettingsCard(title: 'Preferences', children: [
      _buildSwitchTile(
          'Notifications',
          'Trip updates',
          Icons.notifications_outlined,
          _notificationsEnabled,
              (v) => setState(() => _notificationsEnabled = v)
      ),
      const Divider(),
      _buildSwitchTile(
          'Dark Mode',
          currentMode == ThemeMode.dark ? 'Enabled' : 'Disabled',
          Icons.dark_mode_outlined,
          currentMode == ThemeMode.dark,
              (v) {
            // Update the global provider
            ref.read(themeModeProvider.notifier).state = v ? ThemeMode.dark : ThemeMode.light;
          }
      ),
    ]);
  }

  Widget _buildSecuritySection() {
    return _buildSettingsCard(title: 'Security', children: [
      _buildSwitchTile(
          'Biometrics',
          'Face ID/Fingerprint',
          Icons.fingerprint,
          _biometricsEnabled,
              (v) => setState(() => _biometricsEnabled = v)
      ),
    ]);
  }

  Widget _buildAccountSection() {
    return _buildSettingsCard(title: 'Account', children: [
      _buildNavigationTile('Help & Support', 'Get help', Icons.help_outline, () {}),
      const Divider(),
      _buildNavigationTile(
          'Logout',
          'Sign out',
          Icons.logout,
          _handleLogout,
          iconColor: AppColors.error,
          titleColor: AppColors.error
      ),
    ]);
  }

  Widget _buildSettingsCard({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(left: AppSpacing.sm),
            child: Text(title, style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary))
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(child: Column(children: children)),
      ],
    );
  }

  Widget _buildSwitchTile(String t, String s, IconData i, bool v, ValueChanged<bool> c) {
    return SwitchListTile(
        value: v,
        onChanged: c,
        activeColor: AppColors.primary,
        title: Text(t, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        subtitle: Text(s, style: const TextStyle(color: AppColors.textSecondary)),
        secondary: Icon(i, color: AppColors.primary)
    );
  }

  Widget _buildNavigationTile(String t, String s, IconData i, VoidCallback o, {Color? iconColor, Color? titleColor}) {
    return ListTile(
        leading: Icon(i, color: iconColor ?? AppColors.primary),
        title: Text(t, style: TextStyle(color: titleColor ?? Theme.of(context).colorScheme.onSurface)),
        subtitle: Text(s, style: const TextStyle(color: AppColors.textSecondary)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
        onTap: o
    );
  }
}