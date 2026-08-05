import 'package:flutter/material.dart';

class OtpModalContentWidget extends StatefulWidget {
  final String email;
  final Function(String otpCode) onVerify;

  const OtpModalContentWidget({super.key, required this.email, required this.onVerify});

  @override
  State<OtpModalContentWidget> createState() => _OtpModalContentWidgetState();
}

class _OtpModalContentWidgetState extends State<OtpModalContentWidget> {
  final otpController = TextEditingController();

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter Verification Code',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We sent an 8-digit code to:\n${widget.email}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            maxLength: 8,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              letterSpacing: 6,
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              hintText: '00000000',
              counterText: '',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final code = otpController.text.trim();
              if (code.length == 8) {
                widget.onVerify(code);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter the full 8-digit code'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Verify & Log In'),
          ),
        ],
      ),
    );
  }
}
