// lib/core/widgets/error_modal.dart
import 'package:flutter/material.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';

class ErrorModal extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onClose;

  const ErrorModal({
    super.key,
    required this.title,
    required this.message,
    this.onClose,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onClose,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ErrorModal(
        title: title,
        message: message,
        onClose: onClose,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.spacing24),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.spacing24),
        decoration: BoxDecoration(
          color: AppColorsNeutral.neutral0,
          borderRadius: AppRadius.radius16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone de erro
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColorsError.error50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: AppColorsError.error600,
                size: 32,
              ),
            ),
            
            const SizedBox(height: AppSpacing.spacing16),
            
            // Título
            Text(
              title,
              style: AppTypography.heading3.copyWith(
                color: AppColorsNeutral.neutral900,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppSpacing.spacing8),
            
            // Mensagem
            Text(
              message,
              style: AppTypography.contentRegular.copyWith(
                color: AppColorsNeutral.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppSpacing.spacing24),
            
            // Botão de fechar
            AppButton.primary(
              text: 'Fechar',
              onPressed: () {
                Navigator.of(context).pop();
                onClose?.call();
              },
              minWidth: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}

