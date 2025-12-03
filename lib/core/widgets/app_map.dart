// lib/core/widgets/app_map.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:trabalheja/core/constants/app_colors.dart';

/// Controller para manipular o AppMap programaticamente
class AppMapController {
  _AppMapState? _state;

  void _attach(_AppMapState state) {
    _state = state;
  }

  void _detach() {
    _state = null;
  }

  /// Centraliza o mapa em uma nova posição
  void moveToLocation(LatLng newCenter, {double? zoom}) {
    _state?.moveToLocation(newCenter, zoom: zoom);
  }

  /// Obtém o centro atual do mapa
  LatLng? get currentCenter => _state?.currentCenter;
}

/// Widget de mapa usando OpenStreetMap (gratuito)
/// 
/// Este widget substitui o Google Maps por uma solução open source
/// que não requer API keys e é totalmente gratuito para testes.
class AppMap extends StatefulWidget {
  /// Coordenada central do mapa
  final LatLng center;
  
  /// Raio do círculo em metros
  final double radius;
  
  /// Zoom inicial do mapa
  final double initialZoom;
  
  /// Se o mapa pode ser interativo (scroll, zoom)
  final bool isInteractive;
  
  /// Cor de preenchimento do círculo
  final Color? circleFillColor;
  
  /// Cor da borda do círculo
  final Color? circleStrokeColor;
  
  /// Largura da borda do círculo
  final double circleStrokeWidth;

  /// Controller opcional para manipular o mapa
  final AppMapController? controller;

  const AppMap({
    super.key,
    required this.center,
    required this.radius,
    this.initialZoom = 12.0,
    this.isInteractive = true,
    this.circleFillColor,
    this.circleStrokeColor,
    this.circleStrokeWidth = 2.0,
    this.controller,
  });

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  late MapController _mapController;
  late LatLng _currentCenter;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentCenter = widget.center;
    widget.controller?._attach(this);
  }

  @override
  void dispose() {
    widget.controller?._detach();
    super.dispose();
  }

  @override
  void didUpdateWidget(AppMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.center != oldWidget.center) {
      _currentCenter = widget.center;
      _mapController.move(_currentCenter, widget.initialZoom);
    }
    if (widget.radius != oldWidget.radius) {
      setState(() {}); // Atualiza o círculo quando o raio muda
    }
  }

  /// Centraliza o mapa em uma nova posição
  void moveToLocation(LatLng newCenter, {double? zoom}) {
    if (mounted) {
      setState(() {
        _currentCenter = newCenter;
      });
      _mapController.move(newCenter, zoom ?? widget.initialZoom);
    }
  }

  /// Obtém o controller do mapa (para uso externo)
  MapController get mapController => _mapController;

  /// Obtém o centro atual
  LatLng get currentCenter => _currentCenter;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentCenter,
        initialZoom: widget.initialZoom,
        interactionOptions: InteractionOptions(
          flags: widget.isInteractive
              ? InteractiveFlag.all
              : InteractiveFlag.none,
        ),
      ),
      children: [
        // Camada de tiles do OpenStreetMap
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.trabalheja.app',
          maxZoom: 19,
          minZoom: 3,
        ),
        // Camada de círculos (raio de atuação)
        CircleLayer(
          circles: [
            CircleMarker(
              point: _currentCenter,
              radius: widget.radius,
              color: widget.circleFillColor ??
                  AppColorsPrimary.primary500.withOpacity(0.2),
              borderColor: widget.circleStrokeColor ?? AppColorsPrimary.primary700,
              borderStrokeWidth: widget.circleStrokeWidth,
            ),
          ],
        ),
        // Camada de marcadores
        MarkerLayer(
          markers: [
            Marker(
              point: _currentCenter,
              width: 40,
              height: 40,
              child: Icon(
                Icons.location_on,
                color: AppColorsPrimary.primary700,
                size: 40,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

