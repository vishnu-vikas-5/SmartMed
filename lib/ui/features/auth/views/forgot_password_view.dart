import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onReset() async {
    if (!_formKey.currentState!.validate()) return;

    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    final success = await authVm.sendPasswordReset(_emailController.text.trim());

    if (success && mounted) {
      setState(() {
        _sent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _sent
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppColors.takenBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mark_email_read_outlined,
                        size: 56,
                        color: AppColors.taken,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Check your inbox',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We sent a password reset link to\n${_emailController.text.trim()}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'Back to Sign In',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Forgot your password?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Enter your registered email address and we'll send you instructions to reset your password.",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 28),

                      if (authVm.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.missedBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            authVm.errorMessage!,
                            style: const TextStyle(
                                color: AppColors.missed, fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      CustomTextField(
                        label: 'Email Address',
                        hint: 'user@email.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined,
                            color: AppColors.primary),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!val.contains('@')) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      CustomButton(
                        text: 'Send Reset Link',
                        isLoading: authVm.isLoading,
                        onPressed: _onReset,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
