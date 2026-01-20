class EmailValidator {
  static bool isValid(String email) {
    return email.contains('@') && email.contains('.');
  }
}