// lib/features/onboarding/view/onboarding_page_3.dart
import 'package:flutter/material.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/features/onboarding/view/onboarding_page_4.dart';

class OnboardingPage3 extends StatelessWidget {
  const OnboardingPage3({super.key});

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
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: AppRadius.radius24,
                  child: Image.asset(
                    'assets/images/onboarding_background_3.png',
                    height: screenHeight * 0.4,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned(
                  bottom: AppSpacing.spacing16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      bool isActive = index == 2;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing4),
                        height: 8,
                        width: isActive ? 16 : 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColorsPrimary.primary500
                              : AppColorsNeutral.neutral200.withOpacity(0.7),
                          borderRadius: AppRadius.radiusRound,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.spacing32),

            // Textos alterados
            Text(
              'Avaliações e\nPagamento Seguro',
              textAlign: TextAlign.center,
              style: AppTypography.heading1.copyWith(
                color: AppColorsPrimary.primary800,
              ),
            ),
            const SizedBox(height: AppSpacing.spacing12),
            Text(
              'Tenha segurança em suas transações e confira avaliações reais.',
              textAlign: TextAlign.center,
              style: AppTypography.contentRegular.copyWith(
                color: AppColorsNeutral.neutral600,
              ),
            ),

            const SizedBox(height: AppSpacing.spacing32), // Espaço antes dos botões

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const OnboardingPage4()));
                  },
                  child: Text(
                    'Pular',
                    style: AppTypography.contentMedium.copyWith(
                      color: AppColorsNeutral.neutral700,
                      decoration: TextDecoration.underline,
                       decorationColor: AppColorsNeutral.neutral700,
                    ),
                  ),
                ),
                AppButton.primary(
                  text: 'Continuar',
                  iconRightPath: 'assets/icons/arrow_forward.svg',
                  onPressed: () {
                    // TODO: Ação de continuar -> Ir para tela principal/login
                    print('Botão Continuar pressionado');
                  },
                  minWidth: null,
                ),
              ],
            ),
             const SizedBox(height: AppSpacing.spacing16), // Espaço inferior opcional
          ],
        ),
      ),
    );
  }
}