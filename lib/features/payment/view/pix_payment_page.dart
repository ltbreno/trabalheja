import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/payment/view/payment_success_page.dart';
import 'package:trabalheja/features/payment/view/payment_failure_page.dart';

/// Tela de pagamento PIX com QR Code e verificação automática
class PixPaymentPage extends StatefulWidget {
  final String orderId;
  final String qrCode;
  final String? qrCodeUrl;
  final double amount;
  final String serviceRequestId;
  final String? proposalId;
  final Map<String, dynamic> clientProfile;
  final Map<String, dynamic>? freelancerProfile;
  final double serviceAmount;
  final double platformFee;
  final String customerDocument;

  const PixPaymentPage({
    super.key,
    required this.orderId,
    required this.qrCode,
    this.qrCodeUrl,
    required this.amount,
    required this.serviceRequestId,
    this.proposalId,
    required this.clientProfile,
    this.freelancerProfile,
    required this.serviceAmount,
    required this.platformFee,
    required this.customerDocument,
  });

  @override
  State<PixPaymentPage> createState() => _PixPaymentPageState();
}

class _PixPaymentPageState extends State<PixPaymentPage> with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  
  StreamSubscription? _paymentSubscription;
  int _remainingSeconds = 900; // 15 minutos = 900 segundos
  bool _qrCodeCopied = false;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animação de pulso para o QR Code
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Escutar mudanças via Realtime (instantâneo)
    _listenToPaymentChanges();
    
    // Iniciar contagem regressiva
    _startCountdown();
  }

  @override
  void dispose() {
    _paymentSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  /// Escuta mudanças no pagamento via Supabase Realtime
  /// Detecta pagamento instantaneamente quando webhook atualiza o banco
  void _listenToPaymentChanges() {
    print('👂 Escutando mudanças na tabela payments_pagarme via Realtime...');
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
          
          print('🔔 Realtime: Status recebido da tabela payments_pagarme: $status');
          
          if (status == 'paid') {
            // ✅ Pagamento confirmado!
            print('✅ Pagamento PIX confirmado via Realtime (webhook)!');
            _paymentSubscription?.cancel();
            _handlePaymentSuccess(payment);
          } else if (status == 'failed' || status == 'canceled') {
            // ❌ Pagamento falhou
            print('❌ Pagamento PIX falhou via Realtime (webhook)!');
            _paymentSubscription?.cancel();
            _handlePaymentFailure();
          } else {
            print('📊 Status atual na payments_pagarme: $status (aguardando pagamento)');
          }
        } else {
          print('⏳ Aguardando webhook criar registro na payments_pagarme...');
        }
      }, onError: (error) {
        print('❌ Erro no Realtime (payments_pagarme): $error');
        print('⚠️ Verifique se Realtime está habilitado na tabela payments_pagarme');
      });
      
      print('✅ Realtime iniciado com sucesso na tabela payments_pagarme!');
      print('💡 Escutando webhook do Pagar.me via Supabase Realtime');
      print('📊 Nenhuma requisição HTTP será feita - 100% Realtime');
      
    } catch (e) {
      print('❌ Erro ao iniciar Realtime: $e');
      print('⚠️ Certifique-se que:');
      print('   1. Tabela payments_pagarme existe no Supabase');
      print('   2. Realtime está habilitado: ALTER PUBLICATION supabase_realtime ADD TABLE payments_pagarme');
      print('   3. RLS permite SELECT na tabela');
    }
  }

  void _startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          timer.cancel();
          _paymentSubscription?.cancel();
          _handleTimeout();
        }
      });
    });
  }

  Future<void> _handlePaymentSuccess(Map<String, dynamic>? paymentData) async {
    print('💾 Salvando pagamento PIX no Supabase...');
    
    try {
      final paymentId = paymentData?['payment_id']?.toString();
      
      await _supabase.from('payments').insert({
        'service_request_id': widget.serviceRequestId,
        'proposal_id': widget.proposalId,
        'client_id': _supabase.auth.currentUser!.id,
        'freelancer_id': widget.freelancerProfile?['id'],
        'amount': widget.serviceAmount,
        'platform_fee': widget.platformFee,
        'total_amount': widget.amount,
        'installments': 1,
        'pagarme_order_id': widget.orderId,
        'pagarme_payment_id': paymentId,
        'status': 'paid',
        'customer_name': widget.clientProfile['full_name'],
        'customer_email': widget.clientProfile['email'],
        'customer_document': widget.customerDocument,
        'retained_at': DateTime.now().toIso8601String(),
        'release_status': 'retained',
      });
      
      print('✅ Pagamento PIX salvo no Supabase com sucesso!');
    } catch (e) {
      print('⚠️ Erro ao salvar pagamento no Supabase: $e');
    }
    
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PaymentSuccessPage(
          amount: widget.amount,
          orderId: widget.orderId,
          paymentId: paymentData?['payment_id']?.toString(),
        ),
      ),
    );
  }

  Future<void> _handlePaymentFailure() async {
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const PaymentFailurePage(
          errorMessage: 'Pagamento PIX não foi concluído',
        ),
      ),
    );
  }

  void _handleTimeout() {
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const PaymentFailurePage(
          errorMessage: 'QR Code expirado. Por favor, tente novamente.',
        ),
      ),
    );
  }

  void _copyQrCode() {
    Clipboard.setData(ClipboardData(text: widget.qrCode));
    setState(() => _qrCodeCopied = true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Código PIX copiado!'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Reset após 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _qrCodeCopied = false);
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isExpiringSoon = _remainingSeconds < 120; // Menos de 2 minutos
    
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cancelar pagamento?'),
            content: const Text(
              'Se você sair agora, o pagamento não será concluído. '
              'Tem certeza que deseja cancelar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Continuar pagando'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        backgroundColor: AppColorsNeutral.neutral0,
        appBar: AppBar(
          backgroundColor: AppColorsNeutral.neutral0,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: AppColorsNeutral.neutral900),
            onPressed: () async {
              final shouldPop = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cancelar pagamento?'),
                  content: const Text(
                    'Se você sair agora, o pagamento não será concluído. '
                    'Tem certeza que deseja cancelar?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Continuar pagando'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              );
              if (shouldPop == true && mounted) {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            'Pagamento PIX',
            style: AppTypography.contentMedium.copyWith(
              color: AppColorsNeutral.neutral900,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.spacing24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Timer
                _buildTimer(isExpiringSoon),
                
                const SizedBox(height: AppSpacing.spacing24),
                
                // Valor
                _buildAmountCard(),
                
                const SizedBox(height: AppSpacing.spacing32),
                
                // QR Code
                _buildQrCodeSection(),
                
                const SizedBox(height: AppSpacing.spacing24),
                
                // Código Copia e Cola
                _buildCopyPasteSection(),
                
                const SizedBox(height: AppSpacing.spacing32),
                
                // Instruções
                _buildInstructions(),
                
                const SizedBox(height: AppSpacing.spacing24),
                
                // Status: aguardando pagamento via Realtime
                _buildRealtimeStatus(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimer(bool isExpiringSoon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      decoration: BoxDecoration(
        color: isExpiringSoon ? Colors.red.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpiringSoon ? Colors.red.shade200 : Colors.blue.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_outlined,
            color: isExpiringSoon ? Colors.red.shade700 : Colors.blue.shade700,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'Expira em: ${_formatTime(_remainingSeconds)}',
            style: AppTypography.contentBold.copyWith(
              color: isExpiringSoon ? Colors.red.shade900 : Colors.blue.shade900,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColorsPrimary.primary700, AppColorsPrimary.primary900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColorsPrimary.primary700.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Valor a pagar',
            style: AppTypography.contentMedium.copyWith(
              color: AppColorsNeutral.neutral0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'R\$ ${widget.amount.toStringAsFixed(2)}',
            style: AppTypography.heading2.copyWith(
              color: AppColorsNeutral.neutral0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCodeSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing24),
      decoration: BoxDecoration(
        color: AppColorsNeutral.neutral0,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColorsNeutral.neutral200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Escaneie o QR Code',
            style: AppTypography.contentBold.copyWith(
              color: AppColorsNeutral.neutral900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: AppSpacing.spacing16),
          
          // QR Code com animação
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColorsNeutral.neutral0,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: widget.qrCode,
                version: QrVersions.auto,
                size: 250,
                backgroundColor: AppColorsNeutral.neutral0,
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.spacing16),
          
          Text(
            'Abra o app do seu banco e escaneie o código',
            style: AppTypography.captionRegular.copyWith(
              color: AppColorsNeutral.neutral600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCopyPasteSection() {
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
              Icon(Icons.content_copy, color: AppColorsPrimary.primary800, size: 20),
              const SizedBox(width: 8),
              Text(
                'Código PIX Copia e Cola',
                style: AppTypography.contentBold.copyWith(
                  color: AppColorsNeutral.neutral900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing12),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColorsNeutral.neutral0,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColorsNeutral.neutral300),
            ),
            child: Text(
              widget.qrCode,
              style: AppTypography.captionRegular.copyWith(
                color: AppColorsNeutral.neutral700,
                fontFamily: 'monospace',
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          const SizedBox(height: AppSpacing.spacing12),
          
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _copyQrCode,
              icon: Icon(_qrCodeCopied ? Icons.check : Icons.copy, size: 20),
              label: Text(
                _qrCodeCopied ? 'Copiado!' : 'Copiar código',
                style: AppTypography.contentBold.copyWith(
                  color: AppColorsNeutral.neutral0,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _qrCodeCopied ? Colors.green : AppColorsPrimary.primary700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Como pagar',
                style: AppTypography.contentBold.copyWith(
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing12),
          
          _buildInstructionStep('1', 'Abra o app do seu banco'),
          const SizedBox(height: 8),
          _buildInstructionStep('2', 'Escolha pagar com PIX'),
          const SizedBox(height: 8),
          _buildInstructionStep('3', 'Escaneie o QR Code ou cole o código'),
          const SizedBox(height: 8),
          _buildInstructionStep('4', 'Confirme o pagamento'),
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
                Icon(Icons.check_circle_outline, color: Colors.green.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Aguarde, estamos verificando seu pagamento automaticamente',
                    style: AppTypography.captionRegular.copyWith(
                      color: Colors.green.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: AppTypography.captionBold.copyWith(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTypography.captionRegular.copyWith(
              color: Colors.blue.shade900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRealtimeStatus() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wifi,
            size: 20,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Aguardando confirmação do pagamento via Realtime...',
              style: AppTypography.captionMedium.copyWith(
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

