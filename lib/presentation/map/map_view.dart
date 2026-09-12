import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

import '../../app/maps_config.dart';
import '../../app/theme.dart';
import 'map_marker_data.dart';

/// RF-7: mapa real si `mapsConfigured` (por defecto
/// `kGoogleMapsConfigured`), placeholder en caso contrario — mismo
/// patrón que AmiPets. `markers` es público para que los tests lean los
/// pines y disparen `onTap` sin necesitar que `GoogleMap` renderice de
/// verdad (no lo hace en `flutter test`).
class MapView extends StatelessWidget {
  const MapView({
    super.key,
    required this.center,
    required this.markers,
    this.mapsConfigured = kGoogleMapsConfigured,
  });

  final ({double latitude, double longitude}) center;
  final List<MapMarkerData> markers;
  final bool mapsConfigured;

  @override
  Widget build(BuildContext context) {
    if (!mapsConfigured) return const _MapPlaceholder();
    return gmaps.GoogleMap(
      initialCameraPosition: gmaps.CameraPosition(
        target: gmaps.LatLng(center.latitude, center.longitude),
        zoom: 12,
      ),
      markers: {
        for (final marker in markers)
          gmaps.Marker(
            markerId: gmaps.MarkerId(marker.id),
            position: gmaps.LatLng(marker.latitude, marker.longitude),
            infoWindow: gmaps.InfoWindow(title: marker.title, snippet: marker.snippet),
            onTap: marker.onTap,
          ),
      },
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DccColors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.map_outlined, size: 48, color: DccColors.blue),
              SizedBox(height: 8),
              Text(
                'El mapa se activará cuando exista una API key de Google Maps.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
