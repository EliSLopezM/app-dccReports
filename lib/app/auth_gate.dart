import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/entities/account.dart';
import '../domain/entities/account_status.dart';
import '../domain/repositories/account_repository.dart';
import '../domain/repositories/auth_repository.dart';
import '../presentation/home/home_shell.dart';
import '../presentation/login/login_screen.dart';
import '../presentation/pending/pending_approval_screen.dart';

/// Enruta según sesión + estado de la cuenta: sin sesión → Login; con
/// sesión y cuenta pendiente/rechazada → Pending (RF-4); aprobada → Home.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: context.read<AuthRepository>().watchCurrentUid(),
      builder: (context, uidSnapshot) {
        if (uidSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScaffold();
        }
        final uid = uidSnapshot.data;
        if (uid == null) return const LoginScreen();

        return StreamBuilder<Account?>(
          stream: context.read<AccountRepository>().watchAccount(uid),
          builder: (context, accountSnapshot) {
            if (accountSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScaffold();
            }
            final account = accountSnapshot.data;
            if (account == null) return const _LoadingScaffold();
            if (account.status == AccountStatus.approved) {
              return HomeShell(account: account);
            }
            return PendingApprovalScreen(status: account.status);
          },
        );
      },
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
