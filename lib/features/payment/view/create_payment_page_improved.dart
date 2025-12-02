import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';
import 'package:trabalheja/features/payment/service/payment_service.dart';
import 'package:trabalheja/features/payment/view/card_form_page.dart';
import 'package:trabalheja/features/payment/view/payment_success_page.dart';
import 'package:trabalheja/features/payment/view/payment_failure_page.dart';
import 'package:trabalheja/core/constants/pagarme_config.dart';

/// Página melhorada de pagamento com:
/// - Dados do cliente pré-preenchidos do Supabase
/// - Valor do serviço integrado automaticamente
/// - Seletor de parcelamento
/// - Resumo do pedido
/// - Loading com feedback visual
class CreatePaymentPageImproved extends StatefulWidget {
  final String serviceRequestId; // ID do service_request
  final String? proposalId; // ID da proposta aceita (opcional)

  const CreatePaymentPageImproved({
    super.key,
    required this.serviceRequestId,
    this.proposalId,
  });

  @override
  State<CreatePaymentPageImproved> createState() => _CreatePaymentPageImprovedState();
}

class _CreatePaymentPageImprovedState extends State<CreatePaymentPageImproved> {
  final _supabase = Supabase.instance.client;
  final _paymentService = PaymentService();
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _cardTokenController = TextEditingController();
  final _cpfController = TextEditingController();
  
  // Estado
  bool _isLoading = false;
  bool _isLoadingData = true;
  int _selectedInstallments = 1;
  
  // Dados do serviço
  Map<String, dynamic>? _serviceRequest;
  Map<String, dynamic>? _clientProfile;
  Map<String, dynamic>? _freelancerProfile;
  
