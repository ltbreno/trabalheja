// lib/features/auth/view/freelancer_radius_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
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
  final Completer<GoogleMapController> _mapController = Completer();
  final _supabase = Supabase.instance.client;
  String? _selectedRadius = '5km'; // Valor inicial
  bool _isLoading = false;

  final List<DropdownItem<String>> _radiusOptions = [
    DropdownItem(value: '5km', label: 'Até 5km'),
    DropdownItem(value: '10km', label: 'Até 10km'),
    DropdownItem(value: '20km', label: 'Até 20km'),
    DropdownItem(value: '50km', label: 'Mais de 50km'),
  ];

  // Posição de exemplo (Interlagos, SP)
  static const LatLng _center = LatLng(-23.6975, -46.6953);

  // Círculo no mapa
  final Set<Circle> _circles = {
    Circle(
      circleId: const CircleId('radius_circle'),
      center: _center,
      radius: 5000, // 5km (raio em metros)
      fillColor: AppColorsPrimary.primary500.withOpacity(0.2),
      strokeColor: AppColorsPrimary.primary700,
      strokeWidth: 2,
    ),
  };

  // Marcador no mapa
  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('center_pin'),
      position: _center,
    ),
  };

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

      // Tentar salvar raio de atuação e coordenadas no perfil
      // Se o perfil não existir ainda (freelancer), ignorar silenciosamente
      // O perfil será criado apenas no final do processo
      try {
        await _supabase.from('profiles').update({
          'service_radius': _selectedRadius,
          'service_latitude': _center.latitude,
          'service_longitude': _center.longitude,
        }).eq('id', user.id);
      } catch (e) {
        // Se o perfil não existir, ignorar (será criado no final)
        print('ℹ️ [FreelancerRadiusPage] Perfil ainda não existe (será criado no final)');
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
                        // TODO: Atualizar o raio do Círculo no mapa
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.spacing24),
                ],
              ),
            ),
            
            // Mapa
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.spacing12),
                child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: const CameraPosition(
                    target: _center,
                    zoom: 12.0, // Ajuste o zoom inicial
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController.complete(controller);
                  },
                  circles: _circles,
                  markers: _markers,
                  zoomControlsEnabled: false, // Desabilitar controles de zoom
                  scrollGesturesEnabled: false, // Desabilitar scroll (opcional)
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