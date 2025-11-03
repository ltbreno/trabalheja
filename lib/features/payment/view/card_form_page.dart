import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';
import 'package:trabalheja/features/payment/service/pagarme_service.dart';
import 'package:trabalheja/core/constants/pagarme_config.dart';

class CardFormPage extends StatefulWidget {
  final String? encryptionKey; // Opcional: usa config padrão se não fornecido
  final Function(String cardHash)? onCardHashGenerated;

  const CardFormPage({
    super.key,
    this.encryptionKey,
    this.onCardHashGenerated,
  });

  @override
  State<CardFormPage> createState() => _CardFormPageState();
}

class _CardFormPageState extends State<CardFormPage> {
  final _cardNumberController = TextEditingController();
  final _cardHolderNameController = TextEditingController();
  final _cardExpirationController = TextEditingController();
  final _cardCvvController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  late PagarmeService _pagarmeService;
  bool _isLoading = false;
  String? _cardBrand;

  // Máscaras para formatação
  final _cardNumberFormatter = MaskTextInputFormatter(
    mask: '#### #### #### ####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _expirationFormatter = MaskTextInputFormatter(
    mask: '##/##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _cvvFormatter = MaskTextInputFormatter(
    mask: '###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    // Usa encryption key fornecida ou a padrão da configuração
    final encryptionKey = widget.encryptionKey ?? PagarmeConfig.encryptionKey;
    _pagarmeService = PagarmeService(encryptionKey: encryptionKey);
    
    // Detectar bandeira do cartão enquanto digita
    _cardNumberController.addListener(_detectCardBrand);
  }

  @override
  void dispose() {
    _cardNumberController.removeListener(_detectCardBrand);
    _cardNumberController.dispose();
    _cardHolderNameController.dispose();
    _cardExpirationController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  void _detectCardBrand() {
    final brand = PagarmeService.getCardBrand(_cardNumberController.text);
    setState(() {
      _cardBrand = brand;
    });
  }

  Future<void> _generateCardHash() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Remover formatação dos dados
      final cardNumber = _cardNumberController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final cardHolderName = _cardHolderNameController.text.trim();
      
      // Converter data de MM/YY para MMYY
      final expirationParts = _cardExpirationController.text.split('/');
      final cardExpirationDate = expirationParts.length == 2
          ? '${expirationParts[0]}${expirationParts[1]}'
          : _cardExpirationController.text.replaceAll(RegExp(r'[^0-9]'), '');
      
      final cardCvv = _cardCvvController.text.replaceAll(RegExp(r'[^0-9]'), '');

      // Gerar card_hash
      final cardHash = await _pagarmeService.generateCardHash(
        cardNumber: cardNumber,
        cardHolderName: cardHolderName,
        cardExpirationDate: cardExpirationDate,
        cardCvv: cardCvv,
      );

      if (!mounted) return;

      // Callback ou retornar resultado
      if (widget.onCardHashGenerated != null) {
        widget.onCardHashGenerated!(cardHash);
      }

      Navigator.pop(context, cardHash);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cartão processado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Log detalhado do erro para debug
      print('❌ ERRO ao gerar card_hash:');
      print('   Tipo: ${e.runtimeType}');
      print('   Mensagem: ${e.toString()}');
      print('   StackTrace: ${StackTrace.current}');

      // Extrair mensagem de erro mais amigável
      String errorMessage = 'Erro ao processar cartão.';
      final errorStr = e.toString().toLowerCase();
      
      if (errorStr.contains('encryption_key') || errorStr.contains('encryption')) {
        errorMessage = 'Chave de criptografia inválida. Verifique as configurações do Pagar.me.';
      } else if (errorStr.contains('401') || errorStr.contains('unauthorized')) {
        errorMessage = 'Chave de API inválida ou expirada. Verifique as credenciais do Pagar.me.';
      } else if (errorStr.contains('400') || errorStr.contains('bad request')) {
        errorMessage = 'Dados do cartão inválidos. Verifique os dados informados.';
      } else if (errorStr.contains('404') || errorStr.contains('not found')) {
        errorMessage = 'Endpoint não encontrado. Verifique a configuração da API do Pagar.me.';
      } else if (errorStr.contains('card') && (errorStr.contains('invalid') || errorStr.contains('invalid'))) {
        errorMessage = 'Dados do cartão inválidos. Verifique número, validade e CVV.';
      } else {
        errorMessage = 'Erro ao processar cartão: ${e.toString()}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
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
          'Dados do Cartão',
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
                  'Informações do Cartão',
                  style: AppTypography.heading3.copyWith(
                    color: AppColorsNeutral.neutral900,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing8),
                Text(
                  'Digite os dados do cartão de crédito.',
                  style: AppTypography.contentRegular.copyWith(
                    color: AppColorsNeutral.neutral600,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing32),

                // Campo Número do Cartão
                AppTextField(
                  label: 'Número do Cartão',
                  hintText: '0000 0000 0000 0000',
                  controller: _cardNumberController,
                  prefixIconPath: 'assets/icons/credit_card.svg',
                  keyboardType: TextInputType.number,
                  inputFormatters: [_cardNumberFormatter],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, informe o número do cartão';
                    }
                    final cardNumber = value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (cardNumber.length < 13 || cardNumber.length > 19) {
                      return 'Número do cartão inválido';
                    }
                    if (!PagarmeService.isValidCardNumber(cardNumber)) {
                      return 'Número do cartão inválido';
                    }
                    return null;
                  },
                ),

                // Mostrar bandeira do cartão se detectada
                if (_cardBrand != null) ...[
                  const SizedBox(height: AppSpacing.spacing8),
                  Text(
                    'Bandeira: $_cardBrand',
                    style: AppTypography.captionMedium.copyWith(
                      color: AppColorsPrimary.primary700,
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.spacing24),

                // Campo Nome do Portador
                AppTextField(
                  label: 'Nome no Cartão',
                  hintText: 'Nome como está no cartão',
                  controller: _cardHolderNameController,
                  prefixIconPath: 'assets/icons/person.svg',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, informe o nome no cartão';
                    }
                    if (value.trim().split(' ').length < 2) {
                      return 'Informe nome e sobrenome';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.spacing24),

                // Linha para Data e CVV
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Validade',
                        hintText: 'MM/AA',
                        controller: _cardExpirationController,
                        prefixIconPath: 'assets/icons/calendar.svg',
                        keyboardType: TextInputType.number,
                        inputFormatters: [_expirationFormatter],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe a validade';
                          }
                          final parts = value.split('/');
                          if (parts.length != 2) {
                            return 'Formato inválido';
                          }
                          final month = int.tryParse(parts[0]);
                          final year = int.tryParse(parts[1]);
                          if (month == null || month < 1 || month > 12) {
                            return 'Mês inválido';
                          }
                          if (year == null || year < 0 || year > 99) {
                            return 'Ano inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spacing16),
                    Expanded(
                      child: AppTextField(
                        label: 'CVV',
                        hintText: '123',
                        controller: _cardCvvController,
                        prefixIconPath: 'assets/icons/lock.svg',
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        inputFormatters: [_cvvFormatter],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o CVV';
                          }
                          if (value.replaceAll(RegExp(r'[^0-9]'), '').length < 3) {
                            return 'CVV inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.spacing32),

                // Botão Processar Cartão
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : AppButton.primary(
                        text: 'Processar Cartão',
                        onPressed: _generateCardHash,
                        minWidth: double.infinity,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

