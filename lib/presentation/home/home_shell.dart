import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/account.dart';
import '../../domain/entities/account_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/comite_repository.dart';
import '../chat/chats_list_screen.dart';
import '../chat/create_chat_screen.dart';
import '../comite/comite_management_screen.dart';
import '../content/capacitate_stub_screen.dart';
import '../content/news_stub_screen.dart';
import '../content/preparate_stub_screen.dart';
import '../map/map_screen.dart';
import '../notifications/active_reports_bell.dart';
import '../panel/panel_accounts_list_screen.dart';
import '../panel/panel_reports_list_screen.dart';

/// Shell post-login. RF-11: solo Admin/Funcionario/Líder funcionario ven
/// acceso al panel (mismo `canReviewAccounts` que RF-6/RF-7).
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.account});

  final Account account;

  /// RF-1 (spec 004): un funcionario/líder funcionario con comité es
  /// siempre su líder — cada uno funda exactamente uno al registrarse.
  bool get _isComiteLeader => account.role.requiresOrganization && account.comiteId != null;

  Future<void> _openComiteManagement(BuildContext context) async {
    final comite = await context.read<ComiteRepository>().watchComite(account.comiteId!).first;
    if (comite == null || !context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ComiteManagementScreen(comite: comite, requesterId: account.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DCC-BOGOTA'),
        actions: [
          const ActiveReportsBell(),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => context.read<AuthRepository>().logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Hola, ${account.name}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          ListTile(
            key: const Key('map-access'),
            leading: const Icon(Icons.map),
            title: const Text('Mapa'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MapScreen()),
            ),
          ),
          ListTile(
            key: const Key('chats-access'),
            leading: const Icon(Icons.chat),
            title: const Text('Chats'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatsListScreen(uid: account.id, displayName: account.name),
              ),
            ),
          ),
          if (_isComiteLeader)
            ListTile(
              key: const Key('comite-management-access'),
              leading: const Icon(Icons.groups),
              title: const Text('Mi comité'),
              onTap: () => _openComiteManagement(context),
            ),
          if (account.role == AccountRole.funcionario)
            ListTile(
              key: const Key('create-chat-access'),
              leading: const Icon(Icons.add_comment),
              title: const Text('Crear chats'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreateChatScreen(funcionarioId: account.id),
                ),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.newspaper),
            title: const Text('Noticias'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NewsStubScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Capacítate'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CapacitateStubScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.health_and_safety),
            title: const Text('Prepárate'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PreparateStubScreen()),
            ),
          ),
          if (account.role.canReviewAccounts) ...[
            ListTile(
              key: const Key('panel-access'),
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Panel'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PanelAccountsListScreen(
                    viewerRole: account.role,
                    viewerId: account.id,
                  ),
                ),
              ),
            ),
            ListTile(
              key: const Key('reports-access'),
              leading: const Icon(Icons.report),
              title: const Text('Reportes'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PanelReportsListScreen(reviewerId: account.id),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
