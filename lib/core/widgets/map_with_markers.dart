// lib/core/widgets/map_with_markers.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Widget de mapa com marcadores customizados
class MapWithMarkers extends StatefulWidget {
  /// Coordenada central do mapa
  final LatLng center;
  
  /// Zoom inicial do mapa
  final double initialZoom;
  
  /// Lista de marcadores para exibir
  final List<MapMarker> markers;
  
  /// Callback quando um marcador é tocado
  final Function(MapMarker)? onMarkerTap;
  
  /// Callback quando o mapa é tocado
  final Function(LatLng)? onMapTap;
  
  /// Se o mapa pode ser interativo
  final bool isInteractive;

  const MapWithMarkers({
    super.key,
    required this.center,
    required this.markers,
    this.initialZoom = 12.0,
    this.isInteractive = true,
    this.onMarkerTap,
    this.onMapTap,
  });

  @override
  State<MapWithMarkers> createState() => _MapWithMarkersState();
}

class _MapWithMarkersState extends State<MapWithMarkers> {
  late MapController _mapController;
  LatLng? _selectedMarkerPosition;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void didUpdateWidget(MapWithMarkers oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.center != oldWidget.center) {
      _mapController.move(widget.center, widget.initialZoom);
    }
  }

  void moveToLocation(LatLng newCenter, {double? zoom}) {
    _mapController.move(newCenter, zoom ?? widget.initialZoom);
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.center,
        initialZoom: widget.initialZoom,
        interactionOptions: InteractionOptions(
          flags: widget.isInteractive
              ? InteractiveFlag.all
              : InteractiveFlag.none,
        ),
        onTap: (tapPosition, point) {
          _selectedMarkerPosition = null;
          widget.onMapTap?.call(point);
          setState(() {});
        },
      ),
      children: [
        // Camada de tiles do OpenStreetMap
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.trabalheja.app',
          maxZoom: 19,
          minZoom: 3,
        ),
        // Círculo de seleção (se houver marcador selecionado)
        if (_selectedMarkerPosition != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: _selectedMarkerPosition!,
                radius: 50,
                color: Colors.cyan.withOpacity(0.2),
                borderColor: Colors.cyan,
                borderStrokeWidth: 2,
              ),
            ],
          ),
        // Camada de marcadores
        MarkerLayer(
          markers: widget.markers.map((mapMarker) {
            return Marker(
              point: mapMarker.position,
              width: mapMarker.width,
              height: mapMarker.height,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMarkerPosition = mapMarker.position;
                  });
                  widget.onMarkerTap?.call(mapMarker);
                },
                child: mapMarker.child,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Classe para representar um marcador no mapa
class MapMarker {
  final LatLng position;
  final Widget child;
  final double width;
  final double height;
  final dynamic data; // Dados associados ao marcador

  MapMarker({
    required this.position,
    required this.child,
    this.width = 40,
    this.height = 40,
    this.data,
  });
}

