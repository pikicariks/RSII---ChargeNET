import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_exception.dart';
import '../providers/app_providers.dart';
import '../theme/chargenet_text_styles.dart';
import '../theme/chargenet_spacing.dart';
import '../widgets/cn_brand_header.dart';
import '../widgets/cn_button.dart';
import '../widgets/cn_card.dart';
import '../widgets/cn_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _requesting = false;
  bool _submitting = false;
  bool _tokenRequested = false;

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _requestToken() async {
    setState(() => _requesting = true);
    try {
      final service = await ref.read(authServiceProvider.future);
      final token = await service.requestPasswordReset(
        email: _emailController.text.trim(),
      );
      if (!mounted) {
        return;
      }

      if (token != null && token.isNotEmpty) {
        _tokenController.text = token;
      }
      setState(() => _tokenRequested = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reset token generated.')),
      );
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) {
        setState(() => _requesting = false);
      }
    }
  }

  Future<void> _confirmReset() async {
    setState(() => _submitting = true);
    try {
      final service = await ref.read(authServiceProvider.future);
      await service.confirmPasswordReset(
        email: _emailController.text.trim(),
        resetToken: _tokenController.text.trim(),
        newPassword: _newPasswordController.text,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset successful. You can sign in now.')),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: ListView(
        padding: const EdgeInsets.all(ChargeNetSpacing.mobileHorizontal),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: CnCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CnBrandHeader(
                      compact: true,
                      subtitle: 'Account recovery',
                    ),
                    const SizedBox(height: ChargeNetSpacing.md),
                    Text(
                      'Enter your email to request a reset token, then set a new password.',
                      style: ChargeNetTextStyles.bodySm(),
                    ),
                    const SizedBox(height: ChargeNetSpacing.md),
                    CnTextField(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: ChargeNetSpacing.md),
                    CnButton(
                      label: 'Request reset token',
                      onPressed: _requesting ? null : _requestToken,
                      isLoading: _requesting,
                    ),
                    if (_tokenRequested) ...[
                      const SizedBox(height: ChargeNetSpacing.lg),
                      const Divider(height: 1),
                      const SizedBox(height: ChargeNetSpacing.lg),
                      CnTextField(
                        controller: _tokenController,
                        label: 'Reset token',
                        hint: '6-digit token',
                      ),
                      const SizedBox(height: ChargeNetSpacing.md),
                      CnTextField(
                        controller: _newPasswordController,
                        label: 'New password',
                        obscureText: true,
                      ),
                      const SizedBox(height: ChargeNetSpacing.md),
                      CnButton(
                        label: 'Reset password',
                        onPressed: _submitting ? null : _confirmReset,
                        isLoading: _submitting,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
