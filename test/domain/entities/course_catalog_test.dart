import 'package:flutter_test/flutter_test.dart';
import 'package:app_dcc_reports/domain/entities/course_catalog.dart';

void main() {
  test('el catálogo de cursos no está vacío y no tiene ids duplicados', () {
    expect(kCourseCatalog, isNotEmpty);
    final ids = kCourseCatalog.map((course) => course.id).toList();
    expect(ids.toSet().length, ids.length);
  });
}
