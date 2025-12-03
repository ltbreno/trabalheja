import 'package:flutter/material.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isSender;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isSender,
  });

  @override
  Widget build(BuildContext context) {
    final alignment =
        isSender ? MainAxisAlignment.end : MainAxisAlignment.start;
    final color =
        isSender ? AppColorsPrimary.primary900 : AppColorsNeutral.neutral100;
    final textColor =
        isSender ? AppColorsNeutral.neutral0 : AppColorsNeutral.neutral900;
    
    // Raio de borda customizado para balão de chat
    final borderRadius = BorderRadius.only(
      topLeft: AppRadius.radius16.topLeft,
      topRight: AppRadius.radius16.topRight,
      bottomLeft: isSender ? AppRadius.radius16.bottomLeft : Radius.zero,
      bottomRight: isSender ? Radius.zero : AppRadius.radius16.bottomRight,
    );

    return Row(
      mainAxisAlignment: alignment,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75, // Máx 75% da tela
          ),
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.spacing4),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.spacing12,
            horizontal: AppSpacing.spacing16,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: borderRadius,
          ),
          child: Text(
            text,
            style: AppTypography.contentRegular.copyWith(color: textColor),
          ),
        ),
      ],
    );
  }
}