import 'package:rojgar/core/api/api_endpoints.dart';
import 'package:rojgar/feature/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String username;
  final String email;
  final String? password;
  final String? profilePicture;

  AuthApiModel({
    this.id,
    required this.username,
    required this.email,
    this.password,
    this.profilePicture,
  });

  Map<String, dynamic> toJson() {
    final data = {
      "username": username,
      "email": email,
      "profilePicture": profilePicture,
    };
    if (password != null) {
      data["password"] = password;
    }
    return data;
  }

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      username: json['username'] as String,
      email: json['email'] as String,
      profilePicture: json['profilePicture'] as String?,
    );
  }

  AuthEntity toEntity() {
    String? fullProfilePictureUrl;
    if (profilePicture != null && profilePicture!.isNotEmpty) {
      if (profilePicture!.startsWith('http')) {
        fullProfilePictureUrl = profilePicture;
      } else {
        fullProfilePictureUrl = ApiEndpoints.profilePicture(profilePicture!);
      }
    }
    return AuthEntity(
      authId: id,
      username: username,
      email: email,
      profilePicture: fullProfilePictureUrl,
    );
  }

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.authId,
      username: entity.username,
      email: entity.email,
      password: entity.password,
      profilePicture: entity.profilePicture,
    );
  }

  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}