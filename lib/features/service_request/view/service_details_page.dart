// lib/features/service_request/view/service_details_page.dart
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/core/utils/distance_calculator.dart' as distance_util;
import 'package:trabalheja/core/widgets/app_map.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/proposals/view/send_proposal_page.dart';

class ServiceDetailsPage extends StatelessWidget {
  final Map<String, dynamic> serviceRequest;

  const ServiceDetailsPage({
    super.key,
    required this.serviceRequest,
  });

  String _formatCurrency(double value) {
    final formatted = value.toStringAsFixed(2);
    final parts = formatted.split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];
    
    String formattedInteger = '';
    for (int i = integerPart.length - 1; i >= 0; i--) {
      formattedInteger = integerPart[i] + formattedInteger;
      if ((integerPart.length - i) % 3 == 0 && i > 0) {
        formattedInteger = '.$formattedInteger';
      }
    }
    
    return 'R\$ $formattedInteger,$decimalPart';
  }

  @override
  Widget build(BuildContext context) {
    final client = serviceRequest['profiles'] as Map<String, dynamic>?;
    final clientName = client?['full_name'] as String? ?? 'Cliente';
    final serviceDesc = serviceRequest['service_description'] as String? ?? '';
    final budget = serviceRequest['budget'] as num? ?? 0;
    final deadlineHours = serviceRequest['deadline_hours'] as int? ?? 0;
    final additionalInfo = serviceRequest['additional_info'] as String?;
    final lat = serviceRequest['service_latitude'] as double?;
    final lng = serviceRequest['service_longitude'] as double?;
    final distance = serviceRequest['distance'] as double? ?? 0.0;
    
    final serviceLocation = (lat != null && lng != null) 
        ? LatLng(lat, lng) 
        : const LatLng(-7.1205, -34.8287);

    return Scaffold(
      backgroundColor: AppColorsNeutral.neutral0,
      appBar: AppBar(
        backgroundColor: AppColorsNeutral.neutral0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColorsNeutral.neutral900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detalhes do serviço',
          style: AppTypography.contentMedium.copyWith(
            color: AppColorsNeutral.neutral900,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.spacing24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card do Cliente
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.spacing16),
                      decoration: BoxDecoration(
                        color: AppColorsNeutral.neutral0,
                        borderRadius: AppRadius.radius12,
                        border: Border.all(color: AppColorsNeutral.neutral200),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: AppColorsNeutral.neutral200,
                            child: Text(
                              clientName.isNotEmpty 
                                  ? clientName[0].toUpperCase() 
                                  : 'C',
                              style: AppTypography.heading3.copyWith(
                                color: AppColorsNeutral.neutral600,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.spacing16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  clientName,
                                  style: AppTypography.highlightBold.copyWith(
                                    color: AppColorsNeutral.neutral900,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.spacing4),
                                Text(
                                  'Cliente',
                                  style: AppTypography.captionRegular.copyWith(
                                    color: AppColorsNeutral.neutral500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.spacing24),
                    
                    // Descrição do Serviço
                    Text(
                      'Descrição do serviço',
                      style: AppTypography.highlightBold.copyWith(
                        color: AppColorsNeutral.neutral900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing8),
                    Text(
                      serviceDesc,
                      style: AppTypography.contentRegular.copyWith(
                        color: AppColorsNeutral.neutral700,
                      ),
                    ),
                    
                    if (additionalInfo != null && additionalInfo.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.spacing16),
                      Text(
                        'Informações adicionais',
                        style: AppTypography.highlightBold.copyWith(
                          color: AppColorsNeutral.neutral900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spacing8),
                      Text(
                        additionalInfo,
                        style: AppTypography.contentRegular.copyWith(
                          color: AppColorsNeutral.neutral700,
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: AppSpacing.spacing24),
                    
                    // Informações do Serviço
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.attach_money,
                            label: 'Orçamento',
                            value: _formatCurrency(budget.toDouble()),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.spacing12),
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.calendar_today,
                            label: 'Prazo',
                            value: '$deadlineHours horas',
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSpacing.spacing12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.location_on,
                            label: 'Distância',
                            value: distance_util.AppDistanceCalculator.formatDistance(distance),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSpacing.spacing24),
                    
                    // Mapa com localização
                    Text(
                      'Localização do serviço',
                      style: AppTypography.highlightBold.copyWith(
                        color: AppColorsNeutral.neutral900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing12),
                    ClipRRect(
                      borderRadius: AppRadius.radius12,
                      child: SizedBox(
                        height: 200,
                        child: AppMap(
                          center: serviceLocation,
                          radius: 0, // Sem círculo de raio
                          initialZoom: 15.0,
                          isInteractive: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Botão de ação
            Container(
              padding: const EdgeInsets.all(AppSpacing.spacing24),
              decoration: BoxDecoration(
                color: AppColorsNeutral.neutral0,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: AppButton.primary(
                text: 'Enviar proposta',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SendProposalPage(
                        serviceRequest: serviceRequest,
                      ),
                    ),
                  );
                },
                minWidth: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      decoration: BoxDecoration(
        color: AppColorsNeutral.neutral50,
        borderRadius: AppRadius.radius12,
        border: Border.all(color: AppColorsNeutral.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppColorsPrimary.primary700,
              ),
              const SizedBox(width: AppSpacing.spacing8),
              Text(
                label,
                style: AppTypography.captionRegular.copyWith(
                  color: AppColorsNeutral.neutral600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing8),
          Text(
            value,
            style: AppTypography.contentMedium.copyWith(
              color: AppColorsNeutral.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

