import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/proposals/widgets/proposal_info_tile.dart'; // Importa o tile reutilizável

class ReceivedProposalCard extends StatelessWidget {
  final String name;
  final String location;
  final String price;
  final String timeframe;
  final String? message; // Observações da proposta
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const ReceivedProposalCard({
    super.key,
    required this.name,
    required this.location,
    required this.price,
    required this.timeframe,
    this.message,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      decoration: BoxDecoration(
        color: AppColorsNeutral.neutral0,
        borderRadius: AppRadius.radius12,
        border: Border.all(color: AppColorsNeutral.neutral100),
        boxShadow: [
          BoxShadow(
            color: AppColorsNeutral.neutral100.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProposalInfoTile(
            iconPath: 'assets/icons/person.svg', // Ícone de conta
            text: name,
            style: AppTypography.contentMedium.copyWith(color: AppColorsPrimary.primary900),
          ),
          const SizedBox(height: AppSpacing.spacing8),
          ProposalInfoTile(
            iconPath: 'assets/icons/location_pin.svg', // Ícone de localização
            text: location,
          ),
          const SizedBox(height: AppSpacing.spacing8),
          ProposalInfoTile(
            iconPath: 'assets/icons/credit_card.svg', // Ícone de dinheiro
            text: price,
          ),
          const SizedBox(height: AppSpacing.spacing8),
          ProposalInfoTile(
            iconPath: 'assets/icons/calendar.svg', // Ícone de calendário
            text: timeframe,
          ),
          // Exibir observações se houver
          if (message != null && message!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.spacing12),
            Container(
              padding: const EdgeInsets.all(AppSpacing.spacing12),
              decoration: BoxDecoration(
                color: AppColorsNeutral.neutral50,
                borderRadius: AppRadius.radius8,
                border: Border.all(color: AppColorsNeutral.neutral200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/document.svg',
                        height: 16,
                        colorFilter: ColorFilter.mode(AppColorsPrimary.primary900, BlendMode.srcIn),
                      ),
                      const SizedBox(width: AppSpacing.spacing8),
                      Text(
                        'Observações',
                        style: AppTypography.captionBold.copyWith(
                          color: AppColorsPrimary.primary900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.spacing8),
                  Text(
                    message!,
                    style: AppTypography.captionRegular.copyWith(
                      color: AppColorsNeutral.neutral700,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.spacing16),
          _buildCardActions(),
        ],
      ),
    );
  }

  Widget _buildCardActions() {
    return Row(
      children: [
        // Botão Rejeitar
        Expanded(
          child: ElevatedButton.icon(
            icon: SvgPicture.asset(
              'assets/icons/close.svg',
              height: 16,
              colorFilter: ColorFilter.mode(AppColorsError.error600, BlendMode.srcIn),
            ),
            label: Text(
              'Rejeitar',
              style: AppTypography.contentBold.copyWith(color: AppColorsError.error600),
            ),
            onPressed: onReject,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorsError.error100,
              foregroundColor: AppColorsError.error300, // Splash
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.radius8),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.spacing12),
        // Botão Aceitar
        Expanded(
          child: ElevatedButton.icon(
            icon: SvgPicture.asset(
              'assets/icons/checkmark.svg',
              height: 16,
              colorFilter: ColorFilter.mode(AppColorsSuccess.success600, BlendMode.srcIn),
            ),
            label: Text(
              'Aceitar',
               style: AppTypography.contentBold.copyWith(color: AppColorsSuccess.success600),
            ),
            onPressed: onAccept,
             style: ElevatedButton.styleFrom(
              backgroundColor: AppColorsSuccess.success100,
              foregroundColor: AppColorsSuccess.success300, // Splash
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.radius8),
            ),
          ),
        ),
      ],
    );
  }
}
