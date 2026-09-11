import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/emergency_report.dart';
import '../../domain/repositories/emergency_report_repository.dart';

/// RF-12: historial de reportes de un mismo dispositivo o teléfono.
class ReporterHistoryScreen extends StatelessWidget {
  const ReporterHistoryScreen.byDevice({super.key, required String deviceId})
      // ignore: prefer_initializing_formals
      : _deviceId = deviceId,
        _phone = null;

  const ReporterHistoryScreen.byPhone({super.key, required String phone})
      : _deviceId = null,
        // ignore: prefer_initializing_formals
        _phone = phone;

  final String? _deviceId;
  final String? _phone;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<EmergencyReportRepository>();
    final stream = _deviceId != null
        ? repository.watchReportsByDevice(_deviceId)
        : repository.watchReportsByPhone(_phone!);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de reportes')),
      body: StreamBuilder<List<EmergencyReport>>(
        stream: stream,
        builder: (context, snapshot) {
          final reports = snapshot.data ?? const [];
          if (reports.isEmpty) {
            return const Center(child: Text('Sin reportes previos.'));
          }
          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return ListTile(
                title: Text(report.title),
                subtitle: Text(report.status.name),
              );
            },
          );
        },
      ),
    );
  }
}
