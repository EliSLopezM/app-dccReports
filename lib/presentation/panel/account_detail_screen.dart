import 'package:flutter/material.dart';

import '../../domain/entities/account.dart';
import '../../domain/entities/account_role.dart';
import '../../domain/entities/account_status.dart';
import '../../domain/entities/course_catalog.dart';

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

/// RF-12: detalle de una cuenta para Admin/Funcionario/Líder funcionario.
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
