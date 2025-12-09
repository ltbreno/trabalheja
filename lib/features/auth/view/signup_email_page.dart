// lib/features/auth/view/signup_email_page.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';
import 'package:trabalheja/features/auth/view/signup_details_page.dart';

class SignUpEmailPage extends StatefulWidget {
  const SignUpEmailPage({super.key});

  @override
  State<SignUpEmailPage> createState() => _SignUpEmailPageState();
}

class _SignUpEmailPageState extends State<SignUpEmailPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _continue() {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text;
      print('Email para cadastro: $email');
      // Navegar para SignUpDetailsPage passando o email
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignUpDetailsPage(email: email),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsNeutral.neutral0,
      appBar: AppBar( // AppBar similar à tela de Login
        backgroundColor: AppColorsNeutral.neutral0,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/arrow_back.svg',
            height: 24,
            colorFilter: ColorFilter.mode(
              AppColorsNeutral.neutral900,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Voltar',
          style: AppTypography.contentMedium.copyWith(
            color: AppColorsNeutral.neutral900,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.spacing24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.spacing16),
                Text(
                  'Primeiro, vamos criar\nsua conta', // Título
                  style: AppTypography.heading1.copyWith(
                    color: AppColorsNeutral.neutral900,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing32), // Mais espaço

                // Campo de E-mail
                AppTextField(
                  label: 'Digite seu e-mail',
                  hintText: 'E-mail',
                  controller: _emailController,
                  prefixIconPath: 'assets/icons/mail.svg', // Ícone de email
                  keyboardType: TextInputType.emailAddress,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]'))],
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return 'Por favor, digite um e-mail válido';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.spacing24),

                // Botão Continuar
                AppButton.primary(
                  text: 'Continuar',
                  onPressed: _continue,
                  minWidth: double.infinity,
                ),

                const SizedBox(height: AppSpacing.spacing16),

                // Link "Já tenho uma conta"
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                         Navigator.pop(context); // Volta para a tela anterior (provavelmente LoginPage)
                      }
                    },
                    child: Text(
                      'Já tenho uma conta',
                      style: AppTypography.contentMedium.copyWith(
                        color: AppColorsPrimary.primary800,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColorsPrimary.primary800,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.spacing32), // Espaço antes do texto legal

                // Texto Legal (Termos e Política)
                Align(
                  alignment: Alignment.center,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: AppTypography.captionRegular.copyWith(color: AppColorsNeutral.neutral500),
                      children: [
                        const TextSpan(text: 'Ao se cadastrar, você concorda com nossos '),
                        TextSpan(
                          text: 'Termos e Condições',
                          style: const TextStyle(decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Ação para abrir Termos (manter vazio ou implementar se houver URL)
                            },
                        ),
                        const TextSpan(text: ' e '),
                        TextSpan(
                          text: 'Política de Privacidade',
                          style: const TextStyle(decoration: TextDecoration.underline),
                           recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Ação para abrir Política (manter vazio ou implementar se houver URL)
                            },
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),
                 const SizedBox(height: AppSpacing.spacing16), // Espaço inferior
              ],
            ),
          ),
        ),
      ),
    );
  }
}