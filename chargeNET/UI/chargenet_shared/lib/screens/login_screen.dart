import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/app_routes.dart';
import '../app/charge_net_app.dart';
import '../providers/app_providers.dart';
import '../theme/chargenet_colors.dart';
import '../theme/chargenet_spacing.dart';
import '../theme/chargenet_text_styles.dart';
import '../widgets/cn_brand_header.dart';
import '../widgets/cn_button.dart';
import '../widgets/cn_card.dart';
import '../widgets/cn_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, required this.platform});

  final ChargeNetPlatform platform;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    var valid = true;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _emailError = email.isEmpty
          ? 'Email is required.'
          : (!email.contains('@') ? 'Enter a valid email.' : null);
      _passwordError =
          password.isEmpty ? 'Password is required.' : null;
      valid = _emailError == null && _passwordError == null;
    });
    return valid;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    final ok = await ref.read(authProvider.notifier).login(
          email: _emailController.text,
          password: _passwordController.text,
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
    final isMobile = widget.platform == ChargeNetPlatform.mobile;
    final horizontal = isMobile
        ? ChargeNetSpacing.mobileHorizontal
        : ChargeNetSpacing.desktopHorizontal;

    final form = CnCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CnBrandHeader(
            compact: !isMobile,
            subtitle: isMobile ? 'Driver app' : 'Admin console',
          ),
          const SizedBox(height: ChargeNetSpacing.lg),
          CnTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            errorText: _emailError,
          ),
          const SizedBox(height: ChargeNetSpacing.md),
          CnTextField(
            controller: _passwordController,
            label: 'Password',
            hint: '••••••••',
            obscureText: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            errorText: _passwordError,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: ChargeNetSpacing.lg),
          CnButton(
            label: 'Sign in',
            onPressed: auth.isLoading ? null : _submit,
            isLoading: auth.isLoading,
            icon: Icons.login_rounded,
          ),
          if (isMobile) ...[
            const SizedBox(height: ChargeNetSpacing.md),
            TextButton(
              onPressed: auth.isLoading
                  ? null
                  : () => context.push(AppRoutes.register),
              child: Text(
                'Create driver account',
                style: ChargeNetTextStyles.bodySm(
                  color: ChargeNetColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return Scaffold(
      backgroundColor: ChargeNetColors.background,
      body: SafeArea(
        child: isMobile
            ? SingleChildScrollView(
                padding: EdgeInsets.all(horizontal),
                child: form,
              )
            : Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(horizontal),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: form,
                  ),
                ),
              ),
      ),
    );
  }
}
