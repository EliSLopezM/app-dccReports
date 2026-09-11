import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/emergency_report.dart';
import '../../domain/entities/emergency_type_catalog.dart';
import '../../domain/entities/report_status.dart';
import '../../domain/repositories/emergency_report_repository.dart';
import 'reporter_history_screen.dart';

const _statusLabels = {
  ReportStatus.pending: 'Pendiente',
  ReportStatus.activa: 'Activa',
  ReportStatus.verdadera: 'Verdadera',
  ReportStatus.falsaControlada: 'Falsa controlada',
  ReportStatus.enDesarrollo: 'En desarrollo',
};

String _typeLabel(String id) {
  for (final type in kEmergencyTypeCatalog) {
    if (type.id == id) return type.label;
  }
  return id;
}

/// RF-8/RF-9/RF-11: detalle + evidencia (solo visible aquí, en el panel)
/// + cambio de estado.
class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({super.key, required this.report, required this.reviewerId});

  final EmergencyReport report;
  final String reviewerId;

  Future<void> _changeStatus(BuildContext context, ReportStatus status) {
    return context.read<EmergencyReportRepository>().updateStatus(
          reviewerId: reviewerId,
          reportId: report.id,
          newStatus: status,
        );
  }

  @override
  Widget build(BuildContext context) {
    final evidence = report.reporterEvidence;

    return Scaffold(
      appBar: AppBar(title: Text(report.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: report.photoUrls.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: report.photoUrls[index],
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Tipo: ${_typeLabel(report.emergencyTypeId)}'),
          Text('Dirección: ${report.address}'),
          Text('Estado: ${_statusLabels[report.status]}'),
          const SizedBox(height: 16),
          const Text('Evidencia del reportante', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Nombre: ${evidence.name ?? "no dado"}'),
          Text('Teléfono: ${evidence.phone ?? "no dado"}'),
          Text('Dispositivo: ${evidence.deviceId}'),
          Wrap(
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReporterHistoryScreen.byDevice(deviceId: evidence.deviceId),
                  ),
                ),
                child: const Text('Ver historial por dispositivo'),
              ),
              if (evidence.phone != null)
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ReporterHistoryScreen.byPhone(phone: evidence.phone!),
                    ),
                  ),
                  child: const Text('Ver historial por teléfono'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Catalogar como', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: [
              for (final status in [
                ReportStatus.activa,
                ReportStatus.verdadera,
                ReportStatus.falsaControlada,
                ReportStatus.enDesarrollo,
              ])
                ElevatedButton(
                  onPressed: () => _changeStatus(context, status),
                  child: Text(_statusLabels[status]!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
