import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/payment/view/payment_success_page.dart';
import 'package:trabalheja/features/payment/view/payment_failure_page.dart';

/// Tela de processamento de pagamento com cartão de crédito
/// Escuta mudanças na tabela payments_pagarme via Realtime
class CreditCardProcessingPage extends StatefulWidget {
  final String orderId;
  final double amount;
  final String? paymentId;

  const CreditCardProcessingPage({
    super.key,
    required this.orderId,
    required this.amount,
    this.paymentId,
  });

  @override
  State<CreditCardProcessingPage> createState() => _CreditCardProcessingPageState();
}

class _CreditCardProcessingPageState extends State<CreditCardProcessingPage> with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  
  StreamSubscription? _paymentSubscription;
  late AnimationController _animationController;
  bool _isProcessing = true;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    // Escutar mudanças na tabela payments_pagarme
    _listenToPaymentChanges();
  }

  @override
  void dispose() {
    _paymentSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _listenToPaymentChanges() {
    print('👂 Escutando mudanças na tabela payments_pagarme (Cartão)...');
    print('   Order ID: ${widget.orderId}');
    
    try {
      _paymentSubscription = _supabase
          .from('payments_pagarme')
          .stream(primaryKey: ['id'])
          .eq('pagarme_order_id', widget.orderId)
          .listen((List<Map<String, dynamic>> data) {
        
        if (!mounted) return;
        
        if (data.isNotEmpty) {
          final payment = data.first;
          final status = payment['status'] as String?;
          
          print('🔔 Realtime (Cartão): Status recebido: $status');
          
          if (status == 'paid') {
            // ✅ Pagamento confirmado!
            print('✅ Pagamento com cartão confirmado via Realtime!');
            _paymentSubscription?.cancel();
            _handlePaymentSuccess();
          } else if (status == 'failed' || status == 'canceled' || status == 'refused') {
            // ❌ Pagamento falhou
            print('❌ Pagamento com cartão falhou via Realtime!');
            _paymentSubscription?.cancel();
            _handlePaymentFailure();
          } else {
            print('📊 Status atual: $status (processando)');
          }
        }
      }, onError: (error) {
        print('❌ Erro no Realtime: $error');
        // Após 10 segundos sem resposta, considerar falha
        Future.delayed(const Duration(seconds: 10), () {
          if (mounted && _isProcessing) {
            _handlePaymentFailure();
          }
        });
      });
      
      print('✅ Realtime iniciado para pagamento com cartão!');
      
    } catch (e) {
      print('❌ Erro ao iniciar Realtime: $e');
      // Timeout de segurança
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted && _isProcessing) {
          _handlePaymentFailure();
        }
      });
    }
  }

  void _handlePaymentSuccess() {
    setState(() => _isProcessing = false);
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PaymentSuccessPage(
          amount: widget.amount,
          orderId: widget.orderId,
          paymentId: widget.paymentId,
        ),
      ),
    );
  }

  void _handlePaymentFailure() {
    setState(() => _isProcessing = false);
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const PaymentFailurePage(
          errorMessage: 'Falha ao processar o pagamento com cartão',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsNeutral.neutral0,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spacing24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animação de loading
                RotationTransition(
                  turns: _animationController,
                  child: Icon(
                    Icons.credit_card,
                    size: 80,
                    color: AppColorsPrimary.primary700,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing32),
                
                // Título
                Text(
                  'Processando Pagamento',
                  style: AppTypography.heading2.copyWith(
                    color: AppColorsPrimary.primary900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.spacing16),
                
                // Descrição
                Text(
                  'Estamos processando seu pagamento com cartão de crédito...',
                  style: AppTypography.contentRegular.copyWith(
                    color: AppColorsNeutral.neutral600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.spacing8),
                
                Text(
                  'Por favor, aguarde.',
                  style: AppTypography.captionMedium.copyWith(
                    color: AppColorsNeutral.neutral500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.spacing32),
                
                // Indicador de progresso
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    backgroundColor: AppColorsNeutral.neutral200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColorsPrimary.primary700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

