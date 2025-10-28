// lib/features/auth/view/signup_details_page.dart
import 'package:flutter/material.dart';   
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart'; // Importar máscara
import 'package:supabase_flutter/supabase_flutter.dart'; // Importar Supabase
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';

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
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

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

  Future<void> _signUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);

    final phone = _phoneController.text; // Ou use _phoneMaskFormatter.getUnmaskedText()
    final password = _passwordController.text;

    try {
      // Usa o email recebido e a senha digitada
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: widget.email, // Usa o e-mail da tela anterior
        password: password,
        // Adiciona o telefone aos metadados do usuário (opcional)
        // Certifique-se que 'phone' está habilitado nos User Metadata no Supabase Auth Settings
        data: {'phone': phone},
      );

       if (!mounted) return;

       // Verificar se precisa de confirmação de e-mail (config Supabase)
       final session = res.session;
       final user = res.user;

       if (user != null) {
          if (session != null) {
              // Login automático após cadastro (sem confirmação de email ou já confirmado)
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Conta criada com sucesso!')),
              );
              // TODO: Navegar para a tela principal do app
              // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomePage()), (route) => false);
          } else {
             // Precisa confirmar e-mail
             ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Verifique seu e-mail para confirmar a conta.')),
             );
             // TODO: Voltar para a tela de login ou mostrar mensagem
             Navigator.of(context).popUntil((route) => route.isFirst); // Volta para a primeira tela da pilha (WelcomePage?)
          }
       } else {
           // Caso inesperado ou erro silencioso
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Algo deu errado. Tente novamente.')),
            );
       }

    } on AuthException catch (error) {
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Erro: ${error.message}')),
       );
    } catch (error) {
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Erro inesperado: $error')),
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

                // Botão Continuar (Finalizar Cadastro)
                _isLoading
                   ? const Center(child: CircularProgressIndicator())
                   : AppButton.primary(
                      text: 'Continuar',
                      onPressed: _signUp, // Chama a função final de cadastro
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