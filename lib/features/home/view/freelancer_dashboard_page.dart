// lib/features/home/view/freelancer_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/core/utils/distance_calculator.dart' as distance_util;
import 'package:trabalheja/core/widgets/map_with_markers.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/service_request/view/service_details_page.dart';

class FreelancerDashboardPage extends StatefulWidget {
  const FreelancerDashboardPage({super.key});

  @override
  State<FreelancerDashboardPage> createState() => _FreelancerDashboardPageState();
}

class _FreelancerDashboardPageState extends State<FreelancerDashboardPage> {
  final _supabase = Supabase.instance.client;
  final _searchController = TextEditingController();
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _serviceRequests = [];
  List<Map<String, dynamic>> _filteredRequests = [];
  Map<String, dynamic>? _selectedRequest;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  
  // Coordenadas do freelancer
  LatLng? _freelancerLocation;
  double _serviceRadius = 5000; // metros padrão

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _searchController.addListener(_filterServices);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Carregar perfil do freelancer
      final profile = await _supabase
          .from('profiles')
          .select('service_latitude, service_longitude, service_radius')
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null) {
        final lat = profile['service_latitude'] as double?;
        final lng = profile['service_longitude'] as double?;
        final radiusStr = profile['service_radius'] as String?;
        
        if (lat != null && lng != null) {
          _freelancerLocation = LatLng(lat, lng);
          
          // Converter raio para metros
          if (radiusStr != null) {
            _serviceRadius = _parseRadiusToMeters(radiusStr);
          }
        }
      }

      // Carregar solicitações de serviço pendentes
      await _loadServiceRequests();
    } catch (e) {
      print('Erro ao carregar dados do dashboard: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  double _parseRadiusToMeters(String radiusStr) {
    switch (radiusStr) {
      case '5km':
        return 5000;
      case '10km':
        return 10000;
      case '20km':
        return 20000;
      case '50km':
        return 50000;
      default:
        return 5000;
    }
  }

  Future<void> _loadServiceRequests() async {
    try {
      // Buscar solicitações pendentes
      final requests = await _supabase
          .from('service_requests')
          .select('''
            *,
            profiles!client_id (
              id,
              full_name,
              profile_picture_url
            )
          ''')
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> requestsList = [];
      
      if (_freelancerLocation != null) {
        for (var request in requests) {
          final lat = request['service_latitude'] as double?;
          final lng = request['service_longitude'] as double?;
          
          if (lat != null && lng != null) {
            final requestLocation = LatLng(lat, lng);
            final distance = distance_util.AppDistanceCalculator.calculateDistanceInMeters(
              _freelancerLocation!,
              requestLocation,
            );
            
            // Filtrar apenas serviços dentro do raio de atuação
            if (distance <= _serviceRadius) {
              request['distance'] = distance;
              requestsList.add(request);
            }
          }
        }
        
        // Ordenar por distância
        requestsList.sort((a, b) => 
          (a['distance'] as double).compareTo(b['distance'] as double)
        );
      }
      
      setState(() {
        _serviceRequests = requestsList;
        _filteredRequests = requestsList;
      });
    } catch (e) {
      print('Erro ao carregar solicitações: $e');
    }
  }

  void _filterServices() {
    final query = _searchController.text.toLowerCase().trim();
    
    if (query.isEmpty) {
      setState(() {
        _filteredRequests = _serviceRequests;
      });
      return;
    }

    setState(() {
      _filteredRequests = _serviceRequests.where((request) {
        final description = (request['service_description'] ?? '').toString().toLowerCase();
        return description.contains(query);
      }).toList();
    });
  }

  List<MapMarker> _buildMarkers() {
    return _filteredRequests.map((request) {
      final lat = request['service_latitude'] as double?;
      final lng = request['service_longitude'] as double?;
      
      if (lat == null || lng == null) return null;
      
      return MapMarker(
        position: LatLng(lat, lng),
        width: 40,
        height: 40,
        data: request,
        child: Icon(
          Icons.person_pin,
          color: AppColorsPrimary.primary700,
          size: 40,
        ),
      );
    }).whereType<MapMarker>().toList();
  }

  void _onMarkerTap(MapMarker marker) {
    setState(() {
      _selectedRequest = marker.data as Map<String, dynamic>?;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppColorsPrimary.primary700,
          ),
        ),
      );
    }
    
    final center = _freelancerLocation ?? const LatLng(-23.5505, -46.6333);
    
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          // Mapa
          MapWithMarkers(
            center: center,
            initialZoom: 13.0,
            markers: _buildMarkers(),
            onMarkerTap: _onMarkerTap,
          ),
          
          // Botão "Bicos próximos"
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacing16,
                vertical: AppSpacing.spacing12,
              ),
              decoration: BoxDecoration(
                color: AppColorsPrimary.primary700,
                borderRadius: AppRadius.radius8,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/icons/location_pin.svg',
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      AppColorsNeutral.neutral0,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spacing8),
                  Text(
                    'Bicos próximos',
                    style: AppTypography.contentMedium.copyWith(
                      color: AppColorsNeutral.neutral0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.35,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColorsNeutral.neutral0,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Handle
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColorsNeutral.neutral300,
                        borderRadius: AppRadius.radius2,
                      ),
                    ),
                    
                    // Conteúdo
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(AppSpacing.spacing24),
                        children: [
                          // Título
                          Text(
                            'Qual bico você está procurando?',
                            style: AppTypography.highlightBold.copyWith(
                              color: AppColorsNeutral.neutral900,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spacing16),
                          
                          // Campo de busca
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Pesquisar serviços',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(12),
                                child: SvgPicture.asset(
                                  'assets/icons/search.svg',
                                  height: 20,
                                  colorFilter: ColorFilter.mode(
                                    AppColorsNeutral.neutral500,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              filled: true,
                              fillColor: AppColorsNeutral.neutral50,
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.radius8,
                                borderSide: BorderSide(
                                  color: AppColorsNeutral.neutral200,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: AppRadius.radius8,
                                borderSide: BorderSide(
                                  color: AppColorsNeutral.neutral200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: AppRadius.radius8,
                                borderSide: BorderSide(
                                  color: AppColorsPrimary.primary700,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: AppSpacing.spacing24),
                          
                          // Cliente selecionado (se houver)
                          if (_selectedRequest != null) ...[
                            Text(
                              'Cliente selecionado',
                              style: AppTypography.captionRegular.copyWith(
                                color: AppColorsNeutral.neutral600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.spacing12),
                            _buildSelectedClientCard(_selectedRequest!),
                            const SizedBox(height: AppSpacing.spacing24),
                          ],
                          
                          // Clientes próximos
                          Text(
                            'Clientes próximos',
                            style: AppTypography.captionRegular.copyWith(
                              color: AppColorsNeutral.neutral600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spacing12),
                          
                          // Lista de clientes
                          if (_filteredRequests.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(AppSpacing.spacing32),
                              child: Center(
                                child: Text(
                                  'Nenhum bico próximo encontrado',
                                  style: AppTypography.contentRegular.copyWith(
                                    color: AppColorsNeutral.neutral500,
                                  ),
                                ),
                              ),
                            )
                          else
                            ..._filteredRequests.map((request) => 
                              _buildClientCard(request)
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedClientCard(Map<String, dynamic> request) {
    final client = request['profiles'] as Map<String, dynamic>?;
    final clientName = client?['full_name'] as String? ?? 'Cliente';
    final serviceDesc = request['service_description'] as String? ?? '';
    final budget = request['budget'] as num? ?? 0;
    final deadlineHours = request['deadline_hours'] as int? ?? 0;
    final distance = request['distance'] as double? ?? 0.0;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      decoration: BoxDecoration(
        color: AppColorsNeutral.neutral0,
        borderRadius: AppRadius.radius12,
        border: Border.all(color: AppColorsNeutral.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColorsNeutral.neutral200,
                child: Text(
                  clientName.isNotEmpty ? clientName[0].toUpperCase() : 'C',
                  style: AppTypography.heading4.copyWith(
                    color: AppColorsNeutral.neutral600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName,
                      style: AppTypography.contentMedium.copyWith(
                        color: AppColorsNeutral.neutral900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      serviceDesc,
                      style: AppTypography.captionRegular.copyWith(
                        color: AppColorsNeutral.neutral600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing16),
          
          // Informações
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.location_on,
                text: 'Em ${distance_util.AppDistanceCalculator.formatDistance(distance)}',
              ),
              const SizedBox(width: AppSpacing.spacing8),
              _buildInfoChip(
                icon: Icons.attach_money,
                text: _formatCurrency(budget.toDouble()),
              ),
              const SizedBox(width: AppSpacing.spacing8),
              _buildInfoChip(
                icon: Icons.calendar_today,
                text: 'Em até $deadlineHours horas',
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.spacing16),
          
          // Botão
          AppButton.primary(
            text: 'Detalhes do serviço',
            onPressed: () {
              if (_selectedRequest != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ServiceDetailsPage(
                      serviceRequest: _selectedRequest!,
                    ),
                  ),
                );
              }
            },
            minWidth: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildClientCard(Map<String, dynamic> request) {
    final client = request['profiles'] as Map<String, dynamic>?;
    final clientName = client?['full_name'] as String? ?? 'Cliente';
    final isSelected = _selectedRequest?['id'] == request['id'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRequest = request;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.spacing12),
        padding: const EdgeInsets.all(AppSpacing.spacing16),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColorsPrimary.primary50 
              : AppColorsNeutral.neutral0,
          borderRadius: AppRadius.radius12,
          border: Border.all(
            color: isSelected 
                ? AppColorsPrimary.primary700 
                : AppColorsNeutral.neutral200,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColorsNeutral.neutral200,
              child: Text(
                clientName.isNotEmpty ? clientName[0].toUpperCase() : 'C',
                style: AppTypography.heading4.copyWith(
                  color: AppColorsNeutral.neutral600,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.spacing12),
            Expanded(
              child: Text(
                clientName,
                style: AppTypography.contentMedium.copyWith(
                  color: AppColorsNeutral.neutral900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double value) {
    // Formatar como R$ 1.234,56
    final formatted = value.toStringAsFixed(2);
    final parts = formatted.split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];
    
    // Adicionar pontos de milhar
    String formattedInteger = '';
    for (int i = integerPart.length - 1; i >= 0; i--) {
      formattedInteger = integerPart[i] + formattedInteger;
      if ((integerPart.length - i) % 3 == 0 && i > 0) {
        formattedInteger = '.$formattedInteger';
      }
    }
    
    return 'R\$ $formattedInteger,$decimalPart';
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacing8,
          vertical: AppSpacing.spacing6,
        ),
        decoration: BoxDecoration(
          color: AppColorsNeutral.neutral50,
          borderRadius: AppRadius.radius6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColorsNeutral.neutral600),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                style: AppTypography.captionRegular.copyWith(
                  color: AppColorsNeutral.neutral600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

