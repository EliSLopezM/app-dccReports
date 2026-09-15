import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/account.dart';
import '../../domain/entities/account_status.dart';
import '../../domain/entities/content_kind.dart';
import '../../domain/repositories/auth_repository.dart';
import '../content/capacitate_screen.dart';
import '../content/content_list_screen.dart';
import '../legal/legal_screen.dart';

/// RF-4: mientras la cuenta está pendiente (o fue rechazada), solo se
/// puede navegar a Noticias/Capacítate/Prepárate/Legal (spec 008, RF-3)
/// — nada de mapa, emergencias, chats ni panel.
class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final status = account.status;
    final message = status == AccountStatus.rejected
        ? 'Tu solicitud fue rechazada. Puedes registrarte de nuevo si crees que fue un error.'
        : 'Tu cuenta está pendiente de aprobación por un administrador de la DCC.';

    return Scaffold(
      appBar: AppBar(title: const Text('DCC-BOGOTA')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(message, key: const Key('pending-status-message')),
          const SizedBox(height: 24),
          ListTile(
            key: const Key('news-access'),
            leading: const Icon(Icons.newspaper),
            title: const Text('Noticias'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ContentListScreen(
                  kind: ContentKind.noticia,
                  viewerId: account.id,
                  viewerRole: account.role,
                ),
              ),
            ),
          ),
          ListTile(
            key: const Key('capacitate-access'),
            leading: const Icon(Icons.school),
            title: const Text('Capacítate'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CapacitateScreen()),
            ),
          ),
          ListTile(
            key: const Key('preparate-access'),
            leading: const Icon(Icons.health_and_safety),
            title: const Text('Prepárate'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ContentListScreen(
                  kind: ContentKind.preparate,
                  viewerId: account.id,
                  viewerRole: account.role,
                ),
              ),
            ),
          ),
          ListTile(
            key: const Key('legal-access'),
            leading: const Icon(Icons.gavel),
            title: const Text('Legal'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LegalScreen()),
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => context.read<AuthRepository>().logout(),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
