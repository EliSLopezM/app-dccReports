import 'package:flutter/material.dart';

import '../../domain/entities/emergency_report.dart';
import '../../domain/entities/emergency_type_catalog.dart';
import '../map/emergency_detail_screen.dart';

String _typeLabel(String id) {
  for (final type in kEmergencyTypeCatalog) {
    if (type.id == id) return type.label;
  }
  return id;
}

/// RF-6: lista de emergencias activas, alcanzable desde la campana.
class ActiveReportsListScreen extends StatelessWidget {
  const ActiveReportsListScreen({super.key, required this.reports});

  final List<EmergencyReport> reports;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergencias activas')),
      body: reports.isEmpty
          ? const Center(child: Text('No hay emergencias activas.'))
          : ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return ListTile(
                  title: Text(report.title),
                  subtitle: Text('${_typeLabel(report.emergencyTypeId)} · ${report.address}'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => EmergencyDetailScreen(report: report)),
                  ),
                );
              },
            ),
    );
  }
}
