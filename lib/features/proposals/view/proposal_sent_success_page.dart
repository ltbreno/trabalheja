// lib/features/proposals/view/proposal_sent_success_page.dart
import 'package:flutter/material.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/view/freelancer_dashboard_page.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';

class ProposalSentSuccessPage extends StatelessWidget {
  const ProposalSentSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsNeutral.neutral0,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spacing24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone de sucesso
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColorsSuccess.success50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppColorsSuccess.success600,
                  size: 64,
                ),
              ),
              
              const SizedBox(height: AppSpacing.spacing24),
              
              // Título
              Text(
                'Proposta enviada!',
                style: AppTypography.heading1.copyWith(
                  color: AppColorsPrimary.primary700,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSpacing.spacing12),
              
              // Mensagem
              Text(
                'O cliente já recebeu sua proposta. Caso ela seja aceita, você receberá uma notificação',
                style: AppTypography.contentRegular.copyWith(
                  color: AppColorsNeutral.neutral600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSpacing.spacing48),
              
              // Botão continuar
              AppButton.primary(
                text: 'Continuar',
                onPressed: () {
                  // Voltar para o dashboard do freelancer
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const FreelancerDashboardPage(),
                    ),
                    (route) => false,
                  );
                },
                minWidth: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

