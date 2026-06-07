import 'package:flutter/material.dart';

/// ChargeNET design tokens — Figma slate/emerald palette.
abstract final class ChargeNetColors {
  /// slate-950 — app scaffold background
  static const background = Color(0xFF020617);

  /// Cards, sidebar panels
  static const surface = Color(0xFF1E293B);

  /// Borders, dividers
  static const surfaceElevated = Color(0xFF334155);

  /// emerald-500 — CTAs, active nav
  static const primary = Color(0xFF10B981);

  /// Active nav background tint
  static const primaryMuted = Color(0x1A10B981);

  /// Unavailable stations, alerts
  static const warning = Color(0xFFF97316);

  /// Headings, primary body text
  static const textPrimary = Color(0xFFFFFFFF);

  /// slate-400 — captions
  static const textSecondary = Color(0xFF94A3B8);

  /// slate-500 — hints, placeholders
  static const textMuted = Color(0xFF64748B);
}
