// lib/features/auth/view/complete_name_page.dart
import 'package:flutter/material.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';
// Importe a próxima página de endereço
import 'address_page.dart';

class CompleteNamePage extends StatefulWidget {
  // Receber dados das telas anteriores, se necessário (email, tipo de conta, etc.)
  // final AccountType accountType;

  const CompleteNamePage({
    super.key,
    // required this.accountType,
  });

  @override
  State<CompleteNamePage> createState() => _CompleteNamePageState();
}

class _CompleteNamePageState extends State<CompleteNamePage> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _continue() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text;
      print('Nome completo: $name');
      // TODO: Navegar para AddressPage passando os dados acumulados
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddressPage(
                // Passar dados como nome, email, tipo de conta...
              // fullName: name,
              // accountType: widget.accountType,
              ),
        ),
      );
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
                  'Nome completo', // Título
                  style: AppTypography.heading1.copyWith(
                    color: AppColorsNeutral.neutral900,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing32), // Mais espaço

                // Campo Nome Completo
                AppTextField( // Usando AppTextField em vez de TextField
                  label: 'Informe seu nome completo', // Usando label como na imagem
                  hintText: 'Nome completo', // Placeholder
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, informe seu nome completo';
                    }
                     if (value.trim().split(' ').length < 2) { // Validação simples para nome + sobrenome
                      return 'Por favor, informe nome e sobrenome';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.spacing32), // Espaço antes do botão

                // Botão Continuar
                AppButton.primary(
                  text: 'Continuar',
                  onPressed: _continue,
                  minWidth: double.infinity,
                ),

                const SizedBox(height: AppSpacing.spacing16), // Espaço inferior
              ],
            ),
          ),
        ),
      ),
    );
  }
}