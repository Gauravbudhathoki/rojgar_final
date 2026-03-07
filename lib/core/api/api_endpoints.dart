import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = false;
  static const String _ipAddress = '192.168.137.1';
  static const int _port = 5050;

  static String get _host {
    if (isPhysicalDevice) return _ipAddress;
    if (kIsWeb || Platform.isIOS) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static String get serverUrl => 'http://$_host:$_port';
  static String get baseUrl => '$serverUrl/api';
  static String get mediaServerUrl => serverUrl;

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String user = '/profile';
  static String userById(String id) => '/profile/$id';

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';

  static const String jobs = '/jobs';
  static String jobById(String id) => '/jobs/$id';
  static const String myJobs = '/jobs/my';

  
  static const String uploadProfilePicture = '/profile/upload';
  static String profilePicture(String filename) =>
      '$mediaServerUrl/profile_pictures/$filename';
}