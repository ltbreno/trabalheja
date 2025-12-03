import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/core/widgets/MainAppShell.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newPassword = _passwordController.text;

      // Atualizar a senha no Supabase
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (!mounted) return;

      // Senha atualizada com sucesso - fazer login automático
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha redefinida com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navegar para a tela principal
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainAppShell()),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;

      String errorMessage = 'Erro ao redefinir senha.';
      final message = e.message.toLowerCase();

      if (message.contains('password') && message.contains('weak')) {
        errorMessage = 'A senha é muito fraca. Use uma senha mais forte.';
      } else if (message.contains('token') || message.contains('expired')) {
        errorMessage = 'Link expirado ou inválido. Solicite uma nova redefinição.';
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
          content: Text('Erro ao redefinir senha: ${e.toString()}'),
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
          'Nova senha',
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
                  'Defina sua nova senha',
                  style: AppTypography.heading3.copyWith(
                    color: AppColorsNeutral.neutral900,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing8),
                Text(
                  'Digite uma nova senha segura para sua conta.',
                  style: AppTypography.contentRegular.copyWith(
                    color: AppColorsNeutral.neutral600,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing32),

                // Campo de Nova Senha
                AppTextField(
                  label: 'Nova senha',
                  hintText: 'Senha',
                  controller: _passwordController,
                  prefixIconPath: 'assets/icons/lock.svg',
                  obscureText: !_isPasswordVisible,
                  suffixIconPath: _isPasswordVisible
                      ? 'assets/icons/eye_off.svg'
                      : 'assets/icons/eye.svg',
                  onSuffixIconTap: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite sua nova senha';
                    }
                    if (value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.spacing24),

                // Campo de Confirmar Senha
                AppTextField(
                  label: 'Confirmar nova senha',
                  hintText: 'Confirme sua senha',
                  controller: _confirmPasswordController,
                  prefixIconPath: 'assets/icons/lock.svg',
                  obscureText: !_isConfirmPasswordVisible,
                  suffixIconPath: _isConfirmPasswordVisible
                      ? 'assets/icons/eye_off.svg'
                      : 'assets/icons/eye.svg',
                  onSuffixIconTap: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, confirme sua senha';
                    }
                    if (value != _passwordController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.spacing32),

                // Botão Redefinir
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : AppButton.primary(
                        text: 'Redefinir senha',
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

