import 'package:basic_diet/presentation/resources/color_manager.dart';
import 'package:basic_diet/presentation/resources/font_manager.dart';
import 'package:basic_diet/presentation/resources/styles_manager.dart';
import 'package:basic_diet/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';

ThemeData getApplicationTheme() {
  final colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: ColorManager.brand.primary,
    onPrimary: ColorManager.text.inverse,
    secondary: ColorManager.brand.accent,
    onSecondary: ColorManager.text.inverse,
    error: ColorManager.state.error,
    onError: ColorManager.text.inverse,
    surface: ColorManager.background.surface,
    onSurface: ColorManager.text.primary,
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: FontConstants.fontFamily,
    primaryColor: ColorManager.brand.primary,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: ColorManager.background.app,
    dividerColor: ColorManager.border.defaultColor,
    appBarTheme: AppBarTheme(
      backgroundColor: ColorManager.background.surface,
      foregroundColor: ColorManager.text.primary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),

    buttonTheme: ButtonThemeData(
      shape: const StadiumBorder(),
      buttonColor: ColorManager.brand.primary,
      disabledColor: ColorManager.state.disabledSurface,
      splashColor: ColorManager.brand.primary,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorManager.brand.primary,
        foregroundColor: ColorManager.text.inverse,
        disabledBackgroundColor: ColorManager.state.disabledSurface,
        disabledForegroundColor: ColorManager.state.disabled,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s16),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ColorManager.text.primary,
        side: BorderSide(color: ColorManager.border.defaultColor),
        backgroundColor: ColorManager.background.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s14),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: ColorManager.brand.primary),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorManager.background.surface,
      errorStyle: getRegularTextStyle(color: ColorManager.state.error),
      hintStyle: getRegularTextStyle(
        color: ColorManager.text.secondary,
        fontSize: AppSize.s16,
      ),

      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.border.defaultColor,
          width: AppSize.s1_5,
        ),
        borderRadius: BorderRadius.circular(AppSize.s8),
      ),

      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.brand.primary,
          width: AppSize.s1_5,
        ),
        borderRadius: BorderRadius.circular(AppSize.s8),
      ),

      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.state.error,
          width: AppSize.s1_5,
        ),
        borderRadius: BorderRadius.circular(AppSize.s8),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.state.error,
          width: AppSize.s1_5,
        ),
        borderRadius: BorderRadius.circular(AppSize.s8),
      ),
    ),
  );
}
