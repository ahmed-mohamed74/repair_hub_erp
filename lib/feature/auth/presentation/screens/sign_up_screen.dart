import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:repair_hub/core/constants/asset_images.dart';
import 'package:repair_hub/core/routes/app_router.dart';
import 'package:repair_hub/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:repair_hub/feature/auth/presentation/widgets/authTextFieldWidget.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthFailure) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
                } else if (state is AuthSignUpSuccess) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                  context.go(AppRoutes.login);
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
                      Image.asset(
                        AssetImages.repairHubLogo,
                        fit: BoxFit.contain,
                        height: 110,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Create Account',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Join Repair Hub to manage your devices & service',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Full Name
                      _buildFieldLabel('Full Name', theme),
                      const SizedBox(height: 6),
                      AuthTextFieldWidget(
                        hintText: 'Ahmed Mohamed',
                        controller: nameController,
                        icon: Icons.person_outline,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Full Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone Number
                      _buildFieldLabel('Phone Number', theme),
                      const SizedBox(height: 6),
                      AuthTextFieldWidget(
                        hintText: '+20 1234567891',
                        controller: phoneNumberController,
                        icon: Icons.phone_android_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Phone Number is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email
                      _buildFieldLabel('Email', theme),
                      const SizedBox(height: 6),
                      AuthTextFieldWidget(
                        hintText: 'you@example.com',
                        controller: emailController,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password
                      _buildFieldLabel('Password', theme),
                      const SizedBox(height: 6),
                      AuthTextFieldWidget(
                        hintText: 'Enter Password',
                        controller: passwordController,
                        isObscureText: true,
                        icon: Icons.lock_outline,
                        hasPostIcon: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Password is required';
                          }
                          if (value.trim().length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      _buildFieldLabel('Confirm Password', theme),
                      const SizedBox(height: 6),
                      AuthTextFieldWidget(
                        hintText: 'Confirm Password',
                        controller: confirmPasswordController,
                        isObscureText: true,
                        icon: Icons.lock_outline,
                        hasPostIcon: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value.trim() != passwordController.text.trim()) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Submit Button
                      if (isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(
                                AuthSignUp(
                                  name: nameController.text.trim(),
                                  phone: phoneNumberController.text.trim(),
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                  confirmPassword: confirmPasswordController
                                      .text
                                      .trim(),
                                ),
                              );
                            }
                          },
                          child: const Text('Sign Up'),
                        ),

                      const SizedBox(height: 24),

                      // Already have an account? Login
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.login),
                        child: Text.rich(
                          TextSpan(
                            text: "Already have an account? ",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            children: [
                              TextSpan(
                                text: 'Log In',
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

  Widget _buildFieldLabel(String label, ThemeData theme) {
    return Text(
      label,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}
