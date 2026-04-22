import 'package:flutter/material.dart';

class AppBrandColors {
  const AppBrandColors();

  final Color primary = const Color(0xFF10B981);
  final Color primaryPressed = const Color(0xFF16664A);
  final Color primaryHover = const Color(0xFF2E9C75);
  final Color primaryTint = const Color(0xFFEAF7F1);

  final Color accent = const Color(0xFFFF6900);
  final Color accentPressed = const Color(0xFFFF5A00);
  final Color accentSoft = const Color(0xFFFFF0E8);
  final Color accentBorder = const Color(0xFFFFA577);
}

class AppTextColors {
  const AppTextColors();

  final Color primary = const Color(0xFF111827);
  final Color secondary = const Color(0xFF6B7280);
  final Color inverse = const Color(0xFFFFFFFF);
  final Color muted = const Color(0xFF9CA3AF);
}

class AppBackgroundColors {
  const AppBackgroundColors();

  final Color app = const Color(0xFFF8FAF9);
  final Color surface = const Color(0xFFFFFFFF);
  final Color subtle = const Color(0xFFF3F4F6);
  final Color overlayStrong = const Color(0xCC111827);
}

class AppBorderColors {
  const AppBorderColors();

  final Color defaultColor = const Color(0xFFE5E7EB);
  final Color subtle = const Color(0xFFF2F4F7);
  final Color accent = const Color(0xFFFFA577);
}

class AppIconColors {
  const AppIconColors();

  final Color primary = const Color(0xFF111827);
  final Color secondary = const Color(0xFF6B7280);
  final Color inverse = const Color(0xFFFFFFFF);
  final Color accent = const Color(0xFFFF6900);
  final Color success = const Color(0xFF16664A);
}

class AppStateColors {
  const AppStateColors();

  final Color success = const Color(0xFF10B981);
  final Color successEmphasis = const Color(0xFF16664A);
  final Color successSurface = const Color(0xFFEAF7F1);

  final Color warning = const Color(0xFFFF6900);
  final Color warningEmphasis = const Color(0xFFFF5A00);
  final Color warningSurface = const Color(0xFFFFF0E8);
  final Color warningBorder = const Color(0xFFFFA577);

  final Color error = const Color(0xFFED1B24);
  final Color errorSurface = const Color(0xFFFEF2F2);
  final Color errorBorder = const Color(0xFFFECACA);
  final Color errorEmphasis = const Color(0xFF991B1B);

  final Color info = const Color(0xFFEAF7F1);
  final Color infoEmphasis = const Color(0xFF16664A);
  final Color active = const Color(0xFF10B981);
  final Color selected = const Color(0xFFEAF7F1);
  final Color disabled = const Color(0xFF9CA3AF);
  final Color disabledSurface = const Color(0xFFF3F4F6);
}

class ColorManager {
  const ColorManager._();

  static const AppBrandColors brand = AppBrandColors();
  static const AppTextColors text = AppTextColors();
  static const AppBackgroundColors background = AppBackgroundColors();
  static const AppBorderColors border = AppBorderColors();
  static const AppIconColors icon = AppIconColors();
  static const AppStateColors state = AppStateColors();

  static const Color transparent = Colors.transparent;

  static const Color greenPrimary = Color(0xFF10B981);
  static const Color greenPressed = Color(0xFF16664A);
  static const Color greenHover = Color(0xFF2E9C75);
  static const Color greenLight = Color(0xFFEAF7F1);
  static const Color greenDark = Color(0xFF16664A);

  static const Color orangePrimary = Color(0xFFFF6900);
  static const Color orangePressed = Color(0xFFFF5A00);
  static const Color orangeHover = Color(0xFFFFF0E8);
  static const Color orangeLight = Color(0xFFFFA577);
  static const Color orangeF54900 = Color(0xFFFF6900);
  static const Color orangeFFF5EC = Color(0xFFFFF0E8);

  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color whiteF0FDF4 = Color(0xFFEAF7F1);
  static const Color blackColor = Color(0xFF111827);
  static const Color black101828 = Color(0xFF111827);
  static const Color grayColor = Color(0xFF6B7280);
  static const Color grey6A7282 = Color(0xFF6B7280);
  static const Color grey4A5565 = Color(0xFF4B5563);
  static const Color grey364153 = Color(0xFF374151);
  static const Color grey9CA3AF = Color(0xFF9CA3AF);
  static const Color greyF3F4F6 = Color(0xFFF3F4F6);

  static const Color formFieldsBorderColor = Color(0xFFE5E7EB);
  static const Color errorColor = Color(0xFFED1B24);

  static const Color greenFA76F = Color(0xFF10B981);
  static const Color bluePrimary = Color(0xFFFF6900);
  static const Color purplePrimary = Color(0xFFFF6900);
}
