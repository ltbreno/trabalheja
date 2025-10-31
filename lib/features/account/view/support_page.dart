import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendSupportMessage() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    // TODO: Implementar lógica de envio para o backend/Supabase
    print('Assunto: ${_subjectController.text}');
    print('Mensagem: ${_messageController.text}');

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mensagem enviada com sucesso!')),
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
          icon: Icon(Icons.arrow_back, color: AppColorsPrimary.primary900),
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
                // Ícone de check
                Center(
                  child: Icon(
                    Icons.check_circle,
                    color: AppColorsSuccess.success500,
                    size: 60,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing16),
                // Título
                Text(
                  'Fale com o suporte',
                  textAlign: TextAlign.center,
                  style: AppTypography.heading1.copyWith(
                    color: AppColorsPrimary.primary900, // Cor roxa
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing32),

                // Campo "Qual sua dúvida ou problema?"
                AppTextField(
                  label: 'Qual sua dúvida ou problema?',
                  hintText: 'Resuma sua dúvida ou problema',
                  controller: _subjectController,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira um assunto';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.spacing16),

                // Campo "Mensagem" (com altura específica)
                AppTextField(
                  label: 'Mensagem',
                  hintText: 'Descreva sua dúvida ou problema',
                  controller: _messageController,
                  keyboardType: TextInputType.multiline,
                  minLines: 6,
                  maxLines: 6,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]'))],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, descreva sua mensagem';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.spacing32),

                // Botão Enviar
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : AppButton.primary(
                        text: 'Enviar',
                        onPressed: _sendSupportMessage,
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
