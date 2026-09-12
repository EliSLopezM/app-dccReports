import 'package:flutter/widgets.dart';

/// Dato de pin desacoplado de `google_maps_flutter` — permite construir
/// y testear la lista de marcadores sin depender del widget real del
/// mapa (ver `MapView`).
class MapMarkerData {
  const MapMarkerData({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.title,
    this.snippet,
    this.onTap,
  });

  final String id;
  final double latitude;
  final double longitude;
  final String title;
  final String? snippet;
  final VoidCallback? onTap;
}
