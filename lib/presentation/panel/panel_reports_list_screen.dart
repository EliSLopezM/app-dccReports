import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/emergency_report.dart';
import '../../domain/entities/emergency_type_catalog.dart';
import '../../domain/entities/report_status.dart';
import '../../domain/repositories/emergency_report_repository.dart';
import 'report_detail_screen.dart';

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

/// RF-8: panel embebido — lista todos los reportes, con filtro por estado.
class PanelReportsListScreen extends StatefulWidget {
  const PanelReportsListScreen({super.key, required this.reviewerId});

  final String reviewerId;

  @override
  State<PanelReportsListScreen> createState() => _PanelReportsListScreenState();
}

class _PanelReportsListScreenState extends State<PanelReportsListScreen> {
  ReportStatus? _statusFilter = ReportStatus.pending;
  late final Stream<List<EmergencyReport>> _reportsStream;

  @override
  void initState() {
    super.initState();
    _reportsStream = context.read<EmergencyReportRepository>().watchAllReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel — Reportes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Todos'),
                  selected: _statusFilter == null,
                  onSelected: (_) => setState(() => _statusFilter = null),
                ),
                for (final status in ReportStatus.values)
                  ChoiceChip(
                    label: Text(_statusLabels[status]!),
                    selected: _statusFilter == status,
                    onSelected: (_) => setState(() => _statusFilter = status),
                  ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<EmergencyReport>>(
              stream: _reportsStream,
              builder: (context, snapshot) {
                final reports = (snapshot.data ?? const [])
                    .where((r) => _statusFilter == null || r.status == _statusFilter)
                    .toList();
                if (reports.isEmpty) {
                  return const Center(child: Text('No hay reportes para este filtro.'));
                }
                return ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return ListTile(
                      title: Text(report.title),
                      subtitle: Text(
                        '${_typeLabel(report.emergencyTypeId)} · ${_statusLabels[report.status]}',
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ReportDetailScreen(
                            report: report,
                            reviewerId: widget.reviewerId,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
