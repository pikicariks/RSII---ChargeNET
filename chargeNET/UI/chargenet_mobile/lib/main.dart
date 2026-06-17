import 'package:chargenet_mobile/app.dart';
import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final publishableKey = AppConfig.stripePublishableKey;
  if (publishableKey.isNotEmpty) {
    Stripe.publishableKey = publishableKey;
    Stripe.urlScheme = 'chargenet';
    await Stripe.instance.applySettings();
  }

  runApp(
    const ProviderScope(
      child: MobileApp(),
    ),
  );
}
