class ApiEndpoints {
  ApiEndpoints._();

  // ================= Base URLs =================

  // Android Emulator
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // iOS Simulator
  // static const String baseUrl = 'http://localhost:5050/api';

  // Physical Device (use your PC IP)
  // static const String baseUrl = 'http://192.168.137.1:5050/api';

  // ================= Timeouts =================
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ================= Auth =================
  static const String register = '/auth/register';
  static const String login = '/auth/login';

  // ================= User =================
  static const String profile = '/auth/profile';

  static Null get user => null;
}