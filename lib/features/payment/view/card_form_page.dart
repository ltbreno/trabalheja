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
    // Usa encryption key e secret key da configuração
    final encryptionKey = widget.encryptionKey ?? PagarmeConfig.encryptionKey;
    final secretKey = PagarmeConfig.secretKey;
    _pagarmeService = PagarmeService(
      encryptionKey: encryptionKey,
      secretKey: secretKey,
    );

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

  Future<void> _submitCard() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Remover formatação dos dados
      final cardNumber = _cardNumberController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final cardHolderName = _cardHolderNameController.text.trim();

      // Converter data de MM/YY para MM e YY separados
      final expirationParts = _cardExpirationController.text.split('/');
      String expMonth;
      String expYear;
      
      if (expirationParts.length == 2) {
        expMonth = expirationParts[0];
        expYear = expirationParts[1];
      } else {
        // Fallback básico
        final raw = _cardExpirationController.text.replaceAll(RegExp(r'[^0-9]'), '');
        if (raw.length >= 4) {
          expMonth = raw.substring(0, 2);
          expYear = raw.substring(2, 4);
        } else {
          throw Exception('Data de validade inválida');
        }
      }

      final cardCvv = _cardCvvController.text.replaceAll(RegExp(r'[^0-9]'), '');
      // Converter ano para 4 dígitos (int)
      // Mês deve ser string com 2 dígitos (ex: "01")
      int expYearInt = int.parse(expYear);
      String expMonthStr = expMonth.padLeft(2, '0');
      
      // Se ano for 2 dígitos (ex: 30), converter para 2030
      if (expYearInt < 100) {
        expYearInt += 2000;
      }

      final cardData = {
        'number': cardNumber,
        'holder_name': cardHolderName,
        'exp_month': expMonthStr,
        'exp_year': expYearInt,
        'cvv': cardCvv,
        // removendo campos extras que podem atrapalhar se o backend for estrito
        // 'brand': _cardBrand ?? 'Unknown', 
        // 'label': _cardBrand ?? 'Credits',
      };

      if (!mounted) return;

      Navigator.pop(context, cardData);

    } catch (e) {
      if (!mounted) return;
      print('❌ Erro ao processar cartão: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao processar dados do cartão: ${e.toString()}'),
          backgroundColor: Colors.red,
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
                        text: 'Confirmar Cartão',
                        onPressed: _submitCard,
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

