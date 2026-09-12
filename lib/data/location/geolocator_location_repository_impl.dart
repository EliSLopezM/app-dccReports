import 'package:geolocator/geolocator.dart';

import '../../domain/repositories/location_repository.dart';

/// Delegación directa al plugin `geolocator` — fuera de los tests
/// unitarios (no se puede simular GPS real en la suite); se ejerce
/// indirectamente vía un fake de [LocationRepository] en
/// `PublicReportScreen`.
class GeolocatorLocationRepositoryImpl implements LocationRepository {
  @override
  Future<({double latitude, double longitude})?> getCurrentLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return null;
      }
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      final position = await Geolocator.getCurrentPosition();
      return (latitude: position.latitude, longitude: position.longitude);
    } catch (_) {
      return null;
    }
  }
}
