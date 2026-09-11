import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/account.dart';
import '../../domain/entities/account_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../content/capacitate_stub_screen.dart';
import '../content/news_stub_screen.dart';
import '../content/preparate_stub_screen.dart';
import '../panel/panel_accounts_list_screen.dart';

/// Shell post-login. RF-11: solo Admin/Funcionario/Líder funcionario ven
/// acceso al panel (mismo `canReviewAccounts` que RF-6/RF-7).
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DCC-BOGOTA'),
        actions: [
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
          if (account.role.canReviewAccounts)
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
        ],
      ),
    );
  }
}
