import 'package:flutter/material.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/proposals/widgets/proposal_info_tile.dart';
import 'package:intl/intl.dart';

/// Card para propostas pagas (com botão de chat)
class PaidProposalCard extends StatelessWidget {
  final String name;
  final String location;
  final String price;
  final String serviceName;
  final String? message; // Observações da proposta
  final String? paymentMethod; // 'pix' ou 'credit_card'
  final String? paymentDate; // ISO 8601
  final String? releaseStatus; // 'retained' ou 'released'
  final VoidCallback? onChat; // Callback para abrir chat

  const PaidProposalCard({
    super.key,
    required this.name,
    required this.location,
    required this.price,
    required this.serviceName,
    this.message,
    this.paymentMethod,
    this.paymentDate,
    this.releaseStatus,
    this.onChat,
  });

  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'Data não disponível';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy \'às\' HH:mm').format(date);
    } catch (e) {
      return 'Data inválida';
    }
  }

  String _getPaymentMethodLabel() {
    if (paymentMethod == 'pix') return 'PIX';
    if (paymentMethod == 'credit_card') return 'Cartão de Crédito';
    return 'Não informado';
  }

  IconData _getPaymentMethodIcon() {
    if (paymentMethod == 'pix') return Icons.qr_code_2;
    if (paymentMethod == 'credit_card') return Icons.credit_card;
    return Icons.payment;
  }

  String _getReleaseStatusLabel() {
    if (releaseStatus == 'released') return 'Pagamento Liberado';
    if (releaseStatus == 'retained') return 'Pagamento Retido';
    return 'Aguardando confirmação';
  }

  Color _getReleaseStatusColor() {
    if (releaseStatus == 'released') return Colors.purple.shade700;
    if (releaseStatus == 'retained') return Colors.orange.shade700;
    return AppColorsNeutral.neutral600;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      decoration: BoxDecoration(
        color: AppColorsNeutral.neutral0,
        borderRadius: AppRadius.radius12,
        border: Border.all(color: Colors.purple.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.shade100.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges de status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: AppRadius.radius8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.purple.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'PAGA',
                      style: AppTypography.captionBold.copyWith(
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Badge de status de liberação
              if (releaseStatus != null)
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getReleaseStatusColor().withOpacity(0.1),
                      borderRadius: AppRadius.radius8,
                      border: Border.all(
                        color: _getReleaseStatusColor().withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      releaseStatus == 'released' ? 'Liberado' : 'Retido',
                      style: AppTypography.captionBold.copyWith(
                        color: _getReleaseStatusColor(),
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
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
                      Icon(
                        Icons.description,
                        size: 16,
                        color: AppColorsPrimary.primary900,
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

          // Divisor
          Divider(color: AppColorsNeutral.neutral200, height: 1),

          const SizedBox(height: AppSpacing.spacing16),

          // Informações do serviço
          Text(
            'Serviço:',
            style: AppTypography.captionBold.copyWith(
              color: AppColorsNeutral.neutral600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            serviceName,
            style: AppTypography.contentRegular.copyWith(
              color: AppColorsPrimary.primary900,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppSpacing.spacing12),

          // Método de pagamento
          Row(
            children: [
              Icon(
                _getPaymentMethodIcon(),
                size: 18,
                color: AppColorsPrimary.primary700,
              ),
              const SizedBox(width: 8),
              Text(
                _getPaymentMethodLabel(),
                style: AppTypography.contentMedium.copyWith(
                  color: AppColorsPrimary.primary900,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.spacing8),

          // Data do pagamento
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 18,
                color: AppColorsNeutral.neutral600,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _formatDate(paymentDate),
                  style: AppTypography.contentRegular.copyWith(
                    color: AppColorsNeutral.neutral700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.spacing16),

          // Status de liberação (mensagem informativa)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getReleaseStatusColor().withOpacity(0.1),
              borderRadius: AppRadius.radius8,
              border: Border.all(
                color: _getReleaseStatusColor().withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  releaseStatus == 'released'
                      ? Icons.verified
                      : Icons.hourglass_empty,
                  size: 20,
                  color: _getReleaseStatusColor(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getReleaseStatusLabel(),
                    style: AppTypography.captionMedium.copyWith(
                      color: _getReleaseStatusColor().withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Botão de Chat (se disponível)
          if (onChat != null) ...[
            const SizedBox(height: AppSpacing.spacing16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.chat_bubble_outline, size: 20),
                label: Text(
                  'Conversar',
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
        ],
      ),
    );
  }
}

