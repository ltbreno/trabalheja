import 'package:flutter/material.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/core/widgets/auth_wrapper.dart';

class App extends StatelessWidget {
  const App({super.key});

  TextTheme _buildTextTheme(TextTheme base) {
    final Color defaultTextColor = AppColorsNeutral.neutral900;

    return base.copyWith(
      displayLarge: AppTypography.display1.copyWith(color: defaultTextColor),
      displayMedium: AppTypography.display2.copyWith(color: defaultTextColor),
      displaySmall: AppTypography.display3.copyWith(color: defaultTextColor),

      headlineLarge: AppTypography.heading1.copyWith(color: defaultTextColor),
      headlineMedium: AppTypography.heading2.copyWith(color: defaultTextColor),
      headlineSmall: AppTypography.heading3.copyWith(color: defaultTextColor),

      titleLarge: AppTypography.heading4.copyWith(color: defaultTextColor),
      titleMedium: AppTypography.highlightMedium.copyWith(color: defaultTextColor),
      titleSmall: AppTypography.contentMedium.copyWith(color: defaultTextColor),

      bodyLarge: AppTypography.contentRegular.copyWith(color: defaultTextColor),
      bodyMedium: AppTypography.captionRegular.copyWith(color: AppColorsNeutral.neutral700),
      bodySmall: AppTypography.footnoteRegular.copyWith(color: AppColorsNeutral.neutral500),

      labelLarge: AppTypography.contentBold.copyWith(color: AppColorsNeutral.neutral0),
      labelMedium: AppTypography.captionMedium.copyWith(color: defaultTextColor),
      labelSmall: AppTypography.footnoteMedium.copyWith(color: defaultTextColor),
    ).apply(
        fontFamily: 'SpaceGrotesk',
    );
  }


  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData.light(useMaterial3: true);

    return MaterialApp(
      title: 'TrabalheJa',
      theme: baseTheme.copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColorsPrimary.primary900,
          primary: AppColorsPrimary.primary900,
          secondary: AppColorsSecondary.secondary900,
          error: AppColorsError.error500,
          background: AppColorsNeutral.neutral0,
          onBackground: AppColorsNeutral.neutral900,  
          surface: AppColorsNeutral.neutral50,
          onSurface: AppColorsNeutral.neutral900,
          onPrimary: AppColorsNeutral.neutral0,
          onSecondary: AppColorsNeutral.neutral0,
          onError: AppColorsNeutral.neutral0,
        ),
        scaffoldBackgroundColor: AppColorsNeutral.neutral0,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColorsPrimary.primary900,
          foregroundColor: AppColorsNeutral.neutral0,
          titleTextStyle: AppTypography.heading3.copyWith(color: AppColorsNeutral.neutral0),
        ),
        textTheme: _buildTextTheme(baseTheme.textTheme),
      ),
      // AuthWrapper gerencia a navegação baseada no estado de autenticação
      home: const AuthWrapper(),
    );
  }
}