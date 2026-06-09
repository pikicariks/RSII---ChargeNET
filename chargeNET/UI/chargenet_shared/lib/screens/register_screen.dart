import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_providers.dart';
import '../theme/chargenet_colors.dart';
import '../theme/chargenet_spacing.dart';
import '../theme/chargenet_text_styles.dart';
import '../widgets/cn_brand_header.dart';
import '../widgets/cn_button.dart';
import '../widgets/cn_card.dart';
import '../widgets/cn_text_field.dart';

/// Driver registration — mobile only.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _firstNameError = _firstNameController.text.trim().isEmpty
          ? 'First name is required.'
          : null;
      _lastNameError = _lastNameController.text.trim().isEmpty
          ? 'Last name is required.'
          : null;
      _emailError = email.isEmpty
          ? 'Email is required.'
          : (!email.contains('@') ? 'Enter a valid email.' : null);
      _passwordError = password.length < 8
          ? 'Password must be at least 8 characters.'
          : null;
    });

    return _firstNameError == null &&
        _lastNameError == null &&
        _emailError == null &&
        _passwordError == null;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    final ok = await ref.read(authProvider.notifier).register(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          phoneNumber: _phoneController.text,
        );

    if (!mounted) return;
    if (!ok) {
      final error = ref.read(authProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: ChargeNetColors.background,
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Create account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ChargeNetSpacing.mobileHorizontal),
          child: CnCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CnBrandHeader(
                  compact: true,
                  subtitle: 'Driver registration',
                ),
                const SizedBox(height: ChargeNetSpacing.lg),
                CnTextField(
                  controller: _firstNameController,
                  label: 'First name',
                  errorText: _firstNameError,
                ),
                const SizedBox(height: ChargeNetSpacing.md),
                CnTextField(
                  controller: _lastNameController,
                  label: 'Last name',
                  errorText: _lastNameError,
                ),
                const SizedBox(height: ChargeNetSpacing.md),
                CnTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                ),
                const SizedBox(height: ChargeNetSpacing.md),
                CnTextField(
                  controller: _phoneController,
                  label: 'Phone (optional)',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: ChargeNetSpacing.md),
                CnTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: true,
                  errorText: _passwordError,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: ChargeNetSpacing.lg),
                CnButton(
                  label: 'Register',
                  onPressed: auth.isLoading ? null : _submit,
                  isLoading: auth.isLoading,
                ),
                const SizedBox(height: ChargeNetSpacing.md),
                TextButton(
                  onPressed: auth.isLoading ? null : () => context.pop(),
                  child: Text(
                    'Already have an account? Sign in',
                    style: ChargeNetTextStyles.bodySm(
                      color: ChargeNetColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
