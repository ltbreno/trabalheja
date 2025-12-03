// lib/features/auth/view/welcome_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/auth/view/login_page.dart';
import 'package:trabalheja/features/auth/view/signup_email_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsPrimary.primary900,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spacing24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),

              SvgPicture.asset(
                'assets/icons/logo.svg',
                height: 40,
                colorFilter: ColorFilter.mode(
                  AppColorsNeutral.neutral0,
                  BlendMode.srcIn,
                ),
              ),

              const Spacer(flex: 3),    
              _buildCreateAccountButton(context),

              const SizedBox(height: AppSpacing.spacing16),

                
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Acessar minha conta',
                      style: AppTypography.contentMedium.copyWith(
                        color: AppColorsNeutral.neutral0, // Texto branco
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spacing8),
                    SvgPicture.asset(
                      'assets/icons/arrow_forward.svg',
                      height: 16,
                      colorFilter: ColorFilter.mode(
                        AppColorsNeutral.neutral0, // Ícone branco
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.spacing16), // Espaço inferior
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateAccountButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: SvgPicture.asset(
        'assets/icons/user.svg',
        height: 18,
        colorFilter: ColorFilter.mode(
          AppColorsPrimary.primary900,
          BlendMode.srcIn,
        ),
      ),
      label: Text(
        'Criar nova conta',
        style: AppTypography.contentBold.copyWith(
          color: AppColorsPrimary.primary900,
        ),
      ),
      onPressed: () {
        // TODO: Navegar para tela de Cadastro
        print('Criar conta');
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpEmailPage()));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorsNeutral.neutral0, // Fundo branco
        foregroundColor: AppColorsPrimary.primary700, // Cor do splash
        minimumSize: const Size(double.infinity, 48), // Altura e largura total
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radius8,
        ),
        elevation: 0,
      ),
    );

    /* Alternativa: Se você adicionar um tipo `AppButtonType.secondary` ao AppButton:
    return AppButton(
      text: 'Criar nova conta',
      onPressed: () {},
      type: AppButtonType.secondary, // Supondo que secondary tenha fundo branco
      iconLeftPath: 'assets/icons/user.svg',
      minWidth: double.infinity,
    );
    */
  }
} 