import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String username;
  final String email;
  final String? password;
  final String? profilePicture; 

  const AuthEntity({ 
    this.authId, 
    required this.username,
    required this.email, 
    this.password ,
    this.profilePicture
  });

  @override

  List<Object?> get props => [
    authId, 
    username, 
    email, 
    password, 
    profilePicture
  ];
}