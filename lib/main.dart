import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rojgar/app/app.dart';
import 'package:rojgar/core/services/hive/hive_service.dart';
import 'package:rojgar/core/services/storage/user_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();

  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      child: const App(),
    ),
  );
}