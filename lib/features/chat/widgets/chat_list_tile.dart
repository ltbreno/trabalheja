import 'package:flutter/material.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';

class ChatListTile extends StatelessWidget {
  final String initials;
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final VoidCallback onTap;

  const ChatListTile({
    super.key,
    required this.initials,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacing24,
          vertical: AppSpacing.spacing16,
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColorsPrimary.primary900.withOpacity(0.1),
              child: Text(
                initials,
                style: AppTypography.heading4
                    .copyWith(color: AppColorsPrimary.primary900),
              ),
            ),
            const SizedBox(width: AppSpacing.spacing12),
            // Conteúdo (Nome, Mensagem, Badge)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Linha do Nome e Hora
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: AppTypography.highlightBold
                              .copyWith(color: AppColorsNeutral.neutral900),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.spacing8),
                      Text(
                        time,
                        style: AppTypography.captionRegular
                            .copyWith(color: AppColorsNeutral.neutral500),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.spacing4),
                  // Linha da Mensagem e Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          style: AppTypography.contentRegular
                              .copyWith(color: AppColorsNeutral.neutral600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: AppSpacing.spacing8),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.spacing6),
                          decoration: BoxDecoration(
                            color: AppColorsPrimary.primary700, // Cor roxa
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: AppTypography.captionBold
                                .copyWith(color: AppColorsNeutral.neutral0),
                          ),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}