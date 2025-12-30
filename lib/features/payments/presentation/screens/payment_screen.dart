import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/payment_provider.dart';
import '../widgets/payment_card.dart';
import '../../domain/models/payment_model.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showTopUpDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TopUpBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final paymentsAsync = ref.watch(paymentStateProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Payments'), automaticallyImplyLeading: false),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildWalletCard(user),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
              child: Row(
                children: [Text('Transaction History', style: AppTextStyles.headingMedium)],
              ),
            ),
            Expanded(
              child: paymentsAsync.when(
                data: (payments) {
                  if (payments.isEmpty) return const EmptyState(icon: Icons.receipt_long, title: 'No transactions yet', message: 'History will appear here');
                  return RefreshIndicator(
                    onRefresh: () async => ref.read(paymentStateProvider.notifier).fetchHistory(user!.id),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
                      itemCount: payments.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: PaymentCard(payment: payments[index]),
                      ),
                    ),
                  );
                },
                loading: () => const LoadingIndicator(),
                error: (e, _) => const Center(child: Text('Error loading payments')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showTopUpDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Top Up', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildWalletCard(user) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.screenPaddingH),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.secondary, AppColors.secondaryDark]),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Available Balance', style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70)),
              Text('KES ${user?.walletBalance?.toStringAsFixed(2) ?? "0.00"}',
                  style: AppTextStyles.displayLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
        ],
      ),
    );
  }
}

class TopUpBottomSheet extends ConsumerStatefulWidget {
  const TopUpBottomSheet({Key? key}) : super(key: key);
  @override
  ConsumerState<TopUpBottomSheet> createState() => _TopUpBottomSheetState();
}

class _TopUpBottomSheetState extends ConsumerState<TopUpBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _selectedMethod = 'M-Pesa';
  bool _isLoading = false;

  final List<int> _quickAmounts = [100, 500, 1000, 2000, 5000];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleTopUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final payment = await ref.read(paymentStateProvider.notifier).topUpWallet(
      amount: double.parse(_amountController.text),
      paymentMethod: _selectedMethod,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (payment != null && payment.status == PaymentStatus.success) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.read(authStateProvider.notifier).updateWalletBalance(user.walletBalance + payment.amount);
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Success!'), backgroundColor: AppColors.success));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.cardRadius)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text('Top Up Wallet', style: AppTextStyles.headingLarge),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Quick Amount Section
                Text('Quick Amount', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _quickAmounts.map((amount) => _buildQuickAmountBtn(amount)).toList(),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Amount Input
                CustomTextField(
                  label: 'Amount',
                  hint: 'Enter amount',
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Payment Method Section
                Text('Payment Method', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.md),
                _buildMethodSelector('M-Pesa', Icons.phone_android),
                const SizedBox(height: AppSpacing.md),
                _buildMethodSelector('Card', Icons.credit_card),

                const SizedBox(height: AppSpacing.xl),
                CustomButton(text: 'Complete Top-Up', onPressed: _handleTopUp, isLoading: _isLoading),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAmountBtn(int amount) {
    return InkWell(
      onTap: () => setState(() => _amountController.text = amount.toString()),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text('KES $amount', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildMethodSelector(String method, IconData icon) {
    final isSelected = _selectedMethod == method;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = method),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Text(method, style: AppTextStyles.bodyLarge.copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            const Spacer(),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}