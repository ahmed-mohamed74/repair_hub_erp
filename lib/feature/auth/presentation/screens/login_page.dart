import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:repair_hub/core/constants/asset_images.dart';
import 'package:repair_hub/core/routes/app_router.dart';
import 'package:repair_hub/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:repair_hub/feature/auth/presentation/widgets/authTextFieldWidget.dart';
import 'package:repair_hub/feature/auth/presentation/widgets/otp_model_content_widget.dart';

enum AuthMode { password, otp }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  AuthMode _authMode = AuthMode.password;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPasswordMode = _authMode == AuthMode.password;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (state is AuthLoginSuccess ||
                    state is AuthOtpVerifiedSuccess) {
                  context.go(AppRoutes.home);
                } else if (state is AuthOtpSentSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  _showOtpDialog(context, emailController.text.trim());
                }
              },
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                return Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      Image.asset(
                        AssetImages.repairHubLogo,
                        fit: BoxFit.contain,
                        height: 110,
                      ),
                      const SizedBox(height: 24),

                      // Header
                      Text(
                        'Welcome Back!',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Log in to access your repair dashboard',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Auth Mode Switcher (Password vs OTP)
                      SegmentedButton<AuthMode>(
                        segments: const [
                          ButtonSegment<AuthMode>(
                            value: AuthMode.password,
                            label: Text('Password'),
                            icon: Icon(Icons.lock_outline, size: 18),
                          ),
                          ButtonSegment<AuthMode>(
                            value: AuthMode.otp,
                            label: Text('OTP Code'),
                            icon: Icon(
                              Icons.mark_email_read_outlined,
                              size: 18,
                            ),
                          ),
                        ],
                        selected: {_authMode},
                        onSelectionChanged: (newSelection) {
                          setState(() {
                            _authMode = newSelection.first;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Email Field (Always visible)
                      AuthTextFieldWidget(
                        hintText: 'Email',
                        controller: emailController,
                        icon: Icons.email_outlined,
                      ),

                      const SizedBox(height: 16),

                      // Fixed Space Password Field (Maintains space without shifting layout)
                      Visibility(
                        visible: isPasswordMode,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AuthTextFieldWidget(
                              hintText: 'Password',
                              controller: passwordController,
                              isObscureText: true,
                              icon: Icons.lock_outline,
                              hasPostIcon: true,
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: isPasswordMode
                                    ? () {
                                        // Forgot Password Action
                                      }
                                    : null,
                                child: Text(
                                  "Forgot Password?",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Dynamic Action Button (Fixed position)
                      if (isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        ElevatedButton(
                          onPressed: () {
                            if (_authMode == AuthMode.password) {
                              // Normal Login
                              if (formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(
                                  AuthLogin(
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim(),
                                  ),
                                );
                              }
                            } else {
                              // OTP Request
                              final email = emailController.text.trim();
                              if (email.isNotEmpty && email.contains('@')) {
                                context.read<AuthBloc>().add(
                                  AuthSendOtp(email: email),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please enter a valid email address',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(
                            _authMode == AuthMode.password
                                ? 'Log In'
                                : 'Send OTP Code',
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Sign Up Redirect
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.signUp),
                        child: Text.rich(
                          TextSpan(
                            text: "Are you new to Repair Hub? ",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            children: [
                              TextSpan(
                                text: 'Register',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showOtpDialog(BuildContext outerContext, String email) {
    showModalBottomSheet(
      context: outerContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return OtpModalContentWidget(
          email: email,
          onVerify: (otpCode) {
            Navigator.pop(bottomSheetContext);
            outerContext.read<AuthBloc>().add(
              AuthVerifyOtp(email: email, token: otpCode),
            );
          },
        );
      },
    );
  }
}
