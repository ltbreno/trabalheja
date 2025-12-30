import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'proposal_info_tile.dart'; // Importa o tile reutilizável

enum ProposalStatus { accepted, rejected, pending }

class SentProposalCard extends StatelessWidget {
  final String name;
  final String location;
  final String price;
  final String timeframe;
  final String? message; // Observações da proposta
  final ProposalStatus status;

  const SentProposalCard({
    super.key,
    required this.name,
    required this.location,
    required this.price,
    required this.timeframe,
    this.message,
    required this.status,
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
        crossAxisAlignment: CrossAxisAlignment.stretch, // Para o badge esticar
        children: [
          // Badge de Status (Aceita/Rejeitada)
          _buildStatusBadge(),
          const SizedBox(height: AppSpacing.spacing12),

          // Informações
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
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (status == ProposalStatus.pending) {
      return const SizedBox.shrink(); // Não mostra nada se pendente
    }

    final bool isAccepted = status == ProposalStatus.accepted;
    final Color bgColor = isAccepted ? AppColorsSuccess.success50 : AppColorsError.error50;
    final Color textColor = isAccepted ? AppColorsSuccess.success700 : AppColorsError.error700;
    final String iconPath = isAccepted ? 'assets/icons/checkmark.svg' : 'assets/icons/close.svg';
    final String text = isAccepted ? 'Aceita' : 'Rejeitada';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing12,
        vertical: AppSpacing.spacing8,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.radius8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconPath,
            height: 16,
            colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
          ),
          const SizedBox(width: AppSpacing.spacing8),
          Text(
            text,
            style: AppTypography.contentBold.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}
