import 'package:hive/hive.dart';
import 'package:rojgar/feature/auth/domain/entities/auth_entity.dart';
import 'package:rojgar/core/constants/hive_table_constant.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.authTableTypeId)
class AuthHiveModel {
  @HiveField(0)
  final String? authId;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? password;

  @HiveField(4)
  final String? profilePicture;

  AuthHiveModel({
    this.authId,
    required this.username,
    required this.email,
    this.password,
    this.profilePicture,
  });

  factory AuthHiveModel.fromEntity(AuthEntity e) {
    return AuthHiveModel(
      authId: e.authId,
      username: e.username,
      email: e.email,
      password: e.password,
      profilePicture: e.profilePicture,
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      username: username,
      email: email,
      password: password,
      profilePicture: profilePicture,
    );
  }
    //To Entity list
  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
