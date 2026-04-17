import 'package:email_validator/email_validator.dart';

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    // Using the package for professional, reliable validation
    if (!EmailValidator.validate(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }
}
