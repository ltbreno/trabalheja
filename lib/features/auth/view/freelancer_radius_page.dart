// lib/features/auth/view/freelancer_radius_page.dart
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/core/widgets/app_map.dart';
import 'package:trabalheja/features/auth/view/freelancer_picture_page.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_dropdown_field.dart';

class FreelancerRadiusPage extends StatefulWidget {
  // Receber dados das telas anteriores, se necessário
  // final String fullName;
  // final Map<String, dynamic> addressData;

  const FreelancerRadiusPage({
    super.key,
    // required this.fullName,
    // required this.addressData,
  });

  @override
  State<FreelancerRadiusPage> createState() => _FreelancerRadiusPageState();
}

class _FreelancerRadiusPageState extends State<FreelancerRadiusPage> {
  final _supabase = Supabase.instance.client;
  String? _selectedRadius = '5km'; // Valor inicial
  bool _isLoading = false;
  bool _isLoadingLocation = false;
  LatLng? _currentCenter; // centro dinâmico quando localização disponível
  final AppMapController _mapController = AppMapController();

  final List<DropdownItem<String>> _radiusOptions = [
    DropdownItem(value: '5km', label: 'Até 5km'),
    DropdownItem(value: '10km', label: 'Até 10km'),
    DropdownItem(value: '20km', label: 'Até 20km'),
    DropdownItem(value: '50km', label: 'Mais de 50km'),
  ];

  // Posição padrão (Interlagos, SP) caso localização não esteja disponível
  static const LatLng _fallbackCenter = LatLng(-23.6975, -46.6953);