  // Dados calculados
  double _serviceAmount = 0.0;
  double _platformFee = 0.0;
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadPaymentData();
  }

  @override
  void dispose() {
    _cardTokenController.dispose();
    _cpfController.dispose();
    super.dispose();
  }

  /// Carrega todos os dados necessários do Supabase
  Future<void> _loadPaymentData() async {
    setState(() => _isLoadingData = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      // 1. Carregar service_request
      final serviceRequest = await _supabase
          .from('service_requests')
          .select('*, client_id')
          .eq('id', widget.serviceRequestId)
          .single();

      // 2. Carregar proposta (se houver)
      Map<String, dynamic>? proposal;
      if (widget.proposalId != null) {
        proposal = await _supabase
            .from('proposals')
            .select('*, freelancer_id')
            .eq('id', widget.proposalId!)
            .single();
      }

      // 3. Carregar perfil do cliente
      final clientProfile = await _supabase
          .from('profiles')
          .select('full_name, email, phone')
          .eq('id', serviceRequest['client_id'])
          .single();

      // 4. Carregar perfil do freelancer (se houver proposta)
      Map<String, dynamic>? freelancerProfile;
      if (proposal != null) {
        freelancerProfile = await _supabase
            .from('profiles')
            .select('full_name, email')
            .eq('id', proposal['freelancer_id'])
            .single();
      }

      // 5. Calcular valores
      final serviceAmount = proposal != null
          ? (proposal['proposed_price'] as num).toDouble()
          : (serviceRequest['budget'] as num).toDouble();
      
      final platformFee = serviceAmount * 0.10; // 10% de taxa da plataforma
      final totalAmount = serviceAmount + platformFee;

      setState(() {
        _serviceRequest = serviceRequest;
        _clientProfile = clientProfile;
        _freelancerProfile = freelancerProfile;
        _serviceAmount = serviceAmount;
        _platformFee = platformFee;
        _totalAmount = totalAmount;
        _isLoadingData = false;
      });
    } catch (e) {
      print('❌ Erro ao carregar dados do pagamento: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _openCardForm() async {
    final cardToken = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => CardFormPage(
          encryptionKey: PagarmeConfig.encryptionKey,
        ),
      ),
    );

    if (cardToken != null && mounted) {
      setState(() {
        _cardTokenController.text = cardToken;
      });
    }
  }

  Future<void> _processPayment() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final cardToken = _cardTokenController.text.trim();
      if (cardToken.isEmpty) {
        throw Exception('Por favor, adicione os dados do cartão primeiro');
      }

      final cpf = _cpfController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
      if (cpf.isEmpty) {
        throw Exception('Por favor, informe o CPF');
      }

      if (cpf.length != 11) {
        throw Exception('CPF inválido. Deve conter 11 dígitos');
      }

      // Converter para centavos
      final amountInCents = (_totalAmount * 100).toInt();

      print('📡 Processando pagamento...');
      print('   Valor total: R\$ ${_totalAmount.toStringAsFixed(2)}');
      print('   Parcelas: ${_selectedInstallments}x');
      print('   CPF: ${cpf.substring(0, 3)}.***.***-${cpf.substring(9)}');

      final result = await _paymentService.createPayment(
        amount: amountInCents,
        cardToken: cardToken,
        customerName: _clientProfile!['full_name'] as String,
        customerEmail: _clientProfile!['email'] as String,
        customerDocument: cpf,
      );

      if (!mounted) return;

      // Extrair dados do resultado
      final paymentData = result['data'] as Map<String, dynamic>?;
      final paymentStatus = paymentData?['status'] as String?;
      final orderId = paymentData?['pagarme_order_id'] as String?;
      final paymentId = paymentData?['payment_id']?.toString();

      // Verificar status
      if (paymentStatus == 'paid') {
        // ✅ SUCESSO - Salvar pagamento no Supabase
        print('💾 Salvando pagamento no Supabase...');
        
        try {
          await _supabase.from('payments').insert({
            'service_request_id': widget.serviceRequestId,
            'proposal_id': widget.proposalId,
            'client_id': _supabase.auth.currentUser!.id,
            'freelancer_id': _freelancerProfile!['id'],
            'amount': _serviceAmount,
            'platform_fee': _platformFee,
            'total_amount': _totalAmount,
            'installments': _selectedInstallments,
            'pagarme_order_id': orderId,
            'pagarme_payment_id': paymentId,
            'status': 'paid',
            'customer_name': _clientProfile!['full_name'],
            'customer_email': _clientProfile!['email'],
            'customer_document': _cpfController.text.trim().replaceAll(RegExp(r'[^0-9]'), ''),
            'retained_at': DateTime.now().toIso8601String(),
            'release_status': 'retained',
          });
          
          print('✅ Pagamento salvo no Supabase com sucesso!');
        } catch (e) {
          print('⚠️ Erro ao salvar pagamento no Supabase: $e');
          // Continuar mesmo se falhar ao salvar (pagamento já foi processado)
        }
        
        if (!mounted) return;
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PaymentSuccessPage(
              amount: _totalAmount,
              orderId: orderId,
              paymentId: paymentId,
            ),
          ),
        );
      } else {
        // ❌ FALHA
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PaymentFailurePage(
              errorMessage: paymentStatus == 'failed'
                  ? 'Pagamento recusado. Verifique os dados do cartão.'
                  : 'Falha ao processar o pagamento',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      print('❌ Erro ao processar pagamento: $e');

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const PaymentFailurePage(),
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
    if (_isLoadingData) {
      return Scaffold(
        backgroundColor: AppColorsNeutral.neutral0,
        appBar: AppBar(
          backgroundColor: AppColorsNeutral.neutral0,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColorsNeutral.neutral900),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Pagamento',
            style: AppTypography.contentMedium.copyWith(
              color: AppColorsNeutral.neutral900,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColorsNeutral.neutral0,
      appBar: AppBar(
        backgroundColor: AppColorsNeutral.neutral0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColorsNeutral.neutral900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Confirmar Pagamento',
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
                // Resumo do Serviço
                _buildServiceSummary(),

                const SizedBox(height: AppSpacing.spacing24),

                // Resumo Financeiro
                _buildFinancialSummary(),

                const SizedBox(height: AppSpacing.spacing24),

                // Campo de CPF
                _buildCpfField(),

                const SizedBox(height: AppSpacing.spacing24),

                // Parcelamento
                _buildInstallmentSelector(),

                const SizedBox(height: AppSpacing.spacing24),

                // Método de Pagamento
                _buildPaymentMethod(),

                const SizedBox(height: AppSpacing.spacing32),

                // Botão de Pagamento
                _buildPaymentButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceSummary() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      decoration: BoxDecoration(
        color: AppColorsNeutral.neutral50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorsNeutral.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.work_outline, color: AppColorsPrimary.primary800, size: 20),
              const SizedBox(width: 8),
              Text(
                'Resumo do Serviço',
                style: AppTypography.contentBold.copyWith(
                  color: AppColorsNeutral.neutral900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing12),
          Divider(color: AppColorsNeutral.neutral200),
          const SizedBox(height: AppSpacing.spacing12),
          
          _buildInfoRow('Serviço:', _serviceRequest!['service_description']),
          const SizedBox(height: 8),
          
          if (_freelancerProfile != null) ...[
            _buildInfoRow('Freelancer:', _freelancerProfile!['full_name']),
            const SizedBox(height: 8),
          ],
          
          _buildInfoRow(
            'Prazo:',
            '${_serviceRequest!['deadline_hours']} horas',
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, color: Colors.green.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Resumo Financeiro',
                style: AppTypography.contentBold.copyWith(
                  color: AppColorsNeutral.neutral900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing12),
          Divider(color: Colors.green.shade200),
          const SizedBox(height: AppSpacing.spacing12),
          
          _buildAmountRow('Valor do serviço:', _serviceAmount, false),
          const SizedBox(height: 8),
          _buildAmountRow('Taxa da plataforma (10%):', _platformFee, false),
          const SizedBox(height: 12),
          Divider(color: Colors.green.shade200),
          const SizedBox(height: 12),
          _buildAmountRow('TOTAL:', _totalAmount, true),
        ],
      ),
    );
  }

  Widget _buildCpfField() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      decoration: BoxDecoration(
        color: AppColorsNeutral.neutral50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorsNeutral.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.badge_outlined, color: AppColorsPrimary.primary800, size: 20),
              const SizedBox(width: 8),
              Text(
                'Dados do Pagador',
                style: AppTypography.contentBold.copyWith(
                  color: AppColorsNeutral.neutral900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing16),
          
          AppTextField(
            label: 'CPF',
            hintText: '000.000.000-00',
            controller: _cpfController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
              _CpfInputFormatter(),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, informe o CPF';
              }
              final cpf = value.replaceAll(RegExp(r'[^0-9]'), '');
              if (cpf.length != 11) {
                return 'CPF deve conter 11 dígitos';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'O CPF é necessário para processar o pagamento',
            style: AppTypography.captionRegular.copyWith(
              color: AppColorsNeutral.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstallmentSelector() {
    // Calcular opções de parcelamento
    final installmentOptions = [1, 2, 3, 6, 12];
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      decoration: BoxDecoration(
        color: AppColorsNeutral.neutral50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorsNeutral.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.credit_card, color: AppColorsPrimary.primary800, size: 20),
              const SizedBox(width: 8),
              Text(
                'Parcelamento',
                style: AppTypography.contentBold.copyWith(
                  color: AppColorsNeutral.neutral900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing12),
          
          ...installmentOptions.map((installments) {
            final installmentAmount = _totalAmount / installments;
            final hasInterest = installments > 3;
            final interestRate = hasInterest ? 0.02 : 0.0;
            final finalAmount = installmentAmount * (1 + interestRate);
            
            return RadioListTile<int>(
              value: installments,
              groupValue: _selectedInstallments,
              onChanged: (value) {
                setState(() => _selectedInstallments = value!);
              },
              title: Text(
                '${installments}x de R\$ ${finalAmount.toStringAsFixed(2)}',
                style: AppTypography.contentMedium,
              ),
              subtitle: Text(
                hasInterest ? 'com juros de 2%' : 'sem juros',
                style: AppTypography.captionRegular.copyWith(
                  color: hasInterest ? Colors.orange : Colors.green,
                ),
              ),
              dense: true,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    final hasCard = _cardTokenController.text.isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      decoration: BoxDecoration(
        color: AppColorsNeutral.neutral50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorsNeutral.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment, color: AppColorsPrimary.primary800, size: 20),
              const SizedBox(width: 8),
              Text(
                'Método de Pagamento',
                style: AppTypography.contentBold.copyWith(
                  color: AppColorsNeutral.neutral900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing16),
          
          // Botão para adicionar/alterar cartão
          OutlinedButton.icon(
            onPressed: _openCardForm,
            icon: Icon(hasCard ? Icons.edit : Icons.add_card),
            label: Text(hasCard ? 'Alterar Cartão' : 'Adicionar Cartão'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: BorderSide(
                color: hasCard ? Colors.green : AppColorsPrimary.primary800,
              ),
              foregroundColor: hasCard ? Colors.green : AppColorsPrimary.primary800,
            ),
          ),
          
          if (hasCard) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cartão adicionado com sucesso',
                      style: AppTypography.captionMedium.copyWith(
                        color: Colors.green.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    final canPay = _cardTokenController.text.isNotEmpty;
    
    return AppButton(
      text: _isLoading
          ? 'Processando...'
          : 'Pagar R\$ ${_totalAmount.toStringAsFixed(2)}',
      onPressed: canPay && !_isLoading ? _processPayment : null,
      isLoading: _isLoading,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTypography.captionMedium.copyWith(
              color: AppColorsNeutral.neutral600,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: AppTypography.captionRegular.copyWith(
              color: AppColorsNeutral.neutral900,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow(String label, double amount, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTypography.contentBold.copyWith(
                  color: Colors.green.shade900,
                  fontSize: 16,
                )
              : AppTypography.captionMedium.copyWith(
                  color: AppColorsNeutral.neutral700,
                ),
        ),
        Text(
          'R\$ ${amount.toStringAsFixed(2)}',
          style: isTotal
              ? AppTypography.heading4.copyWith(
                  color: Colors.green.shade700,
                )
              : AppTypography.captionRegular.copyWith(
                  color: AppColorsNeutral.neutral900,
                ),
        ),
      ],
    );
  }
}

/// Formatador de CPF (000.000.000-00)
class _CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length && i < 11; i++) {
      if (i == 3 || i == 6) {
        buffer.write('.');
      } else if (i == 9) {
        buffer.write('-');
      }
      buffer.write(digitsOnly[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

