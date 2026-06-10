import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('primary color token is emerald green', () {
    expect(ChargeNetColors.primary, const Color(0xFF10B981));
    expect(ChargeNetColors.background, const Color(0xFF020617));
  });

  test('spacing and radii tokens match plan', () {
    expect(ChargeNetSpacing.md, 16);
    expect(ChargeNetRadii.xl, 24);
  });
}
