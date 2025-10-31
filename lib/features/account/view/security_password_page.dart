import 'package:flutter/material.dart';
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

  void _saveChanges() {
     if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    // TODO: Implementar lógica de atualização de senha no Supabase
    // (ex: supabase.auth.updateUser(UserAttributes(password: newPassword)))
    // Você pode precisar autenticar novamente o usuário com a senha atual primeiro.
    print('Salvando nova senha...');
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha atualizada com sucesso!')),
      );
      Navigator.pop(context);
    });
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
                    color: AppColorsNeutral.neutral900,
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