// lib/features/auth/view/email_login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';
import 'package:trabalheja/features/onboarding/view/onboarding_page.dart';

class EmailLoginPage extends StatefulWidget { // Alterado para StatefulWidget
  const EmailLoginPage({super.key});

  @override
  State<EmailLoginPage> createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage> {
  bool _isPasswordVisible = false; // Estado para controlar visibilidade da senha
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Chave para o formulário

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsNeutral.neutral0,
      appBar: AppBar(
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
               Navigator.pop(context); // Ação de voltar padrão
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
        child: SingleChildScrollView( // Permite rolagem se o teclado cobrir os campos
          padding: const EdgeInsets.all(AppSpacing.spacing24),
          child: Form( // Envolve os campos em um Form
             key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.spacing16), // Espaço após AppBar

                // Campo de E-mail
                AppTextField(
                  label: 'Digite seu e-mail',
                  hintText: 'E-mail',
                  controller: _emailController,
                  prefixIconPath: 'assets/icons/mail.svg', // Ícone de email
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) { // Exemplo de validação simples
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite seu e-mail';
                    }
                    if (!value.contains('@')) { // Validação básica de email
                       return 'Por favor, digite um e-mail válido';
                    }
                    return null; // Válido
                  },
                ),

                const SizedBox(height: AppSpacing.spacing24), // Espaço entre os campos

                // Campo de Senha
                AppTextField(
                  label: 'Digite sua senha',
                  hintText: 'Senha',
                  controller: _passwordController,
                  prefixIconPath: 'assets/icons/lock.svg', // Ícone de cadeado
                  obscureText: !_isPasswordVisible, // Controla a visibilidade
                  suffixIconPath: _isPasswordVisible
                      ? 'assets/icons/eye_off.svg' // Ícone olho fechado
                      : 'assets/icons/eye.svg', // Ícone olho aberto
                  onSuffixIconTap: () {
                    setState(() { // Atualiza o estado para alternar a visibilidade
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                   validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite sua senha';
                    }
                     if (value.length < 6) { // Exemplo: mínimo 6 caracteres
                       return 'A senha deve ter pelo menos 6 caracteres';
                     }
                    return null; // Válido
                  },
                ),

                const SizedBox(height: AppSpacing.spacing32), // Espaço antes do botão Entrar

                // Botão Entrar
                AppButton.primary(
                  text: 'Entrar',
                  onPressed: () {
                    // Validar o formulário antes de prosseguir
                    if (_formKey.currentState?.validate() ?? false) {
                       // Se o formulário for válido, execute a lógica de login
                       String email = _emailController.text;
                       String password = _passwordController.text;
                       print('Email: $email, Senha: $password');
                       // TODO: Implementar lógica de autenticação
                       Navigator.push(context, MaterialPageRoute(builder: (context) => const OnboardingPage()));
                    }
                  },
                  minWidth: double.infinity,
                ),

                const SizedBox(height: AppSpacing.spacing16), // Espaço antes do link

                // Link Esqueci minha senha
                Align(  
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navegar para tela de recuperação de senha
                      print('Esqueci minha senha');
                    },
                    child: Text(
                      'Esqueci minha senha',
                      style: AppTypography.contentMedium.copyWith(
                        color: AppColorsPrimary.primary800, // Cor primária escura
                        decoration: TextDecoration.underline,
                        decorationColor: AppColorsPrimary.primary800,
                      ),
                    ),
                  ),
                ),
                 // const Spacer(), // Removido para não empurrar tudo para cima
                 const SizedBox(height: AppSpacing.spacing32), // Espaço inferior
              ],
            ),
          ),
        ),
      ),
    );
  }
} 