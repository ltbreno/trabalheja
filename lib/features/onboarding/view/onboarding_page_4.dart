// lib/features/onboarding/view/onboarding_page_4.dart
import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // Removido se não houver SVGs nesta tela
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';

class OnboardingPage4 extends StatelessWidget {
  const OnboardingPage4({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: AppColorsNeutral.neutral0,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: AppRadius.radius24,
              child: Image.asset(
                'assets/images/onboarding_ready.png',
                height: screenHeight * 0.4,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: AppSpacing.spacing32),

            Text(
              'Está pronto para\ncomeçar?',
              textAlign: TextAlign.center,
              style: AppTypography.heading1.copyWith(
                color: AppColorsPrimary.primary800,
              ),
            ),
            const SizedBox(height: AppSpacing.spacing12),
            Text(
              'Agora que já conhece nosso aplicativo, vamos criar sua conta.',
              textAlign: TextAlign.center,
              style: AppTypography.contentRegular.copyWith(
                color: AppColorsNeutral.neutral700,
              ),
            ),

            const SizedBox(height: AppSpacing.spacing32),

            AppButton.primary(
              text: 'Continuar',
              onPressed: () {
                // TODO: Ação final -> Navegar para tela de Login/Cadastro
                print('Botão Continuar final pressionado');
              },
              minWidth: double.infinity, // Ocupa largura total
              // Remover iconRightPath se não houver ícone no botão final
            ),
             const SizedBox(height: AppSpacing.spacing16), // Espaço inferior opcional
          ],
        ),
      ),
    );
  }
}