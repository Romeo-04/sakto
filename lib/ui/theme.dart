/// The MaterialApp theme, built entirely from `tokens.dart`.
library;

import 'package:baon/ui/tokens.dart';
import 'package:flutter/material.dart';

ThemeData buildBaonTheme() {
  final ColorScheme scheme =
      ColorScheme.fromSeed(
        seedColor: BaonColors.accent,
        brightness: Brightness.light,
      ).copyWith(
        primary: BaonColors.ink,
        onPrimary: Colors.white,
        onSurface: BaonColors.ink,
        secondary: BaonColors.accent,
        secondaryContainer: BaonColors.accentSoft,
        surface: BaonColors.cream,
        error: BaonColors.risky,
      );

  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Nunito',
    materialTapTargetSize: MaterialTapTargetSize.padded,
    focusColor: BaonColors.accentSoft,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: BaonColors.accent,
      selectionColor: BaonColors.accentSoft,
      selectionHandleColor: BaonColors.accent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: BaonColors.whiteGlass,
      labelStyle: BaonType.label,
      hintStyle: BaonType.bodyMuted,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Space.lg,
        vertical: Space.lg,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Corner.pill),
        borderSide: const BorderSide(color: Colors.white, width: 3),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Corner.soft),
        borderSide: const BorderSide(color: Colors.white, width: 3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Corner.soft),
        borderSide: const BorderSide(color: BaonColors.accent, width: 3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Corner.soft),
        borderSide: const BorderSide(color: BaonColors.risky, width: 3),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: BaonColors.whiteGlass,
      selectedColor: BaonColors.accentSoft,
      labelStyle: BaonType.label.copyWith(color: BaonColors.ink),
      padding: const EdgeInsets.symmetric(
        horizontal: Space.sm,
        vertical: Space.sm,
      ),
      shape: const StadiumBorder(
        side: BorderSide(color: Colors.white, width: 2.5),
      ),
      side: const BorderSide(color: Colors.white, width: 2.5),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? BaonColors.accent
            : BaonColors.textMuted,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: BaonColors.accent,
      linearTrackColor: BaonColors.accentSoft,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(
        BaonColors.textMuted.withValues(alpha: 0.6),
      ),
      radius: const Radius.circular(Corner.pill),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        textStyle: BaonType.button,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(48, 48),
        focusColor: BaonColors.accentSoft,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: BaonColors.sheet,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Corner.sheet)),
        side: BorderSide(color: Colors.white, width: 3),
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: BaonColors.sheet,
      headerHeadlineStyle: BaonType.h1,
      dayStyle: BaonType.body,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Corner.sheet),
        side: const BorderSide(color: Colors.white, width: 3),
      ),
    ),
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: const TextTheme(
      displayLarge: BaonType.display,
      displayMedium: BaonType.display,
      displaySmall: BaonType.h1,
      headlineLarge: BaonType.h1,
      headlineSmall: BaonType.h2,
      titleMedium: BaonType.h2,
      titleSmall: BaonType.button,
      bodyLarge: BaonType.body,
      labelMedium: BaonType.label,
      labelSmall: BaonType.label,
      headlineMedium: BaonType.h1,
      titleLarge: BaonType.h2,
      bodyMedium: BaonType.body,
      bodySmall: BaonType.bodyMuted,
      labelLarge: BaonType.button,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: BaonColors.paper,
      foregroundColor: BaonColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: BaonType.h1,
    ),
    dividerTheme: const DividerThemeData(
      color: BaonColors.border,
      thickness: BorderWeight.hairline,
      space: Space.lg,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: BaonColors.ink,
      contentTextStyle: BaonType.body.copyWith(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Corner.pill),
        side: const BorderSide(color: Color(0x33FFFFFF)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      indicatorColor: BaonColors.accentSoft,
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.all(
        BaonType.button.copyWith(fontSize: 11, color: BaonColors.ink),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: BaonColors.sheet,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Corner.sheet),
        side: const BorderSide(color: Colors.white, width: 3),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );
}
