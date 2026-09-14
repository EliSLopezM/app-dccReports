import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/account_role.dart';
import '../../domain/entities/comite.dart';
import '../../domain/entities/emergency_report.dart';
import '../../domain/entities/emergency_type_catalog.dart';
import '../../domain/entities/report_status.dart';
import '../../domain/repositories/comite_repository.dart';
import '../../domain/repositories/emergency_report_repository.dart';
import '../emergency_response/emergency_response_screen.dart';

EmergencyType _typeFor(String id) {
  for (final type in kEmergencyTypeCatalog) {
    if (type.id == id) return type;
  }
  return kEmergencyTypeCatalog.last;
}

/// RF-3/RF-4 (spec 003), RF-3/RF-12 (spec 005): detalle de una
/// emergencia activa, con recomendaciones, comités convocados por
/// cercanía, acceso a responder, y cierre completo para liderazgo.
class EmergencyDetailScreen extends StatelessWidget {
  const EmergencyDetailScreen({
    super.key,
    required this.report,
    required this.accountId,
    required this.accountName,
    required this.accountRole,
  });

  final EmergencyReport report;
  final String accountId;
  final String accountName;
  final AccountRole accountRole;

  Future<void> _closeEmergency(BuildContext context) {
    return context.read<EmergencyReportRepository>().updateStatus(
          reviewerId: accountId,
          reportId: report.id,
          newStatus: ReportStatus.verdadera,
        );
  }

  @override
  Widget build(BuildContext context) {
    final type = _typeFor(report.emergencyTypeId);

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
          Text('Tipo: ${type.label}'),
          Text('Dirección: ${report.address}'),
          const SizedBox(height: 16),
          const Text('Recomendaciones', style: TextStyle(fontWeight: FontWeight.bold)),
          for (final tip in type.recommendations) Text('• $tip'),
          if (report.hasLocation) ...[
            const SizedBox(height: 16),
            const Text('Comités convocados', style: TextStyle(fontWeight: FontWeight.bold)),
            StreamBuilder<List<Comite>>(
              stream: context.read<ComiteRepository>().watchNearbyComites(
                    latitude: report.latitude!,
                    longitude: report.longitude!,
                  ),
              builder: (context, snapshot) {
                final comites = snapshot.data ?? const [];
                if (comites.isEmpty) {
                  return const Text('Ninguno con coordenadas conocidas cerca.');
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [for (final comite in comites) Text('• ${comite.name}')],
                );
              },
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            key: const Key('respond-button'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EmergencyResponseScreen(
                  report: report,
                  accountId: accountId,
                  accountName: accountName,
                  accountRole: accountRole,
                ),
              ),
            ),
            child: const Text('Responder'),
          ),
          if (accountRole.isEmergencyLeadership)
            OutlinedButton(
              key: const Key('close-emergency-button'),
              onPressed: () => _closeEmergency(context),
              child: const Text('Cerrar emergencia'),
            ),
        ],
      ),
    );
  }
}
