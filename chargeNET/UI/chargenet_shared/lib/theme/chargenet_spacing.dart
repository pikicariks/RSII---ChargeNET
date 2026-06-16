/// Spacing scale — maps to Tailwind gap/padding utilities in Figma Make.
///
/// | Token | px | Figma |
/// |-------|----|-------|
/// | xs    | 4  | gap-1 |
/// | sm    | 8  | gap-2 |
/// | md    | 16 | gap-4 / px-4 mobile |
/// | lg    | 24 | gap-6 / px-6 desktop |
/// | xl    | 32 | gap-8 |
abstract final class ChargeNetSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 40.0;

  /// Horizontal screen padding on mobile (full-bleed map, bottom sheets).
  static const mobileHorizontal = md;

  /// Horizontal screen padding on desktop (sidebar + content).
  static const desktopHorizontal = lg;

  /// Minimum main content width on desktop layouts.
  static const desktopMinContentWidth = 1024.0;
}
