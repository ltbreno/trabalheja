import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trabalheja/core/utils/distance_calculator.dart';

void main() {
  group('AppDistanceCalculator', () {
    test('formats short and long distances corretamente', () {
      expect(AppDistanceCalculator.formatDistance(950), '950m');
      expect(AppDistanceCalculator.formatDistance(2500), '2.5km');
      expect(AppDistanceCalculator.formatDistance(12000), '12km');
    });

    test('calcula distância aproximada entre pontos próximos', () {
      final distanceMeters = AppDistanceCalculator.calculateDistanceInMeters(
        const LatLng(0, 0),
        const LatLng(0, 0.01),
      );

      // Aproximadamente 1.11 km na linha do equador
      expect(distanceMeters, closeTo(1110, 10));
    });

    test('verifica se ponto está dentro do raio', () {
      final center = const LatLng(0, 0);
      final nearPoint = const LatLng(0, 0.005); // ~555 m
      final farPoint = const LatLng(0, 0.02); // ~2.2 km

      expect(
        AppDistanceCalculator.isWithinRadius(center, nearPoint, 600),
        isTrue,
      );
      expect(
        AppDistanceCalculator.isWithinRadius(center, farPoint, 600),
        isFalse,
      );
    });
  });
}
