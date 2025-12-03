import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/payment/service/payment_service.dart';

/// Página para liberar pagamento para o freelancer
/// 
/// Usado após o serviço ser finalizado
class ReleasePaymentPage extends StatefulWidget {
  final String proposalId;
  final Map<String, dynamic> paymentData;
  final Map<String, dynamic> freelancerProfile;

  const ReleasePaymentPage({
    super.key,
    required this.proposalId,
    required this.paymentData,
    required this.freelancerProfile,
  });

  @override
  State<ReleasePaymentPage> createState() => _ReleasePaymentPageState();
}

class _ReleasePaymentPageState extends State<ReleasePaymentPage> {
  final _supabase = Supabase.instance.client;
  final _paymentService = PaymentService();
  
  bool _isReleasing = false;
  String? _recipientId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipientId();
  }

  Future<void> _loadRecipientId() async {
    try {
      // Buscar recipient_id do freelancer
      final freelancerId = widget.freelancerProfile['id'] as String;
      
      final entity = await _supabase
          .from('pagarme_entities')
          .select('pagarme_id')
          .eq('user_id', freelancerId)
          .eq('entity_type', 'recipient')
          .maybeSingle();

      if (entity != null) {
        setState(() {
          _recipientId = entity['pagarme_id'] as String;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Freelancer ainda não cadastrou dados bancários'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
      
    } catch (e) {
      print('❌ Erro ao carregar recipient ID: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _releasePayment() async {
    if (_recipientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Freelancer precisa cadastrar dados bancários primeiro'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Confirmar ação
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Liberar Pagamento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Você confirma que o serviço foi finalizado?'),
            const SizedBox(height: 16),
            Text(
              'Valor a ser liberado: R\$ ${(widget.paymentData['amount'] as int) / 100}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Taxa da plataforma: R\$ ${(widget.paymentData['platform_fee'] as int) / 100}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isReleasing = true);

    try {
      print('💸 Liberando pagamento...');
      print('   Recipient ID: $_recipientId');
      print('   Valor: ${widget.paymentData['amount']}');
      print('   Order ID: ${widget.paymentData['pagarme_order_id']}');

      // Calcular valor a ser transferido (serviço - taxa da plataforma)
      final serviceAmount = widget.paymentData['amount'] as int;
      final platformFee = widget.paymentData['platform_fee'] as int;
      final transferAmount = serviceAmount - platformFee;

      // Criar transferência para o freelancer
      await _paymentService.createTransfer(
        recipientId: _recipientId!,
        amount: transferAmount,
        orderId: widget.paymentData['pagarme_order_id'] as String,
      );

      // Atualizar status do pagamento no Supabase
      await _supabase
          .from('payments')
          .update({
            'release_status': 'released',
            'released_at': DateTime.now().toIso8601String(),
          })
          .eq('proposal_id', widget.proposalId);

      print('✅ Pagamento liberado com sucesso!');

      if (!mounted) return;

      // Mostrar mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Pagamento liberado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Voltar para a tela anterior
      Navigator.of(context).pop(true);
      
    } catch (e) {
      print('❌ Erro ao liberar pagamento: $e');
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao liberar pagamento: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isReleasing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceAmount = widget.paymentData['amount'] as int;
    final platformFee = widget.paymentData['platform_fee'] as int;
    final transferAmount = serviceAmount - platformFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liberar Pagamento'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card do freelancer
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Freelancer',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: widget.freelancerProfile['profile_picture_url'] != null
                                    ? NetworkImage(widget.freelancerProfile['profile_picture_url'] as String)
                                    : null,
                                child: widget.freelancerProfile['profile_picture_url'] == null
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.freelancerProfile['full_name'] as String? ?? 'Freelancer',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      widget.freelancerProfile['email'] as String? ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Resumo do pagamento
                  const Text(
                    'Resumo do Pagamento',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildPaymentInfoRow(
                    'Valor do Serviço',
                    'R\$ ${serviceAmount / 100}',
                    isLarge: false,
                  ),
                  const Divider(height: 24),
                  
                  _buildPaymentInfoRow(
                    'Taxa da Plataforma (${((platformFee / serviceAmount) * 100).toStringAsFixed(1)}%)',
                    '- R\$ ${platformFee / 100}',
                    color: Colors.red,
                    isLarge: false,
                  ),
                  const Divider(height: 24),
                  
                  _buildPaymentInfoRow(
                    'Valor a Liberar',
                    'R\$ ${transferAmount / 100}',
                    color: Colors.green,
                    isLarge: true,
                  ),
                  const SizedBox(height: 24),

                  // Status
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _recipientId != null ? Colors.green.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _recipientId != null ? Icons.check_circle : Icons.warning,
                          color: _recipientId != null ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _recipientId != null
                                ? 'Dados bancários cadastrados ✓'
                                : 'Aguardando cadastro de dados bancários',
                            style: TextStyle(
                              color: _recipientId != null ? Colors.green.shade900 : Colors.orange.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            const Text(
                              'Informações',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• O pagamento será transferido para a conta bancária do freelancer\n'
                          '• A transferência pode levar até 2 dias úteis\n'
                          '• Esta ação não pode ser desfeita',
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botão de liberar
                  AppButton(
                    text: _isReleasing ? 'Liberando...' : 'Liberar Pagamento',
                    onPressed: (_isReleasing || _recipientId == null) ? null : _releasePayment,
                    isLoading: _isReleasing,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildPaymentInfoRow(String label, String value, {Color? color, required bool isLarge}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 16 : 14,
            fontWeight: isLarge ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

