// lib/features/auth/view/complete_name_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';
// Importe a próxima página de endereço
import 'address_page.dart';

class CompleteNamePage extends StatefulWidget {
  final String email;
  final String phone;

  const CompleteNamePage({
    super.key,
    required this.email,
    required this.phone,
  });

  @override
  State<CompleteNamePage> createState() => _CompleteNamePageState();
}

class _CompleteNamePageState extends State<CompleteNamePage> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;
  String? _errorMessage; // Variável para a mensagem de erro centralizada

  @override
  void dispose() {
    _nameController.dispose();
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
      _showError('Por favor, preencha seu nome completo.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final user = _supabase.auth.currentUser;
      
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Preparar dados para atualização
      final updateData = <String, dynamic>{
        'full_name': name,
        'email': widget.email,
        'phone': widget.phone,
      };

      // Debug: mostrar o que será enviado
      print('📤 [CompleteNamePage] Enviando UPDATE para Supabase:');
      print('   - full_name: ${updateData['full_name']}');
      print('   - email: ${updateData['email']}');
      print('   - phone: ${updateData['phone']}');
      print('   - user.id: ${user.id}');

      // Atualizar perfil (UPDATE - o perfil já existe pois foi criado na página anterior)
      await _supabase.from('profiles').update(updateData).eq('id', user.id);

      print('✅ [CompleteNamePage] Dados atualizados com sucesso!');

      if (!mounted) return;

      // Navegar para AddressPage passando o nome
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddressPage(fullName: name),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Erro ao salvar nome: ${e.toString()}');
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
                  'Nome completo', // Título
                  style: AppTypography.heading1.copyWith(
                    color: AppColorsNeutral.neutral900,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing32), // Mais espaço

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
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : AppButton.primary(
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