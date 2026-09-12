import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/emergency_report.dart';
import '../../domain/entities/emergency_type_catalog.dart';

EmergencyType _typeFor(String id) {
  for (final type in kEmergencyTypeCatalog) {
    if (type.id == id) return type;
  }
  return kEmergencyTypeCatalog.last;
}

/// RF-3/RF-4: detalle público de una emergencia activa, con
/// recomendaciones según su tipo.
class EmergencyDetailScreen extends StatelessWidget {
  const EmergencyDetailScreen({super.key, required this.report});

  final EmergencyReport report;

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
        ],
      ),
    );
  }
}
