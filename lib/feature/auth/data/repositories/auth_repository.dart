import 'package:dartz/dartz.dart';
import 'package:repair_hub/core/network/connection_checker.dart';
import 'package:repair_hub/core/supabase/supabase_service.dart';
import 'package:repair_hub/feature/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseService supabaseService;
  final ConnectionChecker connectionChecker;
  AuthRepository(this.supabaseService, this.connectionChecker);
  Future<Either<String, UserModel>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return Left('No internet connection!');
      }
      return Right(
        UserModel(
          address: 'address',
          email: email,
          id: 'id',
          name: 'name',
          phone: 'phone',
        ),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, String>> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return Left('No internet connection!');
      }
      final message = await supabaseService.client.auth.signUp(
        email: email,
        password: password,
      );
      return Right(message.user?.email ?? 'Sign up successful');
    } catch (e) {
      return Left(e.toString());
    }
  }

Future<Either<String, String>> sendOtp({required String email}) async {
  try {
    if (!await connectionChecker.isConnected) {
      return const Left('No internet connection!');
    }

    await supabaseService.client.auth.signInWithOtp(
      email: email,
      shouldCreateUser: false,
    );

    return const Right('OTP code sent to your email');
  } on AuthException catch (e) {
    return Left(e.message);
  } catch (e) {
    return Left(e.toString());
  }
}

Future<Either<String, UserModel>> verifyOtp({
  required String email,
  required String token,
}) async {
  try {
    if (!await connectionChecker.isConnected) {
      return const Left('No internet connection!');
    }
    final response = await supabaseService.client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );

    if (response.user != null) {
      return Right(
        UserModel(
          id: response.user!.id,
          email: response.user!.email ?? email,
          name: response.user!.userMetadata?['name'] ?? '',
          phone: response.user!.phone ?? '',
          address: '',
        ),
      );
    } else {
      return const Left('Verification failed!');
    }
  } on AuthException catch (e) {
    return Left(e.message); // يعطي رسالة واضحة من Supabase
  } catch (e) {
    return Left(e.toString());
  }
}

}
