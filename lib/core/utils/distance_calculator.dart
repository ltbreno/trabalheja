// lib/core/utils/distance_calculator.dart
import 'package:latlong2/latlong.dart';

/// Utilitário para calcular distâncias entre coordenadas geográficas
class AppDistanceCalculator {
  static const Distance _distance = Distance();

  /// Calcula a distância em metros entre duas coordenadas
  /// 
  /// Retorna a distância em metros usando a fórmula de Haversine
  static double calculateDistanceInMeters(
    LatLng point1,
    LatLng point2,
  ) {
    return _distance.as(LengthUnit.Meter, point1, point2);
  }

  /// Calcula a distância em quilômetros entre duas coordenadas
  static double calculateDistanceInKm(
    LatLng point1,
    LatLng point2,
  ) {
    return _distance.as(LengthUnit.Kilometer, point1, point2);
  }

  /// Formata a distância para exibição (ex: "2.5 km" ou "500 m")
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()}m';
    } else {
      final km = distanceInMeters / 1000;
      if (km < 10) {
        return '${km.toStringAsFixed(1)}km';
      } else {
        return '${km.round()}km';
      }
    }
  }

  /// Verifica se um ponto está dentro do raio especificado (em metros)
  static bool isWithinRadius(
    LatLng center,
    LatLng point,
    double radiusInMeters,
  ) {
    final distance = calculateDistanceInMeters(center, point);
    return distance <= radiusInMeters;
  }
}

