import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';

class RequestSuccessPage extends StatelessWidget {
  const RequestSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsNeutral.neutral0,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spacing24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               const Spacer(),
               Center(
                child: SvgPicture.asset(
                  'assets/icons/checkmark.svg', // Ícone de check
                  height: 80,
                  width: 80,
                  colorFilter: ColorFilter.mode(
                      AppColorsSuccess.success500, BlendMode.srcIn),
                ),
              ),
              const SizedBox(height: AppSpacing.spacing24),
               Text(
                'Serviço solicitado!',
                textAlign: TextAlign.center,
                style: AppTypography.heading1.copyWith(
                  color: AppColorsPrimary.primary900, // Cor roxa
                ),
              ),
              const SizedBox(height: AppSpacing.spacing12),
              Text(
                'Em breve você receberá propostas de freelancers para realização dos serviços.',
                textAlign: TextAlign.center,
                style: AppTypography.contentRegular.copyWith(
                  color: AppColorsNeutral.neutral600,
                ),
              ),
              const Spacer(),
               AppButton.primary(
                text: 'Continuar',
                onPressed: () {
                  // TODO: Navegar de volta para a HomePage ou ProposalsPage
                  // Limpar a pilha de navegação
                  if(Navigator.canPop(context)) {
                    Navigator.pop(context); // Volta para a HomePage
                  }
                },
                minWidth: double.infinity,
              ),
              const SizedBox(height: AppSpacing.spacing16),
            ],
          ),
        ),
      ),
    );
  }
}
