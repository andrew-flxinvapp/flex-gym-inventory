import 'package:purchases_flutter/purchases_flutter.dart';

class PriceProvider {
  static String monthlyPrice(StoreProduct? product) =>
      product == null ? 'Price unavailable' : '${product.priceString}/month';

  static String yearlyPrice(StoreProduct? product) =>
      product == null ? 'Price unavailable' : '${product.priceString}/year';

  static int? annualSavings(StoreProduct? monthly, StoreProduct? annual) {
    if (monthly == null ||
        annual == null ||
        monthly.currencyCode != annual.currencyCode ||
        monthly.subscriptionPeriod != 'P1M' ||
        annual.subscriptionPeriod != 'P1Y' ||
        monthly.price <= 0 ||
        annual.price <= 0) {
      return null;
    }
    final savings = ((1 - annual.price / (monthly.price * 12)) * 100).floor();
    return savings > 0 ? savings : null;
  }
}
