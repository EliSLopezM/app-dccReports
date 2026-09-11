import 'package:app_dcc_reports/data/device/device_id_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('getOrCreate genera un id la primera vez y lo reutiliza después', () async {
    final provider = DeviceIdProvider();

    final first = await provider.getOrCreate();
    final second = await provider.getOrCreate();

    expect(first, isNotEmpty);
    expect(second, first);
  });

  test('un provider nuevo lee el mismo id ya persistido', () async {
    final id = await DeviceIdProvider().getOrCreate();

    final otherProvider = DeviceIdProvider();
    final idFromOtherInstance = await otherProvider.getOrCreate();

    expect(idFromOtherInstance, id);
  });
}
