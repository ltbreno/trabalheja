// lib/features/auth/view/email_login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';
import 'package:trabalheja/features/auth/view/reset_password_request_page.dart';
import 'package:trabalheja/l10n/app_localizations.dart';

class EmailLoginPage extends StatefulWidget {
  const EmailLoginPage({super.key});

  @override
  State<EmailLoginPage> createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage> {
  bool _isPasswordVisible = false;    
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;
  String? _errorMessage; // Variável para a mensagem de erro centralizada

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  void _clearError() {
    setState(() {
      _errorMessage = null;
    });
  }

  Future<void> _handleLogin() async {
    _clearError(); // Limpa erros anteriores ao tentar login

    // Validar o formulário antes de prosseguir
    if (!(_formKey.currentState?.validate() ?? false)) {
      _showError(AppLocalizations.of(context)!.fillFieldsCorrectly);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (response.user != null && response.session != null) {
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        _showError(AppLocalizations.of(context)!.loginErrorGeneric);
      }
    } on AuthException catch (e) {
      if (!mounted) return;

      String errorMessage = AppLocalizations.of(context)!.loginErrorGeneric;
      final message = e.message.toLowerCase();
      
      if (message.contains('invalid login credentials') ||
          (message.contains('invalid') && message.contains('credentials'))) {
        errorMessage = AppLocalizations.of(context)!.invalidCredentials;
      } else if (message.contains('email not confirmed') ||
                 message.contains('email_not_confirmed') ||
                 message.contains('unconfirmed email')) {
        errorMessage = AppLocalizations.of(context)!.emailNotConfirmed;
      } else if (message.contains('too many requests') ||
                 message.contains('rate limit')) {
        errorMessage = AppLocalizations.of(context)!.tooManyRequests;
      } else {
        errorMessage = e.message.isNotEmpty ? e.message : AppLocalizations.of(context)!.loginErrorGeneric;
      }

      _showError(errorMessage);
    } catch (e) {
      if (!mounted) return;
      _showError('Erro ao fazer login: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          AppLocalizations.of(context)!.back,
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

                // Mensagem de erro centralizada
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: AppTypography.contentMedium.copyWith(
                      color: AppColorsError.error500, // Cor de erro
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacing16), // Espaçamento após a mensagem de erro
                ],

                // Campo de E-mail
                AppTextField(
                  label: AppLocalizations.of(context)!.enterEmail,
                  hintText: AppLocalizations.of(context)!.emailHint,
                  controller: _emailController,
                  prefixIconPath: 'assets/icons/mail.svg', // Ícone de email
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) { // Exemplo de validação simples
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.enterEmail;
                    }
                    if (!value.contains('@')) { // Validação básica de email
                       return AppLocalizations.of(context)!.invalidEmail;
                    }
                    return null; // Válido
                  },
                ),

                const SizedBox(height: AppSpacing.spacing24), // Espaço entre os campos

                // Campo de Senha
                AppTextField(
                  label: AppLocalizations.of(context)!.enterPassword,
                  hintText: AppLocalizations.of(context)!.passwordHint,
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
                      return AppLocalizations.of(context)!.enterPassword;
                    }
                     if (value.length < 6) { // Exemplo: mínimo 6 caracteres
                       return AppLocalizations.of(context)!.passwordMinLength;
                     }
                    return null; // Válido
                  },
                ),

                const SizedBox(height: AppSpacing.spacing32), // Espaço antes do botão Entrar

                // Botão Entrar
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : AppButton.primary(
                        text: AppLocalizations.of(context)!.loginButton,
                        onPressed: _handleLogin,
                        minWidth: double.infinity,
                      ),

                const SizedBox(height: AppSpacing.spacing16), // Espaço antes do link

                // Link Esqueci minha senha
                Align(  
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ResetPasswordRequestPage(),
                        ),
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context)!.forgotPassword,
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