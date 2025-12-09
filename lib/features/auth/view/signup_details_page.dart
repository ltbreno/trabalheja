// lib/features/auth/view/signup_details_page.dart
import 'package:flutter/material.dart';   
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';
import 'package:trabalheja/features/auth/view/select_account_type_page.dart';

class SignUpDetailsPage extends StatefulWidget {
  final String email; // Recebe o e-mail da tela anterior

  const SignUpDetailsPage({super.key, required this.email});

  @override
  State<SignUpDetailsPage> createState() => _SignUpDetailsPageState();
}

class _SignUpDetailsPageState extends State<SignUpDetailsPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage; // Variável para a mensagem de erro centralizada

  // Máscara para telefone (ajuste conforme necessário para seu país)
  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

   @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  Future<void> _continue() async {
    _clearError(); // Limpa erros anteriores

    if (!(_formKey.currentState?.validate() ?? false)) {
      _showError('Por favor, preencha todos os campos corretamente.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final phone = _phoneController.text;
      final password = _passwordController.text;
      
      // Criar conta no Supabase
      final response = await _supabase.auth.signUp(
        email: widget.email,
        password: password,
        data: {
          'phone': phone, // Salvar telefone nos metadados do usuário
        },
      );

      if (!mounted) return;

      if (response.user != null) {
        // Conta criada com sucesso
        // O perfil será criado apenas após o usuário selecionar o account_type
        // Isso é necessário porque a política RLS exige account_type no INSERT
        
        if (!mounted) return;
        
        // Navegar para a página de seleção de tipo de conta
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectAccountTypePage(
              email: widget.email,
              phone: phone,
            ),
          ),
        );
      } else {
        // Erro ao criar conta
        _showError('Erro ao criar conta. Tente novamente.');
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      
      // Tratar erros específicos do Supabase
      String errorMessage = 'Erro ao criar conta.';
      if (e.message.contains('already registered')) {
        errorMessage = 'Este email já está cadastrado.';
      } else if (e.message.contains('invalid')) {
        errorMessage = 'Email ou senha inválidos.';
      } else {
        errorMessage = e.message;
      }
      
      _showError(errorMessage);
    } catch (e) {
      if (!mounted) return;
      
      _showError('Erro ao criar conta: ${e.toString()}');
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
                  'Por último, precisamos\nde mais alguns dados', // Título
                  style: AppTypography.heading1.copyWith(
                    color: AppColorsNeutral.neutral900,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing8),
                Text(
                  'Vamos precisar que informe alguns dados extras de segurança e contato.', // Subtítulo
                  style: AppTypography.contentRegular.copyWith(
                    color: AppColorsNeutral.neutral600,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing16),
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
                const SizedBox(height: AppSpacing.spacing32),

                // Campo de Telefone com Máscara
                AppTextField(
                  label: 'Qual seu telefone?',
                  hintText: '(00) 00000-0000', // Exibe a máscara como hint
                  controller: _phoneController,
                  prefixIconPath: 'assets/icons/phone.svg', // Adapte o ícone
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_phoneMaskFormatter], // Aplica a máscara
                  validator: (value) {
                     if (value == null || value.isEmpty) {
                       return 'Por favor, digite seu telefone';
                     }
                      // Validação adicional do telefone, se necessário
                     if (!_phoneMaskFormatter.isFill()) {
                        return 'Telefone incompleto';
                     }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.spacing16),

                // Campo Senha
                AppTextField(
                  label: 'Escolha uma senha',
                  hintText: 'Digite uma senha',
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  prefixIconPath: 'assets/icons/lock.svg',
                  suffixIconPath: _isPasswordVisible
                      ? 'assets/icons/eye_off.svg'
                      : 'assets/icons/eye.svg',
                  onSuffixIconTap: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.spacing16),

                // Campo Confirmar Senha
                AppTextField(
                  label: 'Confirme a senha',
                  hintText: 'Digite novamente a senha',
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                   prefixIconPath: 'assets/icons/lock.svg',
                   suffixIconPath: _isConfirmPasswordVisible
                      ? 'assets/icons/eye_off.svg'
                      : 'assets/icons/eye.svg',
                  onSuffixIconTap: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
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

                // Botão Continuar
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : AppButton.primary(
                        text: 'Continuar',
                        onPressed: _continue,
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