// lib/features/auth/view/client_cpf_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';
import 'package:trabalheja/features/auth/view/client_birthdate_page.dart';

class ClientCpfPage extends StatefulWidget {
  final String email;
  final String phone;
  final String fullName;

  const ClientCpfPage({
    super.key,
    required this.email,
    required this.phone,
    required this.fullName,
  });

  @override
  State<ClientCpfPage> createState() => _ClientCpfPageState();
}

class _ClientCpfPageState extends State<ClientCpfPage> {
  final _cpfController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _cpfController.dispose();
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
    _clearError();

    if (!(_formKey.currentState?.validate() ?? false)) {
      _showError('Por favor, preencha o CPF corretamente.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cpf = _cpfController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final user = _supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Salvar CPF no perfil
      await _supabase.from('profiles').update({
        'cpf': cpf,
      }).eq('id', user.id);

      print('✅ [ClientCpfPage] CPF salvo com sucesso!');

      if (!mounted) return;

      // Navegar para ClientBirthdatePage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClientBirthdatePage(
            email: widget.email,
            phone: widget.phone,
            fullName: widget.fullName,
            cpf: cpf,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Erro ao salvar CPF: ${e.toString()}');
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
                  'Qual é o seu CPF?',
                  style: AppTypography.heading1.copyWith(
                    color: AppColorsNeutral.neutral900,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing8),
                Text(
                  'Precisamos do seu CPF para processar pagamentos de forma segura.',
                  style: AppTypography.contentRegular.copyWith(
                    color: AppColorsNeutral.neutral600,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing32),

                // Mensagem de erro centralizada
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: AppTypography.contentMedium.copyWith(
                      color: AppColorsError.error500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacing16),
                ],

                // Campo CPF
                AppTextField(
                  label: 'CPF',
                  hintText: '000.000.000-00',
                  controller: _cpfController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _CpfInputFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, informe seu CPF';
                    }
                    final cpf = value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (cpf.length != 11) {
                      return 'CPF deve conter 11 dígitos';
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

/// Formatter para CPF: 000.000.000-00
class _CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length && i < 11; i++) {
      if (i == 3 || i == 6) {
        buffer.write('.');
      } else if (i == 9) {
        buffer.write('-');
      }
      buffer.write(digits[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
