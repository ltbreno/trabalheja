import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';
import 'package:trabalheja/features/auth/view/verify_otp_page.dart';

class ResetPasswordRequestPage extends StatefulWidget {
  const ResetPasswordRequestPage({super.key});

  @override
  State<ResetPasswordRequestPage> createState() => _ResetPasswordRequestPageState();
}

class _ResetPasswordRequestPageState extends State<ResetPasswordRequestPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();

      // Solicitar OTP code para redefinição de senha
      await _supabase.auth.signInWithOtp(
        email: email,
        shouldCreateUser: false,
        emailRedirectTo: null,
        data: {'type': 'recovery'},
      );

      if (!mounted) return;

      // Navegar para página de verificação de OTP
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyOtpPage(email: email),
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;

      String errorMessage = 'Erro ao solicitar redefinição de senha.';
      final message = e.message.toLowerCase();

      if (message.contains('invalid email') || message.contains('email not found')) {
        errorMessage = 'Email não encontrado. Verifique e tente novamente.';
      } else if (message.contains('too many requests') || message.contains('rate limit')) {
        errorMessage = 'Muitas tentativas. Aguarde alguns instantes e tente novamente.';
      } else {
        errorMessage = e.message.isNotEmpty ? e.message : errorMessage;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao solicitar redefinição de senha: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Redefinir senha',
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

                // Título e descrição
                  Text(
                    'Esqueceu sua senha?',
                    style: AppTypography.heading3.copyWith(
                      color: AppColorsNeutral.neutral900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacing8),
                  Text(
                    'Digite seu email e enviaremos um código de verificação (OTP) para redefinir sua senha.',
                    style: AppTypography.contentRegular.copyWith(
                      color: AppColorsNeutral.neutral600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacing32),

                  // Campo de E-mail
                  AppTextField(
                    label: 'Digite seu e-mail',
                    hintText: 'E-mail',
                    controller: _emailController,
                    prefixIconPath: 'assets/icons/mail.svg',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, digite seu e-mail';
                      }
                      if (!value.contains('@')) {
                        return 'Por favor, digite um e-mail válido';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSpacing.spacing32),

                  // Botão Enviar
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : AppButton.primary(
                          text: 'Enviar código OTP',
                          onPressed: _handleResetPassword,
                          minWidth: double.infinity,
                        ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

