import 'package:flutter/material.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/proposals/widgets/proposal_info_tile.dart';

/// Card para propostas aceitas (mostra botão de pagamento)
class AcceptedProposalCard extends StatelessWidget {
  final String name;
  final String location;
  final String price;
  final String timeframe;
  final VoidCallback onPay;
  final VoidCallback? onChat;
  final bool hasPaidPayment; // Se true, pagamento já foi realizado

  const AcceptedProposalCard({
    super.key,
    required this.name,
    required this.location,
    required this.price,
    required this.timeframe,
    required this.onPay,
    this.onChat,
    this.hasPaidPayment = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      decoration: BoxDecoration(
        color: AppColorsNeutral.neutral0,
        borderRadius: AppRadius.radius12,
        border: Border.all(color: AppColorsSuccess.success200, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColorsSuccess.success100.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge de "Aceita"
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColorsSuccess.success100,
              borderRadius: AppRadius.radius8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppColorsSuccess.success700,
                ),
                const SizedBox(width: 6),
                Text(
                  'Proposta Aceita',
                  style: AppTypography.captionBold.copyWith(
                    color: AppColorsSuccess.success700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.spacing16),

          // Informações da proposta
          ProposalInfoTile(
            iconPath: 'assets/icons/person.svg',
            text: name,
            style: AppTypography.contentMedium.copyWith(
              color: AppColorsPrimary.primary900,
            ),
          ),
          const SizedBox(height: AppSpacing.spacing8),
          ProposalInfoTile(
            iconPath: 'assets/icons/location_pin.svg',
            text: location,
          ),
          const SizedBox(height: AppSpacing.spacing8),
          ProposalInfoTile(
            iconPath: 'assets/icons/credit_card.svg',
            text: price,
          ),
          const SizedBox(height: AppSpacing.spacing8),
          ProposalInfoTile(
            iconPath: 'assets/icons/calendar.svg',
            text: timeframe,
          ),

          const SizedBox(height: AppSpacing.spacing16),

          // Aviso importante
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasPaidPayment ? Colors.green.shade50 : Colors.blue.shade50,
              borderRadius: AppRadius.radius8,
              border: Border.all(
                color: hasPaidPayment ? Colors.green.shade200 : Colors.blue.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasPaidPayment ? Icons.check_circle_outline : Icons.info_outline,
                  size: 20,
                  color: hasPaidPayment ? Colors.green.shade700 : Colors.blue.shade700,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasPaidPayment
                        ? 'Pagamento realizado! Converse com o freelancer'
                        : 'Realize o pagamento para iniciar o serviço',
                    style: AppTypography.captionMedium.copyWith(
                      color: hasPaidPayment ? Colors.green.shade900 : Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.spacing16),

          // Botões de ação
          _buildCardActions(),
        ],
      ),
    );
  }

  Widget _buildCardActions() {
    return Column(
      children: [
        // Se pagamento NÃO foi realizado: Mostrar botão de pagamento
        if (!hasPaidPayment)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.payment, size: 20),
              label: Text(
                'Realizar Pagamento',
                style: AppTypography.contentBold.copyWith(
                  color: AppColorsNeutral.neutral0,
                ),
              ),
              onPressed: onPay,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorsPrimary.primary700,
                foregroundColor: AppColorsNeutral.neutral0,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.radius8,
                ),
              ),
            ),
          ),

        // Se pagamento FOI realizado: Mostrar botão de chat
        if (hasPaidPayment && onChat != null)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline, size: 20),
              label: Text(
                'Conversar com Freelancer',
                style: AppTypography.contentBold.copyWith(
                  color: AppColorsNeutral.neutral0,
                ),
              ),
              onPressed: onChat,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorsSuccess.success700,
                foregroundColor: AppColorsNeutral.neutral0,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.radius8,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

