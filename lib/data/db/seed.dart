/// Seed rows the database needs on first open.
///
/// Held as plain data rather than Drift companions so this file does not have
/// to import the generated database, which imports this file in turn.
library;

/// One row of the seed category list.
class SeedCategory {
  const SeedCategory({
    required this.key,
    required this.displayName,
    required this.isEssential,
    required this.icon,
    required this.sortOrder,
  });

  final String key;
  final String displayName;

  /// An essential category is one the user cannot simply skip, so a shortfall
  /// there is a real problem rather than a choice.
  final bool isEssential;
  final String icon;
  final int sortOrder;
}

/// The seed category list from BUILD_PLAN.md Section 7.
///
/// `transport`, `food_daily`, `school`, `health` and `load_data` are marked
/// essential, exactly as the plan specifies.
const List<SeedCategory> seedCategories = <SeedCategory>[
  SeedCategory(
    key: 'transport',
    displayName: 'Transport',
    isEssential: true,
    icon: 'directions_bus',
    sortOrder: 10,
  ),
  SeedCategory(
    key: 'food_daily',
    displayName: 'Everyday food',
    isEssential: true,
    icon: 'restaurant',
    sortOrder: 20,
  ),
  SeedCategory(
    key: 'food_delivery',
    displayName: 'Food delivery',
    isEssential: false,
    icon: 'delivery_dining',
    sortOrder: 30,
  ),
  SeedCategory(
    key: 'groceries',
    displayName: 'Groceries',
    isEssential: true,
    icon: 'shopping_basket',
    sortOrder: 40,
  ),
  SeedCategory(
    key: 'dates_leisure',
    displayName: 'Dates and leisure',
    isEssential: false,
    icon: 'favorite',
    sortOrder: 50,
  ),
  SeedCategory(
    key: 'load_data',
    displayName: 'Load and data',
    isEssential: true,
    icon: 'signal_cellular_alt',
    sortOrder: 60,
  ),
  SeedCategory(
    key: 'school',
    displayName: 'School',
    isEssential: true,
    icon: 'school',
    sortOrder: 70,
  ),
  SeedCategory(
    key: 'health',
    displayName: 'Health',
    isEssential: true,
    icon: 'medical_services',
    sortOrder: 80,
  ),
  SeedCategory(
    key: 'shopping',
    displayName: 'Shopping',
    isEssential: false,
    icon: 'shopping_bag',
    sortOrder: 90,
  ),
  SeedCategory(
    key: 'fees',
    displayName: 'Fees',
    isEssential: false,
    icon: 'receipt_long',
    sortOrder: 100,
  ),
  SeedCategory(
    key: 'transfer_internal',
    displayName: 'Transfer between my accounts',
    isEssential: false,
    icon: 'swap_horiz',
    sortOrder: 110,
  ),
  SeedCategory(
    key: 'savings_in',
    displayName: 'Money into savings',
    isEssential: false,
    icon: 'savings',
    sortOrder: 120,
  ),
  SeedCategory(
    key: 'income',
    displayName: 'Income',
    isEssential: false,
    icon: 'payments',
    sortOrder: 130,
  ),
  SeedCategory(
    key: 'other',
    displayName: 'Unaccounted',
    isEssential: false,
    icon: 'help_outline',
    sortOrder: 140,
  ),
];

/// The category the reconciler uses for a change it cannot explain.
const String unaccountedCategoryKey = 'other';

/// Categories that must never count as spending.
///
/// BUILD_PLAN.md Section 8.4: a transfer is not a spend. Moving PHP 1,000 from
/// GCash into savings would otherwise look like a PHP 1,000 outflow and double
/// the estimated burn rate.
const Set<String> nonSpendCategories = <String>{
  'transfer_internal',
  'savings_in',
};

/// Categories that represent money arriving rather than leaving.
const Set<String> incomeCategories = <String>{'income'};
