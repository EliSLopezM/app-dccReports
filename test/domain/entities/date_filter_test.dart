import 'package:app_dcc_reports/domain/entities/date_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 9, 11, 12);

  test('cada filtro calcula el corte esperado (RF-1/RF-2)', () {
    expect(EmergencyDateFilter.today.cutoff(now), DateTime(2026, 9, 10, 12));
    expect(EmergencyDateFilter.thisWeek.cutoff(now), DateTime(2026, 9, 4, 12));
    expect(EmergencyDateFilter.thisMonth.cutoff(now), DateTime(2026, 8, 12, 12));
    expect(EmergencyDateFilter.last3Months.cutoff(now), now.subtract(const Duration(days: 90)));
    expect(EmergencyDateFilter.last6Months.cutoff(now), now.subtract(const Duration(days: 180)));
    expect(EmergencyDateFilter.lastYear.cutoff(now), now.subtract(const Duration(days: 365)));
  });
}
