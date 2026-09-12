import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/date_filter.dart';
import '../../domain/entities/emergency_report.dart';
import '../../domain/entities/emergency_type_catalog.dart';
import '../../domain/repositories/emergency_report_repository.dart';
import 'emergency_detail_screen.dart';
import 'map_marker_data.dart';
import 'map_view.dart';

const _filterLabels = {
  EmergencyDateFilter.today: 'Hoy',
  EmergencyDateFilter.thisWeek: 'Esta semana',
  EmergencyDateFilter.thisMonth: 'Este mes',
  EmergencyDateFilter.last3Months: '3 meses',
  EmergencyDateFilter.last6Months: '6 meses',
  EmergencyDateFilter.lastYear: 'Último año',
};

// Centro de Bogotá — solo se usa como fallback cuando ningún reporte
// visible tiene coordenadas (RF-13/RF-14 de la spec 002).
const _bogotaCenter = (latitude: 4.6486, longitude: -74.0628);

String _typeLabel(String id) {
  for (final type in kEmergencyTypeCatalog) {
    if (type.id == id) return type.label;
  }
  return id;
}

/// RF-1/RF-2: mapa de emergencias "activa", con filtro de fecha.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  EmergencyDateFilter _filter = EmergencyDateFilter.thisWeek;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<EmergencyReportRepository>();
    final since = _filter.cutoff(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de emergencias'),
        actions: [
          PopupMenuButton<EmergencyDateFilter>(
            key: const Key('date-filter-menu'),
            tooltip: 'Filtrar por fecha',
            icon: const Icon(Icons.filter_list),
            initialValue: _filter,
            onSelected: (value) => setState(() => _filter = value),
            itemBuilder: (context) => [
              for (final filter in EmergencyDateFilter.values)
                PopupMenuItem(value: filter, child: Text(_filterLabels[filter]!)),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<EmergencyReport>>(
        stream: repository.watchActiveReports(since: since),
        builder: (context, snapshot) {
          final reports = snapshot.data ?? const [];
          if (reports.isEmpty) {
            return const Center(
              key: Key('map-empty-state'),
              child: Text('No hay emergencias activas en este rango.'),
            );
          }

          final withLocation = reports.where((r) => r.hasLocation).toList();
          return MapView(
            center: withLocation.isEmpty
                ? _bogotaCenter
                : (latitude: withLocation.first.latitude!, longitude: withLocation.first.longitude!),
            markers: [
              for (final report in withLocation)
                MapMarkerData(
                  id: report.id,
                  latitude: report.latitude!,
                  longitude: report.longitude!,
                  title: report.title,
                  snippet: _typeLabel(report.emergencyTypeId),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => EmergencyDetailScreen(report: report)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
