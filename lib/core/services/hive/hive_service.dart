import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rojgar/core/constants/hive_table_constant.dart';
import 'package:rojgar/feature/auth/data/models/auth_hive_model.dart';

/// Provider (DO NOT create instance here)
final hiveServiceProvider = Provider<HiveService>((ref) {
  throw UnimplementedError('HiveService must be initialized in main.dart');
});

class HiveService {
  // In-memory storage for web
  static final Map<String, AuthHiveModel> _webStorage = {};

  Future<void> init() async {
    if (kIsWeb) return;

    final directory = await getApplicationCacheDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';

    Hive.init(path);

    _registerAdapters();

    // OPEN BOXES HERE (CRITICAL)
    await _openBoxes();
  }

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTableTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  Future<void> _openBoxes() async {
    if (!Hive.isBoxOpen(HiveTableConstant.authTable)) {
      await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
    }
  }

  Box<AuthHiveModel> get _authBox {
    if (kIsWeb) {
      throw UnsupportedError('Hive not supported on web');
    }
    if (!Hive.isBoxOpen(HiveTableConstant.authTable)) {
      throw HiveError('Auth box is not opened');
    }
    return Hive.box<AuthHiveModel>(HiveTableConstant.authTable);
  }

  // REGISTER
  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    if (isEmailExists(model.email)) {
      throw Exception('Email already exists');
    }

    if (kIsWeb) {
      _webStorage[model.authId!] = model;
    } else {
      await _authBox.put(model.authId, model);
    }

    return model;
  }

  //LOGIN
  Future<AuthHiveModel?> login(String email, String password) async {
    if (kIsWeb) {
      return _webStorage.values
          .where((u) => u.email == email && u.password == password)
          .cast<AuthHiveModel?>()
          .firstOrNull;
    }

    final users = _authBox.values.where(
      (u) => u.email == email && u.password == password,
    );

    return users.isNotEmpty ? users.first : null;
  }

  // GET USER
  AuthHiveModel? getCurrentUser(String authId) {
    if (kIsWeb) {
      return _webStorage[authId];
    }
    return _authBox.get(authId);
  }

  //CHECK EMAIL
  bool isEmailExists(String email) {
    if (kIsWeb) {
      return _webStorage.values.any((u) => u.email == email);
    }
    return _authBox.values.any((u) => u.email == email);
  }

  // LOGOUT
  Future<void> logout() async {
    // session handled by SharedPreferences
  }

  Future<void> close() async {
    if (!kIsWeb) {
      await Hive.close();
    }
  }

  Future<void> logoutUser() async {}

  Future<dynamic> loginUser(String email, String password) async {}
}