import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/payment/service/payment_service.dart';
import 'package:trabalheja/features/payment/view/card_form_page.dart';

class SaveCardPage extends StatefulWidget {
  const SaveCardPage({super.key});

  @override
  State<SaveCardPage> createState() => _SaveCardPageState();
}

class _SaveCardPageState extends State<SaveCardPage> {
  bool _isLoading = false;
  bool _isFetchingCards = true;
  final _paymentService = PaymentService();
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _savedCards = [];
  
  // Estado para adicionar novo cartão
  String? _newCardToken;
  Map<String, dynamic>? _newCardRawData;
  String? _newCardMaskedNumber;

  @override
  void initState() {
    super.initState();
    _fetchSavedCards();
  }

  Future<void> _fetchSavedCards() async {
    if (!mounted) return;
    setState(() => _isFetchingCards = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final profile = await _supabase
          .from('profiles')
          .select('pagarme_customer_id')
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null && profile['pagarme_customer_id'] != null) {
        final customerId = profile['pagarme_customer_id'] as String;
        final cards = await _paymentService.listCards(customerPagarmeId: customerId);
        
        if (mounted) {
          setState(() {
            _savedCards = cards;
          });
        }
      }
    } catch (e) {
      print('❌ Erro ao buscar cartões: $e');
      // Não exibe erro na UI para não assustar, apenas loga e mostra lista vazia
    } finally {
      if (mounted) setState(() => _isFetchingCards = false);
    }
  }

  Future<void> _openCardForm() async {
    // Retorno agora é dynamic (String token ou Map raw data)
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CardFormPage(),
      ),
    );

    if (result != null && mounted) {
      if (result is Map) {
        setState(() {
          _newCardToken = null; // Reset token
          _newCardRawData = result as Map<String, dynamic>; // Store raw data
          // Extrair ultimos 4 digitos
          final number = _newCardRawData!['number'].toString();
          final last4 = number.length >= 4 ? number.substring(number.length - 4) : '****';
          _newCardMaskedNumber = "Cartão: **** **** **** $last4";
        });
      } else if (result is String) {
        setState(() {
          _newCardToken = result;
          _newCardRawData = null;
          _newCardMaskedNumber = "Token: ${result.substring(0, 5)}...";
        });
      }
      
      _saveCard(); // Salva automaticamente ao retornar sucesso do formulário
    }
  }

  Future<void> _saveCard() async {
    if (_newCardToken == null && _newCardRawData == null) return;

    setState(() => _isLoading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Usuário não logado');

      final profile = await _supabase
          .from('profiles')
          .select('pagarme_customer_id')
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null || profile['pagarme_customer_id'] == null) {
        throw Exception('Dados do cliente não encontrados. Complete seu perfil primeiro.');
      }

      final customerId = profile['pagarme_customer_id'] as String;

      print('📡 Salvando cartão para o cliente $customerId...');
      
      // Decidir o que enviar (token ou raw data)
      final cardData = _newCardRawData ?? _newCardToken!;
      
      await _paymentService.createCard(
        customerPagarmeId: customerId,
        cardData: cardData,
      );

      // Limpar estado de "novo cartão"
      setState(() {
        _newCardToken = null;
        _newCardRawData = null;
        _newCardMaskedNumber = null;
      });

      // Recarregar lista
      await _fetchSavedCards();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cartão salvo com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      print('❌ Erro ao salvar cartão: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar cartão: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Retorna o ícone da bandeira
  Widget _getBrandIcon(String? brand) {
    IconData icon = Icons.credit_card;
    Color color = AppColorsNeutral.neutral500;
    return Icon(icon, color: color, size: 32);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsNeutral.neutral0,
      appBar: AppBar(
        backgroundColor: AppColorsNeutral.neutral0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColorsNeutral.neutral900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Meus Cartões',
          style: AppTypography.contentMedium.copyWith(
            color: AppColorsNeutral.neutral900,
          ),
        ),
      ),
      body: SafeArea(
        child: _isFetchingCards && _savedCards.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                   Expanded(
                    child: RefreshIndicator(
                      onRefresh: _fetchSavedCards,
                      child: ListView(
                        padding: const EdgeInsets.all(AppSpacing.spacing24),
                        children: [
                           Text(
                            'Cartões Salvos',
                            style: AppTypography.heading3.copyWith(
                              color: AppColorsNeutral.neutral900,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spacing8),
                          Text(
                            'Seus cartões de crédito cadastrados.',
                            style: AppTypography.contentRegular.copyWith(
                              color: AppColorsNeutral.neutral600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spacing24),

                          // Lista de cartões salvos
                          if (_savedCards.isEmpty)
                             Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                child: Text(
                                  'Nenhum cartão cadastrado.',
                                  style: AppTypography.contentRegular.copyWith(
                                    color: AppColorsNeutral.neutral500,
                                  ),
                                ),
                              ),
                            )
                          else
                            ..._savedCards.map((card) {
                              final brand = card['brand'] ?? 'Cartão';
                              final last4 = card['last_four_digits'] ?? card['last_digits'] ?? '****';
                              final holderName = card['holder_name'] ?? '';
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.spacing16),
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.spacing16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColorsNeutral.neutral200),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColorsNeutral.neutral50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: _getBrandIcon(brand),
                                      ),
                                      const SizedBox(width: AppSpacing.spacing16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '**** **** **** $last4',
                                              style: AppTypography.contentMedium.copyWith(
                                                color: AppColorsNeutral.neutral900,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (holderName.isNotEmpty)
                                              Text(
                                                holderName.toUpperCase(),
                                                style: AppTypography.captionMedium.copyWith(
                                                  color: AppColorsNeutral.neutral500,
                                                ),
                                              ),
                                            Text(
                                              brand.toString().toUpperCase(),
                                              style: AppTypography.captionRegular.copyWith(
                                                color: AppColorsPrimary.primary700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),

                          const SizedBox(height: AppSpacing.spacing24),
                          
                          // Botão Adicionar Novo Cartão
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : AppButton.primary(
                                  text: 'Adicionar Novo Cartão',
                                  onPressed: _openCardForm,
                                  minWidth: double.infinity,
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
