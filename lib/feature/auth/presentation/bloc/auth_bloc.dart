import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_hub/feature/auth/data/models/sign_in_model.dart';
import 'package:repair_hub/feature/auth/data/models/user_model.dart';
import 'package:repair_hub/feature/auth/data/repositories/auth_repository.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  bool isChecked = false;
  SignInModel? user;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthLogin>((event, emit) async {
      emit(AuthLoading());
      final response = await authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      response.fold(
        (errorMessage) => emit(AuthFailure(errorMessage: errorMessage)),
        (signInModel) => emit(AuthLoginSuccess()),
      );
    });

    on<AuthSignUp>((event, emit) async {
      emit(AuthLoading());
      final response = await authRepository.signUp(
        name: event.name,
        email: event.email,
        password: event.password,
        phone: event.phone,
        confirmPassword: event.confirmPassword,
      );
      response.fold(
        (errorMessage) => emit(AuthFailure(errorMessage: errorMessage)),
        (message) => emit(AuthSignUpSuccess(message: message)),
      );
    });

    on<AuthSendOtp>((event, emit) async {
      emit(AuthLoading());
      final response = await authRepository.sendOtp(email: event.email);
      response.fold(
        (error) => emit(AuthFailure(errorMessage: error)),
        (message) => emit(AuthOtpSentSuccess(message: message)),
      );
    });

    on<AuthVerifyOtp>((event, emit) async {
      emit(AuthLoading());
      final response = await authRepository.verifyOtp(
        email: event.email,
        token: event.token,
      );
      response.fold(
        (error) => emit(AuthFailure(errorMessage: error)),
        (userModel) => emit(AuthOtpVerifiedSuccess(user: userModel)),
      );
    });
  }
}
