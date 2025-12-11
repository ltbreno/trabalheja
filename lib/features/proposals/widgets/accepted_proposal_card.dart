import 'package:flutter/material.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/proposals/widgets/proposal_info_tile.dart';
import 'package:trabalheja/l10n/app_localizations.dart';

/// Card para propostas aceitas (mostra botão de pagamento)
class AcceptedProposalCard extends StatelessWidget {
  final String name;
  final String location;
  final String price;
  final String timeframe;
  final VoidCallback onPay;
  final VoidCallback? onChat;
  final VoidCallback? onReleasePayment;
  final bool hasPaidPayment; // Se true, pagamento já foi realizado
  final String? paymentReleaseStatus; // Status de liberação: 'retained', 'released', null

  const AcceptedProposalCard({
    super.key,
    required this.name,
    required this.location,
    required this.price,
    required this.timeframe,
    required this.onPay,
    this.onChat,
    this.onReleasePayment,
    this.hasPaidPayment = false,
    this.paymentReleaseStatus,
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
                  AppLocalizations.of(context)!.proposalAcceptedBadge,
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
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: AppRadius.radius8,
              border: Border.all(
                color: _getStatusColor().withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  size: 20,
                  color: _getStatusColor(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getStatusMessage(context),
                    style: AppTypography.captionMedium.copyWith(
                      color: _getStatusColor().withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.spacing16),

          // Botões de ação
          _buildCardActions(context),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (!hasPaidPayment) {
      return Colors.blue.shade700;
    }
    if (paymentReleaseStatus == 'released') {
      return Colors.purple.shade700;
    }
    return Colors.green.shade700;
  }

  IconData _getStatusIcon() {
    if (!hasPaidPayment) {
      return Icons.info_outline;
    }
    if (paymentReleaseStatus == 'released') {
      return Icons.verified;
    }
    return Icons.check_circle_outline;
  }

  String _getStatusMessage(BuildContext context) {
    if (!hasPaidPayment) {
      return AppLocalizations.of(context)!.paymentAction;
    }
    if (paymentReleaseStatus == 'released') {
      return AppLocalizations.of(context)!.paymentReleasedBadge;
    }
    return AppLocalizations.of(context)!.paymentHeldBadge;
  }

  Widget _buildCardActions(BuildContext context) {
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
                AppLocalizations.of(context)!.makePayment,
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

        // Se pagamento FOI realizado mas ainda não foi liberado: Mostrar botões de chat e liberar
        if (hasPaidPayment && paymentReleaseStatus == 'retained') ...[
          // Botão de chat
          if (onChat != null)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.chat_bubble_outline, size: 20),
                label: Text(
                  AppLocalizations.of(context)!.chatWithFreelancer,
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
          const SizedBox(height: 12),
          // Botão de liberar pagamento
          if (onReleasePayment != null)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.account_balance_wallet, size: 20),
                label: Text(
                  AppLocalizations.of(context)!.releasePayment,
                  style: AppTypography.contentBold.copyWith(
                    color: AppColorsPrimary.primary700,
                  ),
                ),
                onPressed: onReleasePayment,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColorsPrimary.primary700, width: 2),
                  foregroundColor: AppColorsPrimary.primary700,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radius8,
                  ),
                ),
              ),
            ),
        ],

        // Se pagamento FOI liberado: Apenas mostrar botão de chat
        if (hasPaidPayment && paymentReleaseStatus == 'released' && onChat != null)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline, size: 20),
              label: Text(
                AppLocalizations.of(context)!.chatWithFreelancer,
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

