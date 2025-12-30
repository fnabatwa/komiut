import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen>
    with TickerProviderStateMixin {
  // Form key
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Loading state
  bool _isLoading = false;

  // Animation controllers for staggered effect
  late AnimationController _mainController;
  late List<AnimationController> _fieldControllers;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  /// staggered animations
  void _setupAnimations() {
    // Main controller for overall timing
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Create animation controllers for each field (4 fields)
    _fieldControllers = List.generate(
      4,
          (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    // Create slide animations for each field
    _slideAnimations = _fieldControllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, 0.3), // Start below
        end: Offset.zero,             // End at normal position
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic,
        ),
      );
    }).toList();

    // Create fade animations for each field
    _fadeAnimations = _fieldControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeIn,
        ),
      );
    }).toList();

    // Start animations with stagger effect
    _startStaggeredAnimations();
  }

  /// Start animations one after another
  void _startStaggeredAnimations() async {
    // Delay before starting (200ms)
    await Future.delayed(const Duration(milliseconds: 200));

    // Start each field animation with 100ms delay between them
    for (int i = 0; i < _fieldControllers.length; i++) {
      if (mounted) {
        _fieldControllers[i].forward();
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _mainController.dispose();
    for (var controller in _fieldControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Handle sign up button press
  Future<void> _handleSignUp() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Set loading state
    setState(() => _isLoading = true);

    // Attempt sign up
    final success = await ref.read(authStateProvider.notifier).signUp(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    // Stop loading
    if (mounted) {
      setState(() => _isLoading = false);
    }

    if (success) {
      // Sign up successful - navigate to 2FA
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/two-factor',
          arguments: {
            'email': _emailController.text.trim(),
            'password': _passwordController.text,
          },
        );
      }
    } else {
      // Sign up failed - email already exists
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email already registered. Please login.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.lg),

                // Header
                _buildHeader(),

                const SizedBox(height: AppSpacing.xxl),

                // Animated field 1: Full Name
                _buildAnimatedField(
                  index: 0,
                  child: CustomTextField(
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    controller: _fullNameController,
                    prefixIcon: Icons.person_outline,
                    validator: _validateFullName,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Animated field 2: Email
                _buildAnimatedField(
                  index: 1,
                  child: CustomTextField(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: _emailController,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Animated field 3: Password
                _buildAnimatedField(
                  index: 2,
                  child: CustomTextField(
                    label: 'Password',
                    hint: 'Create a password',
                    controller: _passwordController,
                    prefixIcon: Icons.lock_outlined,
                    isPassword: true,
                    validator: _validatePassword,
                    onChanged: (value) => setState(() {}), // Rebuild for strength indicator
                  ),
                ),

                // Password strength indicator
                if (_passwordController.text.isNotEmpty)
                  _buildPasswordStrengthIndicator(),

                const SizedBox(height: AppSpacing.md),

                // Animated field 4: Confirm Password
                _buildAnimatedField(
                  index: 3,
                  child: CustomTextField(
                    label: 'Confirm Password',
                    hint: 'Re-enter your password',
                    controller: _confirmPasswordController,
                    prefixIcon: Icons.lock_outlined,
                    isPassword: true,
                    validator: _validateConfirmPassword,
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Sign up button
                CustomButton(
                  text: 'Create Account',
                  onPressed: _handleSignUp,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build header
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: AppTextStyles.displayMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Sign up to get started with Komiut',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Build animated field with stagger effect
  Widget _buildAnimatedField({
    required int index,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(
        position: _slideAnimations[index],
        child: child,
      ),
    );
  }

  /// Build password strength indicator
  Widget _buildPasswordStrengthIndicator() {
    final password = _passwordController.text;
    final strength = _calculatePasswordStrength(password);

    Color strengthColor;
    String strengthText;

    if (strength < 0.3) {
      strengthColor = AppColors.error;
      strengthText = 'Weak';
    } else if (strength < 0.7) {
      strengthColor = AppColors.warning;
      strengthText = 'Medium';
    } else {
      strengthColor = AppColors.success;
      strengthText = 'Strong';
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: strength,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                strengthText,
                style: AppTextStyles.caption.copyWith(
                  color: strengthColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Calculate password strength (0.0 to 1.0)
  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;

    double strength = 0.0;

    // Length check
    if (password.length >= 8) strength += 0.3;
    if (password.length >= 12) strength += 0.2;

    // Contains lowercase
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.15;

    // Contains uppercase
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.15;

    // Contains number
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.15;

    // Contains special character
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.15;

    return strength.clamp(0.0, 1.0);
  }

  /// Validate full name
  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }

    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }

    return null;
  }

  /// Validate email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }

    // Email regex pattern
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  /// Validate password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  /// Validate confirm password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }
}