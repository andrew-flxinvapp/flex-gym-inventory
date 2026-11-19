class SubscriptionConstants {
  const SubscriptionConstants._();

  static const String freePlanName = 'Free';
  static const String proPlanName = 'Pro';
  static const String proPlanIdentifier = 'pro';

  static const String proOverviewDescription =
      'Unlock unlimited everything, plus powerful tools to manage your gym with ease.';

  static const int freeGymLimit = 1;
  static const String freeEquipmentQuantityComparisonValue = '20';
  static const String freeWishlistItemsComparisonValue = '20';
  static const String unlimitedLimitDisplay = 'Unlimited';
  static const String notIncludedDisplay = '-';

  static const List<({String label, String freeValue, String? proValue})>
  planComparisons = [
    (
      label: 'Number of gyms',
      freeValue: '$freeGymLimit',
      proValue: unlimitedLimitDisplay,
    ),
    (
      label: 'Number of equipment Items',
      freeValue: freeEquipmentQuantityComparisonValue,
      proValue: unlimitedLimitDisplay,
    ),
    (
      label: 'Number of wishlist items',
      freeValue: freeWishlistItemsComparisonValue,
      proValue: unlimitedLimitDisplay,
    ),
    (label: 'Priority support', freeValue: notIncludedDisplay, proValue: null),
    (
      label: 'Early access to new features',
      freeValue: notIncludedDisplay,
      proValue: null,
    ),
  ];
}
