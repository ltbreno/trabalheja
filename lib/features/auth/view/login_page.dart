// lib/features/auth/view/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/auth/view/welcome_page.dart';
import 'package:trabalheja/features/auth/view/email_login_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsNeutral.neutral0, // Fundo branco
      appBar: AppBar(
        backgroundColor: AppColorsNeutral.neutral0, // AppBar branca
        elevation: 0, // Sem sombra
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/arrow_back.svg',
            height: 24,
            colorFilter: ColorFilter.mode(
              AppColorsNeutral.neutral900, // Ícone escuro
              BlendMode.srcIn,
            ),
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context); // Ação de voltar padrão
            }
          },
        ),
        title: Text(
          'Voltar',
          style: AppTypography.contentMedium.copyWith(
            color: AppColorsNeutral.neutral900, // Texto escuro
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Alinha horizontalmente
            children: [
              const SizedBox(height: AppSpacing.spacing16), // Espaço após AppBar

              Text(
                'Bem-vindo(a) de volta\nao TrabalheJá',
                style: AppTypography.heading1.copyWith( // Título grande
                  color: AppColorsPrimary.primary800,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing8),
              Text(
                'Escolha seu método de entrada da sua conta.',
                style: AppTypography.contentRegular.copyWith(
                  color: AppColorsNeutral.neutral600, // Subtítulo cinza
                ),
              ),

              const SizedBox(height: AppSpacing.spacing32), // Espaço antes dos botões

              // Botão Entrar com Email e Senha
              AppButton.primary(
                text: 'Entrar com email e senha',
                iconLeftPath: 'assets/icons/mail.svg',
                onPressed: () {
                  // TODO: Navegar para tela de login com email/senha
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const EmailLoginPage()));
                },
                minWidth: double.infinity,
              ),

              const SizedBox(height: AppSpacing.spacing16),

              // Botões de Redes Sociais lado a lado
              Row(
                children: [
                  Expanded(
                    child: _buildSocialButton(
                      text: 'Entrar com Facebook',
                      iconPath: 'assets/icons/facebook_logo.svg',
                      backgroundColor: const Color(0xFF1877F2), // Cor do Facebook
                      foregroundColor: AppColorsNeutral.neutral0, // Texto branco
                      onPressed: () {
                        // TODO: Implementar login com Facebook
                        print('Login com Facebook');
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spacing12),
                  Expanded(
                    child: _buildSocialButton(
                      text: 'Entrar com Google',
                      iconPath: 'assets/icons/google_logo.svg',
                      backgroundColor: const Color(0xFFEB4335), // Cor vermelha do Google
                      foregroundColor: AppColorsNeutral.neutral0, // Texto branco
                      onPressed: () {
                        // TODO: Implementar login com Google
                        print('Login com Google');
                      },
                    ),
                  ),
                ],
              ),

              const Spacer(), // Empurra o link para baixo

              // Link "Não tenho uma conta"
              TextButton(
                onPressed: () {
                  // TODO: Navegar para tela de Cadastro
                  print('Ir para Cadastro');
                },
                child: Text(
                  'Não tenho uma conta',
                  style: AppTypography.contentMedium.copyWith(
                    color: AppColorsPrimary.primary800, // Cor primária escura
                    decoration: TextDecoration.underline,
                    decorationColor: AppColorsPrimary.primary800,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.spacing16), // Espaço inferior
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para botões de login social
  Widget _buildSocialButton({
    required String text,
    required String iconPath,
    required Color backgroundColor,
    required Color foregroundColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        icon: SvgPicture.asset(
          iconPath,
          height: 18,
          colorFilter: ColorFilter.mode(foregroundColor, BlendMode.srcIn),
        ),
        label: Text(
          text,
          style: AppTypography.contentBold.copyWith(color: foregroundColor),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor.withOpacity(0.8), // Cor do splash
          minimumSize: const Size(0, 48), // Largura mínima 0 para funcionar no Row
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radius8,
          ),
          elevation: 0,
        ),
      ),
    );
  }
}