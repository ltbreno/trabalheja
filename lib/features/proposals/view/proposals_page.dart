// lib/features/proposals/view/proposals_page.dart
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/core/utils/distance_calculator.dart' as distance_util;
import 'package:trabalheja/core/widgets/error_modal.dart';
import 'package:trabalheja/features/proposals/widgets/received_proposal_card.dart';
import 'package:trabalheja/features/proposals/widgets/accepted_proposal_card.dart';
import 'package:trabalheja/features/proposals/widgets/sent_proposal_card.dart' show SentProposalCard, ProposalStatus;
import 'package:trabalheja/features/proposals/widgets/paid_proposal_card.dart';
import 'package:trabalheja/features/payment/view/create_payment_page_improved.dart';
import 'package:trabalheja/features/payment/view/release_payment_page.dart';

class ProposalsPage extends StatefulWidget {
  const ProposalsPage({super.key});

  @override
  State<ProposalsPage> createState() => _ProposalsPageState();
}

class _ProposalsPageState extends State<ProposalsPage> {
  final _supabase = Supabase.instance.client;
  
  Map<String, dynamic>? _profileData;
  List<Map<String, dynamic>> _proposals = [];
  bool _isLoading = true;
  bool _isLoadingProposals = false;
  
  // Filtros para propostas
  // [Pendentes, Aceitas, Rejeitadas, Pagas]
  // Por padrão, mostrar todas (nenhum filtro selecionado)
  List<bool> _selectedFilters = [false, false, false, false];
  
  String? get _accountType => _profileData?['account_type'] as String?;
  bool get _isClient => _accountType == 'client';
  bool get _isFreelancer => _accountType == 'freelancer';

  @override
  void initState() {
    super.initState();
    _loadProfileAndProposals();
  }

  Future<void> _loadProfileAndProposals() async {
    await _loadProfile();
    await _loadProposals();
  }

  Future<void> _loadProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final profile = await _supabase
          .from('profiles')
          .select('account_type, service_latitude, service_longitude')
          .eq('id', user.id)
          .maybeSingle();

