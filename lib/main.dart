import 'package:baon/app_providers.dart';
import 'package:baon/features/balance_entry/balance_entry_screen.dart';
import 'package:baon/features/dashboard/dashboard_screen.dart';
import 'package:baon/features/forecast_view/forecast_screen.dart';
import 'package:baon/features/onboarding/onboarding_screen.dart';
import 'package:baon/features/settings/settings_screen.dart';
import 'package:baon/features/transactions/transactions_screen.dart';
import 'package:baon/ui/theme.dart';
import 'package:baon/ui/tokens.dart';
import 'package:baon/ui/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: BaonApp()));
}

class BaonApp extends StatelessWidget {
  const BaonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baon',
      debugShowCheckedModeBanner: false,
      theme: buildBaonTheme(),
      builder: (BuildContext context, Widget? child) =>
          GlassBackdrop(child: child ?? const SizedBox.shrink()),
      home: const _AppRoot(),
    );
  }
}

/// Waits for the database to seed, then routes between onboarding and the
/// main app shell based on whether any account exists.
class _AppRoot extends ConsumerWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<void> ready = ref.watch(databaseReadyProvider);

    return ready.when(
      loading: () => const _SplashScreen(),
      error: (Object error, StackTrace stack) => _ErrorScreen(error: error),
      data: (_) => const _OnboardingGate(),
    );
  }
}

class _OnboardingGate extends ConsumerWidget {
  const _OnboardingGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<bool> done = ref.watch(hasCompletedOnboardingProvider);
    return done.when(
      loading: () => const _SplashScreen(),
      error: (Object error, StackTrace stack) => _ErrorScreen(error: error),
      data: (bool hasAccounts) =>
          hasAccounts ? const HomeShell() : const OnboardingScreen(),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: BaonColors.paper,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('BAON', style: BaonType.display),
            SizedBox(height: Space.lg),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: BaonColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BaonColors.paper,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Space.xl),
          child: EmptyState(
            icon: Icons.error_outline,
            title: 'Something went wrong',
            message: '$error',
          ),
        ),
      ),
    );
  }
}

/// The main app shell: five tabs, one per BUILD_PLAN.md Section 13 screen
/// that is not onboarding.
///
/// The selected tab lives in [selectedTabProvider] rather than local state,
/// so another screen can switch tabs — for example, the dashboard's
/// "Fix your envelopes" banner jumping straight to Balances.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  static const List<Widget> _pages = <Widget>[
    DashboardScreen(),
    BalanceEntryScreen(),
    ForecastScreen(),
    TransactionsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int index = ref.watch(selectedTabProvider);

    return Scaffold(
      backgroundColor: BaonColors.paper,
      body: SafeArea(
        child: IndexedStack(index: index, children: _pages),
      ),
      extendBody: false,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(Space.sm),
          child: GlassPane(
            borderRadius: BorderRadius.circular(Corner.pill),
            color: BaonColors.whiteGlass,
            child: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (int i) =>
                  ref.read(selectedTabProvider.notifier).state = i,
              destinations: const <NavigationDestination>[
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  selectedIcon: Icon(Icons.account_balance_wallet),
                  label: 'Balances',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon: Icon(Icons.insights),
                  label: 'Forecast',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: 'Activity',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
