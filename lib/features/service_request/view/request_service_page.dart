import 'package:flutter/material.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_dropdown_field.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';
import 'package:trabalheja/features/service_request/view/request_success_page.dart'; // Importar tela de sucesso

class RequestServicePage extends StatefulWidget {
  const RequestServicePage({super.key});

  @override
  State<RequestServicePage> createState() => _RequestServicePageState();
}

class _RequestServicePageState extends State<RequestServicePage> {
  final _serviceController = TextEditingController();
  final _budgetController = TextEditingController();
  final _timeValueController = TextEditingController();
  final _infoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _selectedTimeUnit = 'Horas';

  final List<DropdownItem<String>> _timeOptions = [
    DropdownItem(value: 'Horas', label: 'Horas'),
    DropdownItem(value: 'Dias', label: 'Dias'),
    DropdownItem(value: 'Semanas', label: 'Semanas'),
    DropdownItem(value: 'Meses', label: 'Meses'),
  ];

  @override
  void dispose() {
    _serviceController.dispose();
    _budgetController.dispose();
    _timeValueController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  void _submitRequest() {
     if (!(_formKey.currentState?.validate() ?? false)) return;

     setState(() => _isLoading = true);
     // TODO: Implementar lógica de envio da solicitação (ex: Supabase)
     print('Solicitando serviço...');
     print('Serviço: ${_serviceController.text}');
     print('Orçamento: ${_budgetController.text}');
     print('Tempo: ${_timeValueController.text} ${_selectedTimeUnit}');
     print('Info: ${_infoController.text}');

     Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _isLoading = false);
        // Navegar para a tela de sucesso
        Navigator.pushReplacement( // Substitui a tela atual pela de sucesso
          context,
          MaterialPageRoute(builder: (context) => const RequestSuccessPage()),
        );
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
                  'Solicitar serviço',
                  style: AppTypography.heading1.copyWith(
                    color: AppColorsPrimary.primary900, // Cor roxa
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing32),
                
                AppTextField(
                  label: 'Qual serviço você precisa?',
                  hintText: 'ex: Trocar chuveiro',
                  controller: _serviceController,
                  validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
                  textColor: AppColorsPrimary.primary950,
                  labelColor: AppColorsPrimary.primary950,
                ),
                const SizedBox(height: AppSpacing.spacing16),
                
                AppTextField(
                  label: 'Qual seu orçamento para o serviço?',
                  hintText: 'R\$ 0,00',
                  controller: _budgetController,
                  textColor: AppColorsPrimary.primary950,
                  labelColor: AppColorsPrimary.primary950,
                  keyboardType: TextInputType.number,
                  prefixIconPath: 'assets/icons/money.svg', // Ícone de dinheiro
                  iconColor: AppColorsPrimary.primary950,
                  prefixIconSize: 16,
                  validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: AppSpacing.spacing16),
                
                // Campos de tempo: valor + unidade
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Em quanto tempo você precisa?',
                      style: AppTypography.captionMedium.copyWith(
                        color: AppColorsPrimary.primary950,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: '',
                            hintText: '8',
                            controller: _timeValueController,
                            textColor: AppColorsPrimary.primary950,
                            keyboardType: TextInputType.number,
                            validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.spacing8),
                        Expanded(
                          child: AppDropdownField<String>(
                            label: '',
                            hintText: 'Unidade',
                            items: _timeOptions,
                            selectedValue: _selectedTimeUnit,
                            onChanged: (value) {
                              setState(() {
                                _selectedTimeUnit = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spacing8),

                AppTextField(
                  label: 'Informações adicionais',
                  hintText: 'Adicione informações adicionais para o freelancer calcular melhor a proposta',
                  controller: _infoController,
                  keyboardType: TextInputType.multiline,
                  minLines: 4,
                  maxLines: 6,
                  textColor: AppColorsPrimary.primary950,
                  labelColor: AppColorsPrimary.primary950,
                ),
                const SizedBox(height: AppSpacing.spacing16),

                // Aviso de Privacidade
                Container(
                  padding: const EdgeInsets.all(AppSpacing.spacing12),
                  decoration: BoxDecoration(
                    color: AppColorsError.error50,
                    borderRadius: AppRadius.radius8,
                  ),
                  child: Text(
                    'Não inclua seus dados pessoais ou de contato na descrição. Toda negociação deve ser feita pelo aplicativo.',
                    style: AppTypography.captionRegular.copyWith(color: AppColorsNeutral.neutral700),
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing32),

                // Botão Enviar
                _isLoading
                   ? const Center(child: CircularProgressIndicator())
                   : AppButton.primary(
                      text: 'Solicitar serviço',
                      onPressed: _submitRequest,
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
