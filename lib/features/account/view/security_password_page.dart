import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';

class SecurityPasswordPage extends StatefulWidget {
  const SecurityPasswordPage({super.key});

  @override
  State<SecurityPasswordPage> createState() => _SecurityPasswordPageState();
}

class _SecurityPasswordPageState extends State<SecurityPasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  bool _isCurrentVisible = false;
  bool _isNewVisible = false;
  bool _isConfirmVisible = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      // Obter usuário atual e email
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      final email = user.email;
      if (email == null || email.isEmpty) {
        throw Exception('Email do usuário não encontrado');
      }

      final currentPassword = _currentPasswordController.text;
      final newPassword = _newPasswordController.text;

      // Validar a senha atual fazendo login
      try {
        await _supabase.auth.signInWithPassword(
          email: email,
          password: currentPassword,
        );
      } on AuthException catch (e) {
        if (!mounted) return;

        String errorMessage = 'Senha atual incorreta.';
        final message = e.message.toLowerCase();

        if (message.contains('invalid') || message.contains('credentials')) {
          errorMessage = 'Senha atual incorreta. Verifique e tente novamente.';
        } else {
          errorMessage = e.message.isNotEmpty ? e.message : errorMessage;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Se chegou aqui, a senha atual é válida
      // Agora atualizar para a nova senha
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (!mounted) return;

      // Sucesso!
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha atualizada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } on AuthException catch (e) {
      if (!mounted) return;

      String errorMessage = 'Erro ao atualizar senha.';
      final message = e.message.toLowerCase();

      if (message.contains('password') && message.contains('weak')) {
        errorMessage = 'A nova senha é muito fraca. Use uma senha mais forte.';
      } else if (message.contains('same')) {
        errorMessage = 'A nova senha deve ser diferente da senha atual.';
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
          content: Text('Erro ao atualizar senha: ${e.toString()}'),
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
          icon: Icon(Icons.arrow_back, color: AppColorsNeutral.neutral900),
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
                  'Segurança e senha',
                  style: AppTypography.heading1.copyWith(
                    color: AppColorsPrimary.primary900,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing32),

                // Senha atual
                AppTextField(
                  label: 'Senha atual',
                  hintText: 'Digite sua senha',
                  controller: _currentPasswordController,
                  obscureText: !_isCurrentVisible,
                  prefixIconPath: 'assets/icons/lock.svg',
                  suffixIconPath: _isCurrentVisible ? 'assets/icons/eye_off.svg' : 'assets/icons/eye.svg',
                  onSuffixIconTap: () => setState(() => _isCurrentVisible = !_isCurrentVisible),
                  textColor: AppColorsPrimary.primary900,
                  iconColor: AppColorsPrimary.primary800,
                  validator: (value) {
                     if (value == null || value.isEmpty) return 'Informe sua senha atual';
                     return null;
                  },
                ),
                const SizedBox(height: AppSpacing.spacing16),
                
                // Nova senha
                AppTextField(
                  label: 'Nova senha',
                  hintText: 'Digite sua nova senha',
                  controller: _newPasswordController,
                  obscureText: !_isNewVisible,
                  prefixIconPath: 'assets/icons/lock.svg',
                  suffixIconPath: _isNewVisible ? 'assets/icons/eye_off.svg' : 'assets/icons/eye.svg',
                  onSuffixIconTap: () => setState(() => _isNewVisible = !_isNewVisible),
                  textColor: AppColorsPrimary.primary900,
                  iconColor: AppColorsPrimary.primary800,
                   validator: (value) {
                    if (value == null || value.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.spacing16),
                
                // Confirme a senha
                AppTextField(
                  label: 'Confirme a senha',
                  hintText: 'Digite novamente sua senha',
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmVisible,
                  prefixIconPath: 'assets/icons/lock.svg',
                   suffixIconPath: _isConfirmVisible ? 'assets/icons/eye_off.svg' : 'assets/icons/eye.svg',
                  onSuffixIconTap: () => setState(() => _isConfirmVisible = !_isConfirmVisible),
                  textColor: AppColorsPrimary.primary900,
                  iconColor: AppColorsPrimary.primary800,
                   validator: (value) {
                    if (value == null || value.isEmpty) return 'Confirme sua nova senha';
                    if (value != _newPasswordController.text) return 'As senhas não coincidem';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.spacing32),

                // Botão Salvar
                _isLoading
                   ? const Center(child: CircularProgressIndicator())
                   : AppButton.primary(
                      text: 'Salvar alterações',
                      onPressed: _saveChanges,
                      minWidth: double.infinity,
                    ),
                const SizedBox(height: AppSpacing.spacing16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}