import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/account.dart';
import '../../domain/entities/account_role.dart';
import '../../domain/entities/account_status.dart';
import '../../domain/entities/course_catalog.dart';
import '../../domain/entities/emergency_type_catalog.dart';
import '../../domain/entities/participation.dart';
import '../../domain/entities/participation_status.dart';
import '../../domain/entities/profile_stats.dart';
import '../../domain/repositories/participation_repository.dart';

const _roleLabels = {
  AccountRole.voluntario: 'Voluntario',
  AccountRole.funcionario: 'Funcionario',
  AccountRole.lider: 'Líder',
  AccountRole.liderFuncionario: 'Líder funcionario',
  AccountRole.admin: 'Admin',
};

const _statusLabels = {
  AccountStatus.pending: 'Pendiente',
  AccountStatus.approved: 'Aprobada',
  AccountStatus.rejected: 'Rechazada',
};

String _typeLabel(String id) {
  for (final type in kEmergencyTypeCatalog) {
    if (type.id == id) return type.label;
  }
  return id;
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  return '${hours}h ${minutes}min';
}

/// RF-12 (spec 001): detalle de cuenta. RF-2/RF-4 (spec 006): logros e
/// historial de participación, visible para cualquier cuenta aprobada.
class AccountDetailScreen extends StatelessWidget {
  const AccountDetailScreen({super.key, required this.account});

  final Account account;

  String _courseLabel(String id) {
    for (final course in kCourseCatalog) {
      if (course.id == id) return course.label;
    }
    return id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(account.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DetailRow(label: 'Rango', value: _roleLabels[account.role]!),
          _DetailRow(label: 'Estado', value: _statusLabels[account.status]!),
          if (account.email != null) _DetailRow(label: 'Correo', value: account.email!),
          if (account.phone != null) _DetailRow(label: 'Teléfono', value: account.phone!),
          const SizedBox(height: 16),
          const Text('Cursos activos', style: TextStyle(fontWeight: FontWeight.bold)),
          if (account.activeCourseIds.isEmpty)
            const Text('Sin cursos registrados.')
          else
            for (final courseId in account.activeCourseIds) Text('• ${_courseLabel(courseId)}'),
          if (account.organization != null) ...[
            const SizedBox(height: 16),
            const Text('Organización', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(account.organization!.name),
            Text(account.organization!.address),
          ],
          const SizedBox(height: 16),
          StreamBuilder<List<Participation>>(
            stream: context.read<ParticipationRepository>().watchParticipationsForAccount(account.id),
            builder: (context, snapshot) {
              final participations = snapshot.data ?? const [];
              final stats = ProfileStats.from(participations);
              final achievements = unlockedAchievements(stats);
              final history = participations
                  .where((p) => p.status == ParticipationStatus.finished)
                  .toList()
                ..sort((a, b) => b.finishedAt!.compareTo(a.finishedAt!));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${stats.totalParticipations} emergencia(s) · ${_formatDuration(stats.totalServiceTime)} de servicio',
                    key: const Key('profile-stats'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Logros', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (achievements.isEmpty)
                    const Text('Todavía sin insignias.')
                  else
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final achievement in achievements)
                          Chip(
                            avatar: const Icon(Icons.military_tech, size: 18),
                            label: Text(achievement.label),
                          ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  const Text('Historial de emergencias', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (history.isEmpty)
                    const Text('Sin emergencias en el historial todavía.')
                  else
                    for (final participation in history)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(participation.reportTitle),
                        subtitle: Text(
                          '${_typeLabel(participation.emergencyTypeId)} · '
                          '${_formatDuration(participation.timeAtEmergency ?? Duration.zero)} en la emergencia',
                        ),
                      ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