  /// Converte o valor do raio selecionado para metros
  double _getRadiusInMeters(String? radiusValue) {
    switch (radiusValue) {
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

  @override
  void initState() {
    super.initState();
    _askAndLoadCurrentLocation();
  }

  Future<void> _askAndLoadCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        // mantém fallback; usuário pode ativar manualmente depois
        setState(() {
          _currentCenter = null;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newCenter = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentCenter = newCenter;
      });

      // Centralizar mapa na localização atual
      _mapController.moveToLocation(newCenter);

      // Tentar reverse geocode e salvar endereço para auto-preencher a AddressPage
      await _reverseGeocodeAndPersist(position.latitude, position.longitude);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Localização atual detectada.')),
      );
    } catch (e) {
      // Silencioso: usa fallback
      setState(() {
        _currentCenter = null;
      });
    }
  }

  Future<void> _centerOnCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissão de localização negada. Habilite nas configurações do dispositivo.'),
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newCenter = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentCenter = newCenter;
      });

      // Centralizar mapa na localização atual
      _mapController.moveToLocation(newCenter);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mapa centralizado na sua localização.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao obter localização: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<void> _reverseGeocodeAndPersist(double lat, double lng) async {
    try {
      final placemarks = await geo.placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return;
      final p = placemarks.first;

      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('profiles').update({
        'address_rua': p.street?.trim().isEmpty == true ? null : p.street,
        'address_bairro': p.subLocality?.trim().isEmpty == true ? null : p.subLocality,
        'address_cidade': [p.subAdministrativeArea, p.administrativeArea]
                .where((e) => (e ?? '').isNotEmpty)
                .join(', '),
        // CEP nem sempre vem no iOS/Android; tenta postalCode quando disponível
        'address_cep': p.postalCode?.trim().isEmpty == true ? null : p.postalCode,
      }).eq('id', user.id);
    } catch (_) {
      // Ignora falhas de geocodificação
    }
  }

  Future<void> _continue() async {
    if (_selectedRadius == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione um raio de atuação.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Salvar raio de atuação e coordenadas no perfil
      // Como freelancers precisam ter coordenadas (constraint do banco),
      // vamos criar o perfil parcialmente aqui se não existir
      final center = _currentCenter ?? _fallbackCenter;
      
      // Buscar email e phone do usuário
      final userEmail = user.email ?? user.userMetadata?['email'] as String?;
      final userPhone = user.userMetadata?['phone'] as String?;
      
      if (userEmail == null || userPhone == null) {
        throw Exception('Email ou telefone do usuário não encontrado');
      }

      // Verificar se o perfil já existe
      final existingProfile = await _supabase
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (existingProfile != null) {
        // Perfil existe, fazer UPDATE
        print('📝 [FreelancerRadiusPage] Atualizando perfil existente com coordenadas...');
        await _supabase.from('profiles').update({
          'service_radius': _selectedRadius,
          'service_latitude': center.latitude,
          'service_longitude': center.longitude,
        }).eq('id', user.id);
        print('✅ [FreelancerRadiusPage] Coordenadas salvas com sucesso!');
      } else {
        // Perfil não existe, criar parcialmente com dados mínimos necessários
        print('📝 [FreelancerRadiusPage] Criando perfil parcial com coordenadas...');
        final profileData = <String, dynamic>{
          'id': user.id,
          'account_type': 'freelancer',
          'email': userEmail,
          'phone': userPhone,
          'service_radius': _selectedRadius,
          'service_latitude': center.latitude,
          'service_longitude': center.longitude,
        };
        
        try {
          await _supabase.from('profiles').insert(profileData);
          print('✅ [FreelancerRadiusPage] Perfil parcial criado com coordenadas!');
        } catch (insertError) {
          // Se o perfil foi criado entre a verificação e o insert, fazer update
          if (insertError.toString().contains('duplicate') || 
              insertError.toString().contains('unique')) {
            print('⚠️ [FreelancerRadiusPage] Perfil foi criado, fazendo UPDATE...');
            await _supabase.from('profiles').update({
              'service_radius': _selectedRadius,
              'service_latitude': center.latitude,
              'service_longitude': center.longitude,
            }).eq('id', user.id);
            print('✅ [FreelancerRadiusPage] Coordenadas atualizadas!');
          } else {
            rethrow;
          }
        }
      }

      if (!mounted) return;

      // Navegar para FreelancerPicturePage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FreelancerPicturePage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar raio de atuação: ${e.toString()}'),
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
          'Voltar',
          style: AppTypography.contentMedium.copyWith(
              color: AppColorsNeutral.neutral900,
          ),
        ),
      ),
      body: SafeArea(
        child: Column( // Alterado para Column
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.spacing16),
                  Text(
                    'Raio de atuação', // Título
                    style: AppTypography.heading1.copyWith(
                      color: AppColorsNeutral.neutral900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacing8),
                  Text(
                    'Defina um raio de atuação para seus serviços. Você poderá mudar isso mais tarde.', // Subtítulo
                    style: AppTypography.contentRegular.copyWith(
                      color: AppColorsNeutral.neutral600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacing24),
                  AppDropdownField<String>(
                    label: 'Selecione o raio de atuação',
                    items: _radiusOptions,
                    selectedValue: _selectedRadius,
                    onChanged: (value) {
                      setState(() {
                        _selectedRadius = value;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.spacing24),
                ],
              ),
            ),
            
            // Mapa
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing24),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.spacing12),
                      child: AppMap(
                        controller: _mapController,
                        center: _currentCenter ?? _fallbackCenter,
                        radius: _getRadiusInMeters(_selectedRadius),
                        initialZoom: 12.0,
                        isInteractive: true, // Habilitar interação
                      ),
                    ),
                    // Botão para centralizar na localização atual
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton.small(
                        onPressed: _isLoadingLocation ? null : _centerOnCurrentLocation,
                        backgroundColor: AppColorsPrimary.primary700,
                        child: _isLoadingLocation
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Icon(
                                Icons.my_location,
                                color: AppColorsNeutral.neutral0,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Botão Continuar
            Padding(
              padding: const EdgeInsets.all(AppSpacing.spacing24),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : AppButton.primary(
                      text: 'Continuar',
                      onPressed: _continue,
                      minWidth: double.infinity,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}