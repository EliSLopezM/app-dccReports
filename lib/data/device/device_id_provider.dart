import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const _deviceIdKey = 'dcc_device_id';

/// RF-4: identificador de instalación, no de hardware (ver plan.md,
/// "Decisiones técnicas"). Se genera una sola vez y se reutiliza.
class DeviceIdProvider {
  DeviceIdProvider({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  Future<String> getOrCreate() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_deviceIdKey);
    if (existing != null) return existing;

    final generated = _uuid.v4();
    await prefs.setString(_deviceIdKey, generated);
    return generated;
  }
}
