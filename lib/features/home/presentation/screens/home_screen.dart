import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/trip_card.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../activity/presentation/providers/trip_provider.dart';
import '../../../activity/domain/models/trip_model.dart';
import '../../../activity/presentation/screens/activity_screen.dart';
import '../../../payments/presentation/screens/payment_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late List<Animation<Offset>> _cardAnimations;
  late List<Animation<double>> _fadeAnimations;

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

    _cardAnimations = List.generate(2, (index) {
      return Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(index * 0.2, 1.0, curve: Curves.easeOutCubic),
        ),
      );
    });

    _fadeAnimations = List.generate(2, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(index * 0.2, 1.0, curve: Curves.easeIn),
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Future<void> _handleRefresh() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      // Invalidate both the specific user data and the recent trips list
      ref.invalidate(recentTripsProvider(user.id));
      ref.invalidate(currentUserProvider);
    }
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    // Watch the recently defined recentTripsProvider
    final AsyncValue<List<TripModel>>? recentTripsAsync = user != null
        ? ref.watch(recentTripsProvider(user.id))
        : null;

    final List<Widget> _pages = [
      _buildHomePage(user, recentTripsAsync),
      const ActivityScreen(),
      const PaymentScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'Activity'),
          BottomNavigationBarItem(icon: Icon(Icons.payment_outlined), activeIcon: Icon(Icons.payment), label: 'Payments'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildHomePage(user, AsyncValue<List<TripModel>>? recentTripsAsync) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(user)),
            SliverToBoxAdapter(
              child: _buildAnimatedSection(index: 0, child: _buildWalletCard(user)),
            ),
            SliverToBoxAdapter(
              child: _buildAnimatedSection(
                index: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screenPaddingH, AppSpacing.md, AppSpacing.screenPaddingH, AppSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Trips', style: AppTextStyles.headingMedium),
                      TextButton(
                        onPressed: () => setState(() => _currentIndex = 1),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (recentTripsAsync != null)
              recentTripsAsync.when(
                data: (trips) {
                  if (trips.isEmpty) return SliverToBoxAdapter(child: _buildEmptyTrips());
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
                        child: TripCard(trip: trips[index]),
                      ),
                      childCount: trips.length,
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: LoadingIndicator(),
                )),
                error: (error, stack) => SliverToBoxAdapter(child: _buildEmptyTrips()),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(user) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_getGreeting(), style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
          Text(user?.fullName ?? 'User', style: AppTextStyles.displayMedium.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAnimatedSection({required int index, required Widget child}) {
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(position: _cardAnimations[index], child: child),
    );
  }

  Widget _buildWalletCard(user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH, vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Wallet Balance', style: AppTextStyles.bodyLarge.copyWith(color: Colors.white.withOpacity(0.9))),
          const SizedBox(height: AppSpacing.xs),
          Text('KES ${user?.walletBalance?.toStringAsFixed(2) ?? "0.00"}',
              style: AppTextStyles.displayLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: () => setState(() => _currentIndex = 2),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('+ Top Up'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTrips() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text('No recent trips available', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
      ),
    );
  }
}