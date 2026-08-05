
import 'package:repair_hub/feature/auth/data/models/user_model.dart';

class SignInModel {
  final String? message;
  final String? token;
  UserModel user;

  SignInModel({required this.message, required this.token, required this.user});
  factory SignInModel.fromJson(Map<String, dynamic> jsonData) {
    return SignInModel(
      message: jsonData['ApiKey.message'],
      token: jsonData['ApiKey.token'],
      user: UserModel.fromJson(jsonData['ApiKey.user']),
    );
  }
}
