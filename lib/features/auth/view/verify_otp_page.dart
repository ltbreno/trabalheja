import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';
import 'package:trabalheja/features/auth/view/reset_password_page.dart';

class VerifyOtpPage extends StatefulWidget {
  final String email;

  const VerifyOtpPage({
    super.key,
    required this.email,
  });

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;
  String? _feedbackMessage; // Variável para a mensagem de feedback centralizada
  bool _isFeedbackError = false; // Se a mensagem é de erro ou sucesso

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _showFeedback(String message, {bool isError = false}) {
    setState(() {
      _feedbackMessage = message;
      _isFeedbackError = isError;
    });
  }

  void _clearFeedback() {
    setState(() {
      _feedbackMessage = null;
      _isFeedbackError = false;
    });
  }

  Future<void> _verifyOtp() async {
    _clearFeedback(); // Limpa feedback anterior

    if (!(_formKey.currentState?.validate() ?? false)) {
      _showFeedback('Por favor, digite o código de verificação.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final otp = _otpController.text.trim();

      // Verificar o OTP code
      final response = await _supabase.auth.verifyOTP(
        email: widget.email,
        token: otp,
        type: OtpType.recovery,
      );

      if (!mounted) return;

      // Se o OTP for válido, navegar para a página de redefinição de senha
      if (response.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordPage(email: widget.email),
          ),
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;

      String errorMessage = 'Erro ao verificar código.';
      final message = e.message.toLowerCase();

      if (message.contains('invalid') || message.contains('expired')) {
        errorMessage = 'Código inválido ou expirado. Solicite um novo código.';
      } else if (message.contains('too many requests') || message.contains('rate limit')) {
        errorMessage = 'Muitas tentativas. Aguarde alguns instantes e tente novamente.';
      } else {
        errorMessage = e.message.isNotEmpty ? e.message : errorMessage;
      }

      _showFeedback(errorMessage, isError: true);
    } catch (e) {
      if (!mounted) return;

      _showFeedback('Erro ao verificar código: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    _clearFeedback(); // Limpa feedback anterior
    setState(() => _isLoading = true);

    try {
      await _supabase.auth.signInWithOtp(
        email: widget.email,
        shouldCreateUser: false,
        emailRedirectTo: null,
        data: {'type': 'recovery'},
      );

      if (!mounted) return;

      _showFeedback('Novo código enviado para seu email!', isError: false);
    } catch (e) {
      if (!mounted) return;

      _showFeedback('Erro ao reenviar código: ${e.toString()}', isError: true);
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
          'Verificar código',
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
                  'Digite o código de verificação',
                  style: AppTypography.heading3.copyWith(
                    color: AppColorsNeutral.neutral900,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing8),
                Text(
                  'Enviamos um código de 6 dígitos para ${widget.email}',
                  style: AppTypography.contentRegular.copyWith(
                    color: AppColorsNeutral.neutral600,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing16),
                // Mensagem de feedback centralizada
                if (_feedbackMessage != null) ...[
                  Text(
                    _feedbackMessage!,
                    textAlign: TextAlign.center,
                    style: AppTypography.contentMedium.copyWith(
                      color: _isFeedbackError ? AppColorsError.error500 : AppColorsPrimary.primary800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacing16),
                ],
                const SizedBox(height: AppSpacing.spacing32),

                // Campo de OTP
                AppTextField(
                  label: 'Código de verificação',
                  hintText: '000000',
                  controller: _otpController,
                  prefixIconPath: 'assets/icons/mail.svg',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite o código';
                    }
                    if (value.length < 6) {
                      return 'O código deve ter 6 dígitos';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.spacing32),

                // Botão Verificar
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : AppButton.primary(
                        text: 'Verificar código',
                        onPressed: _verifyOtp,
                        minWidth: double.infinity,
                      ),

                const SizedBox(height: AppSpacing.spacing16),

                // Botão Reenviar código
                TextButton(
                  onPressed: _isLoading ? null : _resendOtp,
                  child: Text(
                    'Reenviar código',
                    style: AppTypography.contentMedium.copyWith(
                      color: AppColorsPrimary.primary800,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColorsPrimary.primary800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

