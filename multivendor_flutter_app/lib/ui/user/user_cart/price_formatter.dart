// lib/utils/price_formatter.dart
class PriceFormatter {
  static String format(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }
  
  static String formatWithDiscount(double price, double? discountedPrice) {
    if (discountedPrice != null && discountedPrice < price) {
      return '\$${discountedPrice.toStringAsFixed(2)}';
    }
    return '\$${price.toStringAsFixed(2)}';
  }
}