      setState(() {
        _profileData = profile;
      });
    } catch (e) {
      print('Erro ao carregar perfil: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadProposals() async {
    setState(() => _isLoadingProposals = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        setState(() {
          _proposals = [];
          _isLoading = false;
          _isLoadingProposals = false;
        });
        return;
      }

      List<Map<String, dynamic>> proposals = [];

      if (_isClient) {
        // Para clientes: buscar propostas recebidas (propostas enviadas para seus serviços)
        proposals = await _loadReceivedProposals(user.id);
        print('📋 [ProposalsPage] Propostas recebidas carregadas: ${proposals.length}');
        for (var p in proposals) {
          print('   - Proposta ID: ${p['id']}, Status: ${p['status']}, Service Request: ${p['service_request_id']}');
        }
      } else if (_isFreelancer) {
        // Para freelancers: buscar propostas enviadas (propostas que ele enviou)
        proposals = await _loadSentProposals(user.id);
        print('📋 [ProposalsPage] Propostas enviadas carregadas: ${proposals.length}');
      }

      setState(() {
        _proposals = proposals;
        _isLoading = false;
        _isLoadingProposals = false;
      });
    } catch (e) {
      print('Erro ao carregar propostas: $e');
      setState(() {
        _proposals = [];
        _isLoading = false;
        _isLoadingProposals = false;
      });
    }
  }

  /// Verifica se existe um pagamento aprovado para a proposta
  /// Agora usa a VIEW proposals_with_payment_status
  Future<Map<String, dynamic>?> _getPaymentData(String proposalId) async {
    try {
      final proposal = await _supabase
          .from('proposals_with_payment_status')
          .select('payment_status, payment_method')
          .eq('proposal_id', proposalId)
          .maybeSingle();
      
      if (proposal != null && proposal['payment_status'] == 'paid') {
        return {
          'status': 'paid',
          'payment_method': proposal['payment_method'],
        };
      }
      
      return null;
    } catch (e) {
      print('⚠️ Erro ao buscar dados do pagamento: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> _loadReceivedProposals(String clientId) async {
    // Buscar propostas onde o service_request pertence ao cliente
    // Primeiro, buscar os service_requests do cliente
    final serviceRequests = await _supabase
        .from('service_requests')
        .select('id')
        .eq('client_id', clientId);
    
    if (serviceRequests.isEmpty) {
      return [];
    }
    
    final serviceRequestIds = (serviceRequests as List)
        .map((sr) => sr['id'] as String)
        .toList();
    
    // Buscar todas as propostas (incluindo pagas)
    List<Map<String, dynamic>> allProposals = [];
    
    for (var serviceRequestId in serviceRequestIds) {
      final proposalsForService = await _supabase
          .from('proposals')
          .select('id')
          .eq('service_request_id', serviceRequestId);
      
      for (var proposal in proposalsForService) {
        final proposalId = proposal['id'] as String;
        
        // Verificar status na VIEW (SEM pagarme_order_id)
        final status = await _supabase
            .from('proposals_with_payment_status')
            .select('payment_status, payment_method')
            .eq('proposal_id', proposalId)
            .maybeSingle();
        
        final paymentStatus = status?['payment_status'] as String?;
        
        // Buscar dados completos da proposta
        final fullProposal = await _supabase
            .from('proposals')
            .select('''
              *,
              service_requests (
                id,
                service_description,
                service_latitude,
                service_longitude,
                budget,
                deadline_hours,
                client_id
              ),
              profiles!freelancer_id (
                id,
                full_name,
                profile_picture_url,
                service_latitude,
                service_longitude
              )
            ''')
            .eq('id', proposalId)
            .maybeSingle();
        
        if (fullProposal != null) {
          // Buscar dados completos do pagamento se a proposta está paga
          Map<String, dynamic>? paymentDetails;
          if (paymentStatus == 'paid') {
            paymentDetails = await _supabase
                .from('payments')
                .select('*')
                .eq('proposal_id', proposalId)
                .maybeSingle();
          }
          
          allProposals.add({
            ...fullProposal,
            'payment_status': paymentStatus,
            'payment_method': status?['payment_method'],
            if (paymentDetails != null) 'payment_details': paymentDetails,
          });
        }
      }
    }
    
    final statusMap = <String, Map<String, dynamic>>{};
    for (var proposal in allProposals) {
      statusMap[proposal['id'] as String] = {
        'payment_status': proposal['payment_status'],
        'payment_method': proposal['payment_method'],
      };
    }

    final List<Map<String, dynamic>> enrichedProposals = [];

    for (var proposal in allProposals) {
      final serviceRequest = proposal['service_requests'] as Map<String, dynamic>;
      final freelancer = proposal['profiles'] as Map<String, dynamic>?;
      
      // Calcular distância entre freelancer e serviço
      double? distance;
      if (freelancer != null) {
        final freelancerLat = freelancer['service_latitude'] as double?;
        final freelancerLng = freelancer['service_longitude'] as double?;
        final serviceLat = serviceRequest['service_latitude'] as double?;
        final serviceLng = serviceRequest['service_longitude'] as double?;
        
        if (freelancerLat != null && freelancerLng != null && 
            serviceLat != null && serviceLng != null) {
          distance = distance_util.AppDistanceCalculator.calculateDistanceInMeters(
            LatLng(freelancerLat, freelancerLng),
            LatLng(serviceLat, serviceLng),
          );
        }
      }

      enrichedProposals.add({
        ...proposal,
        'distance': distance,
      });
    }

    // Ordenar por data de criação (mais recentes primeiro)
    enrichedProposals.sort((a, b) {
      final aDate = a['created_at'] as String? ?? '';
      final bDate = b['created_at'] as String? ?? '';
      return bDate.compareTo(aDate);
    });

    return enrichedProposals;
  }

  Future<List<Map<String, dynamic>>> _loadSentProposals(String freelancerId) async {
    // Buscar todas as propostas (incluindo pagas)
    final allProposals = await _supabase
        .from('proposals')
        .select('id')
        .eq('freelancer_id', freelancerId);
    
    if (allProposals.isEmpty) {
      return [];
    }
    
    final validProposals = <Map<String, dynamic>>[];
    
    for (var proposal in allProposals) {
      final proposalId = proposal['id'] as String;
      
      // Verificar status na VIEW (SEM pagarme_order_id)
      final status = await _supabase
          .from('proposals_with_payment_status')
          .select('payment_status, payment_method')
          .eq('proposal_id', proposalId)
          .maybeSingle();
      
      final paymentStatus = status?['payment_status'] as String?;
      
      // Buscar dados completos
      final fullProposal = await _supabase
          .from('proposals')
          .select('''
            *,
            service_requests (
              id,
              service_description,
              service_latitude,
              service_longitude,
              budget,
              deadline_hours,
              client_id,
              profiles!client_id (
                id,
                full_name,
                profile_picture_url,
                service_latitude,
                service_longitude
              )
            )
          ''')
          .eq('id', proposalId)
          .maybeSingle();
      
      if (fullProposal != null) {
        // Buscar dados completos do pagamento se a proposta está paga
        Map<String, dynamic>? paymentDetails;
        if (paymentStatus == 'paid') {
          paymentDetails = await _supabase
              .from('payments')
              .select('*')
              .eq('proposal_id', proposalId)
              .maybeSingle();
        }
        
        validProposals.add({
          ...fullProposal,
          'payment_status': paymentStatus,
          'payment_method': status?['payment_method'],
          if (paymentDetails != null) 'payment_details': paymentDetails,
        });
      }
    }
    
    if (validProposals.isEmpty) {
      return [];
    }
    
    // Ordenar por data
    validProposals.sort((a, b) {
      final aDate = a['created_at'] as String? ?? '';
      final bDate = b['created_at'] as String? ?? '';
      return bDate.compareTo(aDate);
    });
    
    final proposals = validProposals;

    final List<Map<String, dynamic>> enrichedProposals = [];

    for (var proposal in proposals) {
      final serviceRequest = proposal['service_requests'] as Map<String, dynamic>?;
      
      // Calcular distância entre cliente e serviço
      double? distance;
      if (serviceRequest != null) {
        final client = serviceRequest['profiles'] as Map<String, dynamic>?;
        final clientLat = client?['service_latitude'] as double?;
        final clientLng = client?['service_longitude'] as double?;
        final serviceLat = serviceRequest['service_latitude'] as double?;
        final serviceLng = serviceRequest['service_longitude'] as double?;
        
        // Se cliente não tem coordenadas, usar coordenadas do serviço
        if (serviceLat != null && serviceLng != null) {
          if (clientLat != null && clientLng != null) {
            distance = distance_util.AppDistanceCalculator.calculateDistanceInMeters(
              LatLng(clientLat, clientLng),
              LatLng(serviceLat, serviceLng),
            );
          } else {
            // Se não há coordenadas do cliente, distância é 0 (serviço no mesmo local)
            distance = 0.0;
          }
        }
      }

      enrichedProposals.add({
        ...proposal,
        'distance': distance,
      });
    }

    return enrichedProposals;
  }

  /// Conta propostas por status para exibir nos filtros
  Map<String, int> _getProposalCounts() {
    int pending = 0;
    int accepted = 0;
    int rejected = 0;
    int paid = 0;
    
    for (var p in _proposals) {
      final status = p['status'] as String?;
      final paymentStatus = p['payment_status'] as String?;
      
      if (paymentStatus == 'paid') {
        paid++;
      } else if (status == 'pending') {
        pending++;
      } else if (status == 'accepted') {
        accepted++;
      } else if (status == 'rejected') {
        rejected++;
      }
    }
    
    return {
      'pending': pending,
      'accepted': accepted,
      'rejected': rejected,
      'paid': paid,
    };
  }

  List<Map<String, dynamic>> _getFilteredProposals() {
    // Filtros: [Pendentes, Aceitas, Rejeitadas, Pagas]
    final showPending = _selectedFilters[0];
    final showAccepted = _selectedFilters[1];
    final showRejected = _selectedFilters[2];
    final showPaid = _selectedFilters[3];
    
    // Se nenhum filtro estiver selecionado, mostrar todas
    if (!showPending && !showAccepted && !showRejected && !showPaid) {
      return _proposals;
    }
    
    // Filtrar propostas baseado nos filtros selecionados
    return _proposals.where((p) {
      final status = p['status'] as String?;
      final paymentStatus = p['payment_status'] as String?;
      
      // Proposta está paga
      if (paymentStatus == 'paid') {
        return showPaid;
      }
      
      // Proposta não está paga, verificar status da proposta
      if (status == 'pending' && showPending) return true;
      if (status == 'accepted' && showAccepted) return true;
      if (status == 'rejected' && showRejected) return true;
      
      return false;
    }).toList();
  }

  Future<void> _acceptProposal(String proposalId) async {
    try {
      await _supabase
          .from('proposals')
          .update({'status': 'accepted'})
          .eq('id', proposalId);

      // Rejeitar outras propostas do mesmo serviço
      final proposal = _proposals.firstWhere((p) => p['id'] == proposalId);
      final serviceRequestId = proposal['service_request_id'] as String;

      await _supabase
          .from('proposals')
          .update({'status': 'rejected'})
          .eq('service_request_id', serviceRequestId)
          .neq('id', proposalId);

      // Atualizar status do service_request para accepted
      await _supabase
          .from('service_requests')
          .update({'status': 'accepted'})
          .eq('id', serviceRequestId);

      // Criar conversa automaticamente entre cliente e freelancer
      await _createConversation(proposal);

      // Recarregar propostas
      await _loadProposals();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proposta aceita com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorModal.show(
          context,
          title: 'Erro ao aceitar proposta',
          message: 'Não foi possível aceitar a proposta. Tente novamente.',
        );
      }
    }
  }

  Future<void> _createConversation(Map<String, dynamic> proposal) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final freelancerId = proposal['freelancer_id'] as String;
      final proposalId = proposal['id'] as String;
      
      // Determinar participant1 e participant2 (menor ID primeiro)
      final participant1Id = user.id.compareTo(freelancerId) < 0 ? user.id : freelancerId;
      final participant2Id = user.id.compareTo(freelancerId) < 0 ? freelancerId : user.id;

      // Verificar se já existe conversa
      final existingConversation = await _supabase
          .from('conversations')
          .select('id')
          .eq('participant1_id', participant1Id)
          .eq('participant2_id', participant2Id)
          .maybeSingle();

      if (existingConversation == null) {
        // Criar nova conversa
        await _supabase.from('conversations').insert({
          'participant1_id': participant1Id,
          'participant2_id': participant2Id,
          'proposal_id': proposalId,
        });
        print('✅ Conversa criada automaticamente');
      } else {
        print('ℹ️ Conversa já existe');
      }
    } catch (e) {
      print('Erro ao criar conversa: $e');
      // Não bloquear o fluxo se falhar ao criar conversa
    }
  }

  Future<void> _rejectProposal(String proposalId) async {
    try {
      await _supabase
          .from('proposals')
          .update({'status': 'rejected'})
          .eq('id', proposalId);

      // Recarregar propostas
      await _loadProposals();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proposta rejeitada.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorModal.show(
          context,
          title: 'Erro ao rejeitar proposta',
          message: 'Não foi possível rejeitar a proposta. Tente novamente.',
        );
      }
    }
  }

  String _formatCurrency(double value) {
    final formatted = value.toStringAsFixed(2);
    final parts = formatted.split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];
    
    String formattedInteger = '';
    for (int i = integerPart.length - 1; i >= 0; i--) {
      formattedInteger = integerPart[i] + formattedInteger;
      if ((integerPart.length - i) % 3 == 0 && i > 0) {
        formattedInteger = '.$formattedInteger';
      }
    }
    
    return 'R\$ $formattedInteger,$decimalPart';
  }

  ProposalStatus _getProposalStatus(String? status) {
    switch (status) {
      case 'accepted':
        return ProposalStatus.accepted;
      case 'rejected':
        return ProposalStatus.rejected;
      default:
        return ProposalStatus.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColorsPrimary.primary50,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColorsPrimary.primary700,
          ),
        ),
      );
    }

    final filteredProposals = _getFilteredProposals();
    final title = _isClient ? 'Propostas recebidas' : 'Propostas enviadas';
    final subtitle = _isClient 
        ? '${_proposals.length} proposta${_proposals.length != 1 ? 's' : ''} recebida${_proposals.length != 1 ? 's' : ''}'
        : '${_proposals.length} proposta${_proposals.length != 1 ? 's' : ''} enviada${_proposals.length != 1 ? 's' : ''}';

    return Scaffold(
      backgroundColor: AppColorsPrimary.primary50,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 120,
        backgroundColor: Colors.transparent,
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.spacing24,
            right: AppSpacing.spacing24,
            top: 60,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.heading1.copyWith(
                  color: AppColorsPrimary.primary800,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing4),
              Text(
                subtitle,
                style: AppTypography.contentRegular.copyWith(
                  color: AppColorsNeutral.neutral500,
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isClient
          ? _buildReceivedProposals(filteredProposals)
          : _buildSentProposals(filteredProposals),
    );
  }

  Widget _buildReceivedProposals(List<Map<String, dynamic>> proposals) {
    final counts = _getProposalCounts();
    
    return Column(
      children: [
        // Filtros com contadores
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing24,
            vertical: AppSpacing.spacing16,
          ),
          child: Column(
            children: [
              // Primeira linha: Pendentes e Aceitas
              Row(
                children: [
                  Expanded(
                    child: _buildFilterChip(
                      text: 'Pendentes',
                      count: counts['pending'] ?? 0,
                      icon: Icons.schedule,
                      isSelected: _selectedFilters[0],
                      onTap: () => setState(() {
                        _selectedFilters[0] = !_selectedFilters[0];
                      }),
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spacing12),
                  Expanded(
                    child: _buildFilterChip(
                      text: 'Aceitas',
                      count: counts['accepted'] ?? 0,
                      icon: Icons.check_circle,
                      isSelected: _selectedFilters[1],
                      onTap: () => setState(() {
                        _selectedFilters[1] = !_selectedFilters[1];
                      }),
                      color: AppColorsSuccess.success600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spacing12),
              // Segunda linha: Rejeitadas e Pagas
              Row(
                children: [
                  Expanded(
                    child: _buildFilterChip(
                      text: 'Rejeitadas',
                      count: counts['rejected'] ?? 0,
                      icon: Icons.cancel,
                      isSelected: _selectedFilters[2],
                      onTap: () => setState(() {
                        _selectedFilters[2] = !_selectedFilters[2];
                      }),
                      color: AppColorsError.error600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spacing12),
                  Expanded(
                    child: _buildFilterChip(
                      text: 'Pagas',
                      count: counts['paid'] ?? 0,
                      icon: Icons.verified,
                      isSelected: _selectedFilters[3],
                      onTap: () => setState(() {
                        _selectedFilters[3] = !_selectedFilters[3];
                      }),
                      color: Colors.purple.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Lista de propostas
        Expanded(
          child: _isLoadingProposals
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColorsPrimary.primary700,
                  ),
                )
              : proposals.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhuma proposta encontrada',
                        style: AppTypography.contentRegular.copyWith(
                          color: AppColorsNeutral.neutral500,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadProposals,
                      color: AppColorsPrimary.primary700,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.spacing24,
                          0,
                          AppSpacing.spacing24,
                          AppSpacing.spacing24,
                        ),
                        itemCount: proposals.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSpacing.spacing16),
                        itemBuilder: (context, index) {
                          final proposal = proposals[index];
                          final freelancer = proposal['profiles'] as Map<String, dynamic>?;
                          final serviceRequest = proposal['service_requests'] as Map<String, dynamic>?;
                          final paymentStatus = proposal['payment_status'] as String?;
                          
                          final freelancerName = freelancer?['full_name'] as String? ?? 'Freelancer';
                          final distance = proposal['distance'] as double? ?? 0.0;
                          final price = proposal['proposed_price'] as num? ?? 0;
                          final availabilityValue = proposal['availability_value'] as int? ?? 0;
                          final availabilityUnit = proposal['availability_unit'] as String? ?? 'Horas';
                          final status = proposal['status'] as String?;
                          final serviceRequestId = proposal['service_request_id'] as String;
                          final proposalId = proposal['id'] as String;
                          final serviceName = serviceRequest?['service_description'] as String? ?? 'Serviço';
                          
                          // Se proposta está paga, mostrar card especial com botão de chat
                          if (paymentStatus == 'paid') {
                            final paymentDetails = proposal['payment_details'] as Map<String, dynamic>?;
                            return PaidProposalCard(
                              name: freelancerName,
                              location: 'Em ${distance_util.AppDistanceCalculator.formatDistance(distance)}',
                              price: _formatCurrency(price.toDouble()),
                              serviceName: serviceName,
                              paymentMethod: paymentDetails?['payment_method'] as String?,
                              paymentDate: paymentDetails?['created_at'] as String?,
                              releaseStatus: paymentDetails?['release_status'] as String?,
                              onChat: () {
                                // TODO: Navegar para chat
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Chat em desenvolvimento'),
                                  ),
                                );
                              },
                            );
                          }
                          
                          // Se a proposta foi aceita (mas não paga), mostrar card com botão de pagamento
                          if (status == 'accepted') {
                            // Buscar dados completos do pagamento
                            return FutureBuilder<Map<String, dynamic>?>(
                              future: _getPaymentData(proposalId),
                              builder: (context, snapshot) {
                                final paymentData = snapshot.data;
                                final hasPaidPayment = paymentData != null;
                                final releaseStatus = paymentData?['release_status'] as String?;
                                
                                return AcceptedProposalCard(
                                  name: freelancerName,
                                  location: 'Em ${distance_util.AppDistanceCalculator.formatDistance(distance)}',
                                  price: _formatCurrency(price.toDouble()),
                                  timeframe: 'Em até $availabilityValue $availabilityUnit',
                                  hasPaidPayment: hasPaidPayment,
                                  paymentReleaseStatus: releaseStatus,
                                  onPay: () {
                                    // Navegar para tela de pagamento
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CreatePaymentPageImproved(
                                          serviceRequestId: serviceRequestId,
                                          proposalId: proposalId,
                                        ),
                                      ),
                                    ).then((_) {
                                      // Recarregar propostas após voltar da tela de pagamento
                                      _loadProposals();
                                    });
                                  },
                                  onChat: hasPaidPayment ? () {
                                    // TODO: Navegar para chat
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Chat em desenvolvimento'),
                                      ),
                                    );
                                  } : null,
                                  onReleasePayment: (hasPaidPayment && releaseStatus == 'retained') ? () {
                                    // Navegar para tela de liberar pagamento
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ReleasePaymentPage(
                                          proposalId: proposalId,
                                          paymentData: paymentData,
                                          freelancerProfile: freelancer!,
                                        ),
                                      ),
                                    ).then((released) {
                                      if (released == true) {
                                        // Recarregar propostas após liberar pagamento
                                        _loadProposals();
                                      }
                                    }).catchError((_) {
                                      // Ignorar erros de navegação
                                    });
                                  } : null,
                                );
                              },
                            );
                          }
                          
                          // Proposta pendente - mostrar botões de aceitar/rejeitar
                          return ReceivedProposalCard(
                            name: freelancerName,
                            location: 'Em ${distance_util.AppDistanceCalculator.formatDistance(distance)}',
                            price: _formatCurrency(price.toDouble()),
                            timeframe: 'Em até $availabilityValue $availabilityUnit',
                            onAccept: () => _acceptProposal(proposal['id'] as String),
                            onReject: () => _rejectProposal(proposal['id'] as String),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildSentProposals(List<Map<String, dynamic>> proposals) {
    final counts = _getProposalCounts();
    
    return Column(
      children: [
        // Filtros com contadores (mesma UI que cliente)
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing24,
            vertical: AppSpacing.spacing16,
          ),
          child: Column(
            children: [
              // Primeira linha: Pendentes e Aceitas
              Row(
                children: [
                  Expanded(
                    child: _buildFilterChip(
                      text: 'Pendentes',
                      count: counts['pending'] ?? 0,
                      icon: Icons.schedule,
                      isSelected: _selectedFilters[0],
                      onTap: () => setState(() {
                        _selectedFilters[0] = !_selectedFilters[0];
                      }),
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spacing12),
                  Expanded(
                    child: _buildFilterChip(
                      text: 'Aceitas',
                      count: counts['accepted'] ?? 0,
                      icon: Icons.check_circle,
                      isSelected: _selectedFilters[1],
                      onTap: () => setState(() {
                        _selectedFilters[1] = !_selectedFilters[1];
                      }),
                      color: AppColorsSuccess.success600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spacing12),
              // Segunda linha: Rejeitadas e Pagas
              Row(
                children: [
                  Expanded(
                    child: _buildFilterChip(
                      text: 'Rejeitadas',
                      count: counts['rejected'] ?? 0,
                      icon: Icons.cancel,
                      isSelected: _selectedFilters[2],
                      onTap: () => setState(() {
                        _selectedFilters[2] = !_selectedFilters[2];
                      }),
                      color: AppColorsError.error600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spacing12),
                  Expanded(
                    child: _buildFilterChip(
                      text: 'Pagas',
                      count: counts['paid'] ?? 0,
                      icon: Icons.verified,
                      isSelected: _selectedFilters[3],
                      onTap: () => setState(() {
                        _selectedFilters[3] = !_selectedFilters[3];
                      }),
                      color: Colors.purple.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Lista de propostas
        Expanded(
          child: _isLoadingProposals
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColorsPrimary.primary700,
                  ),
                )
              : proposals.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhuma proposta encontrada',
                        style: AppTypography.contentRegular.copyWith(
                          color: AppColorsNeutral.neutral500,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadProposals,
                      color: AppColorsPrimary.primary700,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.spacing24,
                          0,
                          AppSpacing.spacing24,
                          AppSpacing.spacing24,
                        ),
                        itemCount: proposals.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSpacing.spacing16),
                        itemBuilder: (context, index) {
                          final proposal = proposals[index];
                          final serviceRequest = proposal['service_requests'] as Map<String, dynamic>?;
                          final client = serviceRequest?['profiles'] as Map<String, dynamic>?;
                          final paymentStatus = proposal['payment_status'] as String?;
                          
                          final clientName = client?['full_name'] as String? ?? 'Cliente';
                          final distance = proposal['distance'] as double? ?? 0.0;
                          final price = proposal['proposed_price'] as num? ?? 0;
                          final availabilityValue = proposal['availability_value'] as int? ?? 0;
                          final availabilityUnit = proposal['availability_unit'] as String? ?? 'Horas';
                          final serviceName = serviceRequest?['service_description'] as String? ?? 'Serviço';
                          
                          // Se proposta está paga, mostrar card especial com botão de chat
                          if (paymentStatus == 'paid') {
                            final paymentDetails = proposal['payment_details'] as Map<String, dynamic>?;
                            return PaidProposalCard(
                              name: clientName,
                              location: 'Em ${distance_util.AppDistanceCalculator.formatDistance(distance)}',
                              price: _formatCurrency(price.toDouble()),
                              serviceName: serviceName,
                              paymentMethod: paymentDetails?['payment_method'] as String?,
                              paymentDate: paymentDetails?['created_at'] as String?,
                              releaseStatus: paymentDetails?['release_status'] as String?,
                              onChat: () {
                                // TODO: Navegar para chat
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Chat em desenvolvimento'),
                                  ),
                                );
                              },
                            );
                          }
                          
                          // Proposta normal (pending, accepted, rejected)
                          final status = _getProposalStatus(proposal['status'] as String?);
                          
                          return SentProposalCard(
                            name: clientName,
                            location: 'Em ${distance_util.AppDistanceCalculator.formatDistance(distance)}',
                            price: _formatCurrency(price.toDouble()),
                            timeframe: 'Em até $availabilityValue $availabilityUnit',
                            status: status,
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String text,
    required int count,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? color.withOpacity(0.1) : AppColorsNeutral.neutral0,
        foregroundColor: isSelected ? color : AppColorsNeutral.neutral600,
        side: BorderSide(
          color: isSelected ? color.withOpacity(0.5) : AppColorsNeutral.neutral200,
          width: isSelected ? 2 : 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radius8),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacing12,
          vertical: AppSpacing.spacing12,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? color : AppColorsNeutral.neutral500,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: AppTypography.contentMedium.copyWith(
                color: isSelected ? color : AppColorsNeutral.neutral600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          // Contador
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected ? color : AppColorsNeutral.neutral300,
              borderRadius: AppRadius.radius4,
            ),
            child: Text(
              '$count',
              style: AppTypography.captionBold.copyWith(
                color: isSelected ? Colors.white : AppColorsNeutral.neutral700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
