// lib/features/auth/view/freelancer_address_page.dart
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/auth/view/freelancer_radius_page.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';

class FreelancerAddressPage extends StatefulWidget {
  // Receber dados das telas anteriores (nome, email, tipo de conta, etc.)
  // final String fullName;
  // final AccountType accountType;

  const FreelancerAddressPage({
    super.key,
    // required this.fullName,
    // required this.accountType,
  });

  @override
  State<FreelancerAddressPage> createState() => _FreelancerAddressPageState();
}

class _FreelancerAddressPageState extends State<FreelancerAddressPage> {
  final _cepController = TextEditingController();
  final _bairroController = TextEditingController();
  final _ruaController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _cidadeController = TextEditingController(text: 'São Paulo, SP'); // Pré-preenchido
  final _formKey = GlobalKey<FormState>();

  // Máscara para CEP
  final _cepMaskFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _cepController.dispose();
    _bairroController.dispose();
    _ruaController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _cidadeController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final addressData = {
      'cep': _cepController.text, // ou _cepMaskFormatter.getUnmaskedText()
      'bairro': _bairroController.text,
      'rua': _ruaController.text,
      'numero': _numeroController.text,
      'complemento': _complementoController.text,
      'cidade': _cidadeController.text,
    };

    print('Dados de endereço: $addressData');
    // print('Nome: ${widget.fullName}'); // Exemplo
    
    // TODO: Armazenar os dados temporariamente ou passar para as próximas telas
    // TODO: Fazer a chamada de API no final do fluxo de cadastro
    
    // Navegar para a página de raio de atuação do freelancer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FreelancerRadiusPage(
          // Passar dados se necessário:
          // fullName: widget.fullName,
          // addressData: addressData,
        ),
      ),
    );
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
                  'Cadastro de endereço', // Título
                  style: AppTypography.heading1.copyWith(
                    color: AppColorsNeutral.neutral900,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing8),
                Text(
                  'Para uma melhor experiência, precisamos do endereço. Você poderá cadastrar novos mais tarde.', // Subtítulo
                  style: AppTypography.contentRegular.copyWith(
                    color: AppColorsNeutral.neutral600,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing32),

                // Campo CEP
                AppTextField(
                  label: 'CEP',
                  hintText: '00000-000',
                  controller: _cepController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_cepMaskFormatter], // Aplica máscara
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Informe o CEP';
                    if (!_cepMaskFormatter.isFill()) return 'CEP incompleto';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.spacing16),

                // Campo Bairro
                AppTextField(
                  label: 'Bairro',
                  hintText: 'Informe o bairro',
                  controller: _bairroController,
                   validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Informe o bairro';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.spacing16),

                // Campo Rua
                AppTextField(
                  label: 'Rua, avenida, vila...',
                  hintText: 'Informe a rua',
                  controller: _ruaController,
                   validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Informe a rua';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.spacing16),

                // Linha para Número e Complemento
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // Alinha labels no topo
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Número',
                        hintText: '000',
                        controller: _numeroController,
                        keyboardType: TextInputType.number,
                         validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Informe o número';
                          return null;
                         },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spacing16),
                    Expanded(
                      child: AppTextField(
                        label: 'Complemento',
                        hintText: '000',
                        controller: _complementoController,
                        // Complemento geralmente não é obrigatório
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spacing16),

                // Campo Cidade
                AppTextField(
                  label: 'Cidade',
                  hintText: 'Cidade, Estado',
                  controller: _cidadeController,
                  // Poderia ser um Dropdown ou Autocomplete no futuro
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Informe a cidade';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.spacing32),

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