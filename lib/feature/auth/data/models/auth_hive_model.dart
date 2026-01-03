import 'package:hive/hive.dart';
import 'package:rojgar/feature/auth/domain/entities/entities/auth_entity.dart';
import 'package:rojgar/core/constants/hive_table_constant.dart';

class AuthHiveModel {
  final String? authId;
  final String username;
  final String email;
  final String? password;
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
}

class AuthHiveModelAdapter extends TypeAdapter<AuthHiveModel> {
  @override
  final int typeId = HiveTableConstant.authTypeId;

  @override
  AuthHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return AuthHiveModel(
      authId: fields[0] as String?,
      username: fields[1] as String,
      email: fields[2] as String,
      password: fields[3] as String?,
      profilePicture: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AuthHiveModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.authId)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.password)
      ..writeByte(4)
      ..write(obj.profilePicture);
  }
}
