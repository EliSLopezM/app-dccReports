import 'package:app_dcc_reports/domain/entities/emergency_type_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cada tipo de emergencia tiene al menos una recomendación (RF-4)', () {
    for (final type in kEmergencyTypeCatalog) {
      expect(type.recommendations, isNotEmpty, reason: 'Falta recomendación para ${type.id}');
    }
  });
}
