import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:rojgar/core/constants/hive_table_constant.dart';
import 'package:rojgar/feature/auth/data/models/auth_hive_model.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  // In-memory storage for web platform
  static final Map<String, AuthHiveModel> _webStorage = {};
  
  Future<void> init() async {
    if (!kIsWeb) {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/${HiveTableConstant.dbName}';
      Hive.init(path);
      _registerAdapter();
    }
  }

  void _registerAdapter() {
    if (!kIsWeb && !Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  Future<void> openBoxes() async {
    if (!kIsWeb) {
      await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
    }
  }

  Future<void> close() async {
    if (!kIsWeb) {
      await Hive.close();
    }
  }

  Box<AuthHiveModel> get _authBox {
    if (kIsWeb) {
      throw UnsupportedError('Hive box not available on web');
    }
    return Hive.box<AuthHiveModel>(HiveTableConstant.authTable);
  }

  //regiseter user ko lagi
  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    // Check if email already exists
    if (isEmailExists(model.email)) {
      throw Exception('Email already exists');
    }
    // Ensure we have a non-null key (Hive requires String or int keys)
    final String id = model.authId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final AuthHiveModel modelWithId = (model.authId == id)
        ? model
        : AuthHiveModel(
            authId: id,
            username: model.username,
            email: model.email,
            password: model.password,
            profilePicture: model.profilePicture,
          );

    if (kIsWeb) {
      // Use in-memory storage for web
      _webStorage[id] = modelWithId;
    } else {
      // Use Hive for mobile/desktop
      await _authBox.put(id, modelWithId);
    }
    return modelWithId;
  }

  //Login user ko lagi
  Future<AuthHiveModel?> loginUser(String email, String password) async {
    if (kIsWeb) {
      // Use in-memory storage for web
      final users = _webStorage.values.where(
        (user) => user.email == email && user.password == password,
      );
      return users.isNotEmpty ? users.first : null;
    } else {
      // Use Hive for mobile/desktop
      final users = _authBox.values.where(
        (user) => user.email == email && user.password == password,
      );
      if (users.isNotEmpty) {
        return users.first;
      }
      return null;
    }
  }

  //logout ko lagi
  Future<void> logoutUser() async {}

  //get current user
  AuthHiveModel? getCurrentUser(String authId) {
    if (kIsWeb) {
      return _webStorage[authId];
    } else {
      return _authBox.get(authId);
    }
  }

  //isemail exists
  bool isEmailExists(String email) {
    if (kIsWeb) {
      // Use in-memory storage for web
      final users = _webStorage.values.where((user) => user.email == email);
      return users.isNotEmpty;
    } else {
      // Use Hive for mobile/desktop
      final users = _authBox.values.where((user) => user.email == email);
      return users.isNotEmpty;
    }
  }
}