import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';

enum AppButtonType { primary, secondary, disabled }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final String? iconLeftPath;
  final String? iconRightPath;
  final double? height;
  final double? minWidth;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.iconLeftPath,
    this.iconRightPath,
    this.height = 48.0,
    this.minWidth = double.infinity,
  });

  const AppButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.iconLeftPath,
    this.iconRightPath,
    this.height = 48.0,
    this.minWidth = double.infinity,
  }) : type = AppButtonType.primary;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || type == AppButtonType.disabled;
    final buttonStyle = _getButtonStyle(isDisabled);
    final textStyle = _getTextStyle(isDisabled);
    final iconColor = _getIconColor(isDisabled);

    return SizedBox(
      height: height,
      width: minWidth,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: buttonStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconLeftPath != null) ...[
              SvgPicture.asset(
                iconLeftPath!,
                height: 20,
                width: 20,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
              const SizedBox(width: AppSpacing.spacing8),
            ],
            Flexible(
              child: Text(
                text,
                style: textStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (iconRightPath != null) ...[
              const SizedBox(width: AppSpacing.spacing8),
              SvgPicture.asset(
                iconRightPath!,
                height: 20,
                width: 20,
                 colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ],
          ],
        ),
      ),
    );
  }

  ButtonStyle _getButtonStyle(bool isDisabled) {
    Color backgroundColor;
    Color foregroundColor;

    switch (type) {
      case AppButtonType.primary:
        backgroundColor = isDisabled ? AppColorsNeutral.neutral200 : AppColorsPrimary.primary900;
        foregroundColor = isDisabled ? AppColorsNeutral.neutral500 : AppColorsPrimary.primary100; // Cor para o splash
        break;
      case AppButtonType.secondary:
         backgroundColor = isDisabled ? AppColorsNeutral.neutral100 : AppColorsPrimary.primary100;
         foregroundColor = isDisabled ? AppColorsNeutral.neutral400 : AppColorsPrimary.primary800; // Cor para o splash
         break;
       case AppButtonType.disabled:
         backgroundColor = AppColorsNeutral.neutral200;
         foregroundColor = AppColorsNeutral.neutral500;
         break;
    }

    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: AppColorsNeutral.neutral200,
      disabledForegroundColor: AppColorsNeutral.neutral400,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radius8,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
      elevation: 0,
      minimumSize: Size(minWidth ?? 0, height ?? 0),
    );
  }

  TextStyle _getTextStyle(bool isDisabled) {
     Color textColor;
     switch (type) {
       case AppButtonType.primary:
         textColor = isDisabled ? AppColorsNeutral.neutral500 : AppColorsNeutral.neutral0; // Branco no primário ativo
         break;
       case AppButtonType.secondary:
         textColor = isDisabled ? AppColorsNeutral.neutral400 : AppColorsPrimary.primary900; // Verde escuro no secundário ativo
         break;
       case AppButtonType.disabled:
         textColor = AppColorsNeutral.neutral500;
         break;
     }
     return AppTypography.contentBold.copyWith(color: textColor);
  }

   Color _getIconColor(bool isDisabled) {
      switch (type) {
       case AppButtonType.primary:
         return isDisabled ? AppColorsNeutral.neutral500 : AppColorsNeutral.neutral0;
       case AppButtonType.secondary:
         return isDisabled ? AppColorsNeutral.neutral400 : AppColorsPrimary.primary900;
       case AppButtonType.disabled:
         return AppColorsNeutral.neutral500;
     }
   }
}