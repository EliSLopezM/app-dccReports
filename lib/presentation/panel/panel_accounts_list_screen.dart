import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/account.dart';
import '../../domain/entities/account_role.dart';
import '../../domain/entities/account_status.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import 'account_detail_screen.dart';

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

/// RF-11: panel embebido — lista todas las cuentas. RF-7: oculta
/// aprobar/rechazar en filas de rango alto si quien mira no es Admin.
class PanelAccountsListScreen extends StatefulWidget {
  const PanelAccountsListScreen({
    super.key,
    required this.viewerRole,
    required this.viewerId,
  });

  final AccountRole viewerRole;
  final String viewerId;

  @override
  State<PanelAccountsListScreen> createState() => _PanelAccountsListScreenState();
}

class _PanelAccountsListScreenState extends State<PanelAccountsListScreen> {
  AccountStatus? _statusFilter = AccountStatus.pending;
  late final Stream<List<Account>> _accountsStream;

  @override
  void initState() {
    super.initState();
    // Un solo stream para el ciclo de vida del widget: si se pidiera de
    // nuevo en cada build (ej. dentro de StreamBuilder.stream), cada
    // filtro nuevo re-suscribiría a Firestore y parpadearía en "cargando".
    _accountsStream = context.read<AccountRepository>().watchAllAccounts();
  }

  /// RF-4 (spec 004): una cuenta con comité asignado entra a su chat de
  /// comité justo al ser aprobada.
  Future<void> _approve(BuildContext context, Account account) async {
    final accountRepository = context.read<AccountRepository>();
    final chatRepository = context.read<ChatRepository>();
    await accountRepository.approve(
      reviewerRole: widget.viewerRole,
      reviewerId: widget.viewerId,
      accountId: account.id,
    );
    final comiteId = account.comiteId;
    if (comiteId != null) {
      await chatRepository.ensureComiteMembership(comiteId: comiteId, uid: account.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel — Cuentas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Todas'),
                  selected: _statusFilter == null,
                  onSelected: (_) => setState(() => _statusFilter = null),
                ),
                for (final status in AccountStatus.values)
                  ChoiceChip(
                    label: Text(_statusLabels[status]!),
                    selected: _statusFilter == status,
                    onSelected: (_) => setState(() => _statusFilter = status),
                  ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Account>>(
              stream: _accountsStream,
              builder: (context, snapshot) {
                final accounts = (snapshot.data ?? const [])
                    .where((a) => _statusFilter == null || a.status == _statusFilter)
                    .toList();
                if (accounts.isEmpty) {
                  return const Center(child: Text('No hay cuentas para este filtro.'));
                }
                return ListView.builder(
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    final showReviewActions = account.status == AccountStatus.pending &&
                        canReview(reviewerRole: widget.viewerRole, targetRole: account.role);
                    return ListTile(
                      title: Text(account.name),
                      subtitle: Text(
                        '${_roleLabels[account.role]} · ${_statusLabels[account.status]}',
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => AccountDetailScreen(account: account)),
                      ),
                      trailing: showReviewActions
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  tooltip: 'Aprobar',
                                  onPressed: () => _approve(context, account),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  tooltip: 'Rechazar',
                                  onPressed: () => context.read<AccountRepository>().reject(
                                        reviewerRole: widget.viewerRole,
                                        reviewerId: widget.viewerId,
                                        accountId: account.id,
                                      ),
                                ),
                              ],
                            )
                          : null,
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
