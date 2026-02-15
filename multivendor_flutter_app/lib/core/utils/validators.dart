class Validators {
  static String? requiredField(String? value) {
    if (value == null || value.isEmpty) {
      return "This field is required";
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return "Email required";
    if (!value.contains('@')) return "Invalid email";
    return null;
  }

  static String? minLength(String? value, int length) {
    if (value == null || value.length < length) {
      return "Minimum $length characters required";
    }
    return null;
  }
}
