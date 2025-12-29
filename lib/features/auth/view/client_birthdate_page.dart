// lib/features/auth/view/client_birthdate_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';
import 'package:trabalheja/features/auth/view/address_page.dart';

class ClientBirthdatePage extends StatefulWidget {
  final String email;
  final String phone;
  final String fullName;
  final String cpf;

  const ClientBirthdatePage({
    super.key,
    required this.email,
    required this.phone,
    required this.fullName,
    required this.cpf,
  });

  @override
  State<ClientBirthdatePage> createState() => _ClientBirthdatePageState();
}

class _ClientBirthdatePageState extends State<ClientBirthdatePage> {
  final _birthdateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _birthdateController.dispose();
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
      _showError('Por favor, preencha a data de nascimento corretamente.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final birthdate = _birthdateController.text.trim();
      
      // Converter de DD/MM/AAAA para YYYY-MM-DD (Formato aceito pelo PostgreSQL)
      final parts = birthdate.split('/');
      if (parts.length != 3) {
         throw Exception('Formato de data inválido');
      }
      final dateIso = '${parts[2]}-${parts[1]}-${parts[0]}';

      final user = _supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Salvar data de nascimento no perfil
      await _supabase.from('profiles').update({
        'birthdate': dateIso, // Usar data formatada
      }).eq('id', user.id);

      print('✅ [ClientBirthdatePage] Data de nascimento salva com sucesso!');

      if (!mounted) return;

      // Navegar para AddressPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddressPage(
            fullName: widget.fullName,
            email: widget.email,
            phone: widget.phone,
            cpf: widget.cpf,
            birthdate: birthdate,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Erro ao salvar data de nascimento: ${e.toString()}');
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
                  'Qual é a sua data de nascimento?',
                  style: AppTypography.heading1.copyWith(
                    color: AppColorsNeutral.neutral900,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing8),
                Text(
                  'Essa informação é necessária para validar sua identidade.',
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

                // Campo Data de Nascimento
                AppTextField(
                  label: 'Data de Nascimento',
                  hintText: 'DD/MM/AAAA',
                  controller: _birthdateController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _DateInputFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, informe sua data de nascimento';
                    }
                    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (digits.length != 8) {
                      return 'Data inválida. Use o formato DD/MM/AAAA';
                    }
                    
                    // Validar data
                    try {
                      final day = int.parse(digits.substring(0, 2));
                      final month = int.parse(digits.substring(2, 4));
                      final year = int.parse(digits.substring(4, 8));
                      
                      if (day < 1 || day > 31) return 'Dia inválido';
                      if (month < 1 || month > 12) return 'Mês inválido';
                      if (year < 1900 || year > DateTime.now().year) return 'Ano inválido';
                      
                      final date = DateTime(year, month, day);
                      final now = DateTime.now();
                      final age = now.year - date.year;
                      
                      if (age < 18) {
                        return 'Você precisa ter pelo menos 18 anos';
                      }
                    } catch (e) {
                      return 'Data inválida';
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

/// Formatter para data: DD/MM/AAAA
class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length && i < 8; i++) {
      if (i == 2 || i == 4) {
        buffer.write('/');
      }
      buffer.write(digits[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
