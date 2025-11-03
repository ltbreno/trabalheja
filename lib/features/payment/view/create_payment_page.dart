import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';
import 'package:trabalheja/features/payment/service/payment_service.dart';
import 'package:trabalheja/features/payment/view/card_form_page.dart';
import 'package:trabalheja/core/constants/pagarme_config.dart';

class CreatePaymentPage extends StatefulWidget {
  final int? preDefinedAmount;
  final String? preDefinedRecipientId;
  final String? pagarmeEncryptionKey; // Opcional: usa config padrão se não fornecido

  const CreatePaymentPage({
    super.key,
    this.preDefinedAmount,
    this.preDefinedRecipientId,
    this.pagarmeEncryptionKey,
  });

  @override
  State<CreatePaymentPage> createState() => _CreatePaymentPageState();
}

class _CreatePaymentPageState extends State<CreatePaymentPage> {
  final _amountController = TextEditingController();
  final _cardHashController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _paymentService = PaymentService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pré-preencher valores se fornecidos
    if (widget.preDefinedAmount != null) {
      // Converter centavos para reais para exibição
      final amountInReais = widget.preDefinedAmount! / 100;
      _amountController.text = amountInReais.toStringAsFixed(2);
    }
    // Não precisa mais de recipient_id - plataforma recebe 100% inicialmente
  }

  @override
  void dispose() {
    _amountController.dispose();
    _cardHashController.dispose();
    super.dispose();
  }

  Future<void> _openCardForm() async {
    // Navegar para formulário de cartão
    // Usa encryption key fornecida ou a padrão da configuração
    final encryptionKey = widget.pagarmeEncryptionKey ?? PagarmeConfig.encryptionKey;
    
    final cardHash = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => CardFormPage(
          encryptionKey: encryptionKey,
        ),
      ),
    );

    if (cardHash != null && mounted) {
      setState(() {
        _cardHashController.text = cardHash;
      });
    }
  }

  Future<void> _createPayment() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Converter valor de reais para centavos
      final amountInReais = double.parse(_amountController.text.replaceAll(',', '.'));
      final amountInCents = (amountInReais * 100).toInt();

      var cardHash = _cardHashController.text.trim();
      if (cardHash.isEmpty) {
        throw Exception('Por favor, adicione os dados do cartão primeiro');
      }

      print('📡 Tentando processar pagamento com card_hash existente...');

      // Tentar processar com o hash existente
      Map<String, dynamic> result;
      try {
        result = await _paymentService.createPayment(
          amount: amountInCents,
          cardHash: cardHash,
        );
      } catch (e) {
        // Se der erro de chave inválida, pode ser que o hash expirou
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('chave') && 
            (errorStr.contains('inválido') || errorStr.contains('invalido') || errorStr.contains('expirado'))) {
          print('⚠️ Card hash pode ter expirado. Por favor, gere um novo hash imediatamente antes de processar.');
          print('   O card_hash precisa ser gerado momentos antes do pagamento.');
          
          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'O hash do cartão expirou. Por favor, adicione os dados do cartão novamente e processe imediatamente.',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Regenerar',
                textColor: Colors.white,
                onPressed: () async {
                  // Limpar hash antigo e abrir formulário novamente
                  setState(() {
                    _cardHashController.clear();
                  });
                  await _openCardForm();
                  // Após gerar novo hash, processar automaticamente
                  if (_cardHashController.text.isNotEmpty) {
                    await _createPayment();
                  }
                },
              ),
            ),
          );
          return;
        }
        // Se for outro erro, relançar
        rethrow;
      }

      if (!mounted) return;

      // Exibir resultado
      print('✅ Pagamento criado com sucesso: $result');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pagamento processado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Você pode navegar para uma página de sucesso ou voltar
      Navigator.pop(context, result);
    } on FunctionException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao processar pagamento: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar pagamento: ${e.toString()}'),
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
          'Criar Pagamento',
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
                  'Processar Pagamento',
                  style: AppTypography.heading3.copyWith(
                    color: AppColorsNeutral.neutral900,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing8),
                Text(
                  'Preencha os dados para processar o pagamento.',
                  style: AppTypography.contentRegular.copyWith(
                    color: AppColorsNeutral.neutral600,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing32),

                // Campo de Valor
                AppTextField(
                  label: 'Valor (R\$)',
                  hintText: '100.00',
                  controller: _amountController,
                  prefixIconPath: 'assets/icons/money.svg',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, informe o valor';
                    }
                    final amount = double.tryParse(value.replaceAll(',', '.'));
                    if (amount == null || amount <= 0) {
                      return 'Valor inválido';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.spacing24),

                // Campo de Card Hash (com botão para coletar dados do cartão)
                GestureDetector(
                  onTap: _openCardForm,
                  child: AppTextField(
                    label: 'Dados do Cartão',
                    hintText: _cardHashController.text.isEmpty
                        ? 'Clique para adicionar dados do cartão'
                        : 'Cartão processado ✓',
                    controller: _cardHashController,
                    prefixIconPath: 'assets/icons/credit_card.svg',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, adicione os dados do cartão';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.spacing8),
                TextButton.icon(
                  onPressed: _openCardForm,
                  icon: Icon(Icons.add_card, color: AppColorsPrimary.primary800),
                  label: Text(
                    'Adicionar dados do cartão',
                    style: AppTypography.contentMedium.copyWith(
                      color: AppColorsPrimary.primary800,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColorsPrimary.primary800,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.spacing24),

                // Info sobre retenção
                Container(
                  padding: const EdgeInsets.all(AppSpacing.spacing16),
                  decoration: BoxDecoration(
                    color: AppColorsPrimary.primary50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColorsPrimary.primary700,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.spacing8),
                      Expanded(
                        child: Text(
                          'O pagamento será retido na plataforma e liberado ao freelancer após conclusão do serviço.',
                          style: AppTypography.contentRegular.copyWith(
                            color: AppColorsPrimary.primary700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.spacing32),

                // Botão Processar Pagamento
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : AppButton.primary(
                        text: 'Processar Pagamento',
                        onPressed: _createPayment,
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

