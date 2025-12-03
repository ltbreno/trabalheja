import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';

/// Widget de estado vazio reutilizável
class EmptyState extends StatelessWidget {
  final String? iconPath;
  final IconData? icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    this.iconPath,
    this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
  }) : assert(
          iconPath != null || icon != null,
          'Você deve fornecer iconPath ou icon',
        );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone
            if (iconPath != null)
              SvgPicture.asset(
                iconPath!,
                height: 120,
                width: 120,
                colorFilter: ColorFilter.mode(
                  AppColorsNeutral.neutral300,
                  BlendMode.srcIn,
                ),
              )
            else if (icon != null)
              Icon(
                icon,
                size: 120,
                color: AppColorsNeutral.neutral300,
              ),

            const SizedBox(height: AppSpacing.spacing24),

            // Título
            Text(
              title,
              style: AppTypography.heading3.copyWith(
                color: AppColorsNeutral.neutral900,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.spacing12),

            // Subtítulo
            Text(
              subtitle,
              style: AppTypography.contentRegular.copyWith(
                color: AppColorsNeutral.neutral600,
              ),
              textAlign: TextAlign.center,
            ),

            // Botão de ação (opcional)
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.spacing24),
              AppButton.primary(
                text: actionText!,
                onPressed: onAction!,
                minWidth: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

