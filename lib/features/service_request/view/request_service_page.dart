import 'package:flutter/material.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_dropdown_field.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';
import 'package:trabalheja/features/service_request/view/request_success_page.dart'; // Importar tela de sucesso
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/widgets/app_map.dart';

class RequestServicePage extends StatefulWidget {
  const RequestServicePage({super.key});

  @override
  State<RequestServicePage> createState() => _RequestServicePageState();
}

class _RequestServicePageState extends State<RequestServicePage> {
  final _serviceController = TextEditingController();
  final _budgetController = TextEditingController();
  final _timeValueController = TextEditingController();
  final _infoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _selectedTimeUnit = 'Horas';
  final _supabase = Supabase.instance.client;

  // Mapa
  static const LatLng _fallbackCenter = LatLng(-23.6975, -46.6953);
  final AppMapController _mapController = AppMapController();
  LatLng _mapCenter = _fallbackCenter;
  bool _isLoadingLocation = false;

  final List<DropdownItem<String>> _timeOptions = [
    DropdownItem(value: 'Horas', label: 'Horas'),
    DropdownItem(value: 'Dias', label: 'Dias'),
    DropdownItem(value: 'Semanas', label: 'Semanas'),
    DropdownItem(value: 'Meses', label: 'Meses'),
  ];

  @override
  void dispose() {
    _serviceController.dispose();
    _budgetController.dispose();
    _timeValueController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final hasPermission = await _ensureLocationPermission();
      if (!hasPermission) return;
      final Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final LatLng current = LatLng(pos.latitude, pos.longitude);
      _mapController.moveToLocation(current, zoom: 15);
      setState(() {
        _mapCenter = current;
      });
    } catch (_) {
      // Silenciar erro e manter fallback
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<bool> _ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  int _convertToHours(int value, String unit) {
    switch (unit) {
      case 'Horas':
        return value;
      case 'Dias':
        return value * 24;
      case 'Semanas':
        return value * 7 * 24;
      case 'Meses':
        return value * 30 * 24; // aproximação
      default:
        return value;
    }
  }

  double _parseBudget(String input) {
    final sanitized = input
        .replaceAll(RegExp(r'[^0-9,\.]'), '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(sanitized) ?? 0.0;
  }

  Future<void> _submitRequest() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Pegar centro atual do mapa (se disponível no controller)
    final LatLng center = _mapController.currentCenter ?? _mapCenter;

    if (center.latitude.isNaN || center.longitude.isNaN) {
      return; // Falha silenciosa, mas idealmente exibir mensagem ao usuário
    }

    final String serviceDesc = _serviceController.text.trim();
    final double budget = _parseBudget(_budgetController.text.trim());
    final int? timeValue = int.tryParse(_timeValueController.text.trim());
    final String unit = _selectedTimeUnit ?? 'Horas';
    final int deadlineHours = _convertToHours(timeValue ?? 0, unit);
    final String? additionalInfo = _infoController.text.trim().isEmpty
        ? null
        : _infoController.text.trim();

    if (budget <= 0 || (timeValue == null || timeValue <= 0)) {
      return; // Ideal: exibir feedback de validação
    }

    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      await _supabase.from('service_requests').insert({
        'client_id': user.id,
        'service_description': serviceDesc,
        'budget': budget,
        'deadline_hours': deadlineHours,
        'additional_info': additionalInfo,
        'service_latitude': center.latitude,
        'service_longitude': center.longitude,
        'status': 'pending',
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RequestSuccessPage()),
      );
    } catch (_) {
      // Ideal: exibir modal de erro
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.spacing24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.spacing16),
                // Localização no mapa
                Text(
                  'Localização do serviço',
                  style: AppTypography.captionMedium.copyWith(
                    color: AppColorsPrimary.primary950,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing8),
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.radius12,
                    border: Border.all(color: AppColorsNeutral.neutral200),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AppMap(
                    center: _mapCenter,
                    radius: 30,
                    initialZoom: 14,
                    isInteractive: true,
                    controller: _mapController,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing8),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: _isLoadingLocation ? 'Localizando...' : 'Usar minha localização',
                        onPressed: _isLoadingLocation ? null : _useCurrentLocation,
                        minWidth: double.infinity,
                        type: AppButtonType.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spacing16),
                Text(
                  'Solicitar serviço',
                  style: AppTypography.heading1.copyWith(
                    color: AppColorsPrimary.primary900, // Cor roxa
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing32),
                
                AppTextField(
                  label: 'Qual serviço você precisa?',
                  hintText: 'ex: Trocar chuveiro',
                  controller: _serviceController,
                  validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
                  textColor: AppColorsPrimary.primary950,
                  labelColor: AppColorsPrimary.primary950,
                ),
                const SizedBox(height: AppSpacing.spacing16),
                
                AppTextField(
                  label: 'Qual seu orçamento para o serviço?',
                  hintText: 'R\$ 0,00',
                  controller: _budgetController,
                  textColor: AppColorsPrimary.primary950,
                  labelColor: AppColorsPrimary.primary950,
                  keyboardType: TextInputType.number,
                  prefixIconPath: 'assets/icons/money.svg', // Ícone de dinheiro
                  iconColor: AppColorsPrimary.primary950,
                  prefixIconSize: 16,
                  validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: AppSpacing.spacing16),
                
                // Campos de tempo: valor + unidade
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Em quanto tempo você precisa?',
                      style: AppTypography.captionMedium.copyWith(
                        color: AppColorsPrimary.primary950,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: '',
                            hintText: '8',
                            controller: _timeValueController,
                            textColor: AppColorsPrimary.primary950,
                            keyboardType: TextInputType.number,
                            validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.spacing8),
                        Expanded(
                          child: AppDropdownField<String>(
                            label: '',
                            hintText: 'Unidade',
                            items: _timeOptions,
                            selectedValue: _selectedTimeUnit,
                            onChanged: (value) {
                              setState(() {
                                _selectedTimeUnit = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spacing8),

                AppTextField(
                  label: 'Informações adicionais',
                  hintText: 'Adicione informações adicionais para o freelancer calcular melhor a proposta',
                  controller: _infoController,
                  keyboardType: TextInputType.multiline,
                  minLines: 4,
                  maxLines: 6,
                  textColor: AppColorsPrimary.primary950,
                  labelColor: AppColorsPrimary.primary950,
                ),
                const SizedBox(height: AppSpacing.spacing16),

                // Aviso de Privacidade
                Container(
                  padding: const EdgeInsets.all(AppSpacing.spacing12),
                  decoration: BoxDecoration(
                    color: AppColorsError.error50,
                    borderRadius: AppRadius.radius8,
                  ),
                  child: Text(
                    'Não inclua seus dados pessoais ou de contato na descrição. Toda negociação deve ser feita pelo aplicativo.',
                    style: AppTypography.captionRegular.copyWith(color: AppColorsNeutral.neutral700),
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing32),

                // Botão Enviar
                _isLoading
                   ? const Center(child: CircularProgressIndicator())
                   : AppButton.primary(
                      text: 'Solicitar serviço',
                      onPressed: _submitRequest,
                      minWidth: double.infinity,
                    ),
                const SizedBox(height: AppSpacing.spacing16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
