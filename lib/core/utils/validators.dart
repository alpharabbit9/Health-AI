enum PasswordStrength { empty, weak, fair, strong, veryStrong }

class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w.+\-]+@[\w\-]+\.[\w\-.]+$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'At least 8 characters required';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Include at least one uppercase letter';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Include at least one number';
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]'))) {
      return 'Include at least one special character';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required';
    final trimmed = value.trim();
    if (trimmed.length < 3) return 'Name must be at least 3 characters';
    if (!trimmed.contains(' ')) return 'Please enter your first and last name';
    return null;
  }

  static String? age(String? value) {
    if (value == null || value.trim().isEmpty) return 'Age is required';
    final n = int.tryParse(value.trim());
    if (n == null) return 'Enter a valid number';
    if (n < 1 || n > 120) return 'Enter a valid age (1–120)';
    return null;
  }

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static PasswordStrength passwordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.empty;
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]'))) score++;

    if (score <= 1) return PasswordStrength.weak;
    if (score <= 2) return PasswordStrength.fair;
    if (score <= 4) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }
}
