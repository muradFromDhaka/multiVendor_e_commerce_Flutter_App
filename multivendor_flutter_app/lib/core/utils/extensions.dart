extension StringExtensions on String {
  bool get isEmail => contains('@');
}

extension PriceExtensions on num {
  String get formatPrice => "৳$this";
}
