import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/auth_gate.dart';
import 'app/theme.dart';
import 'data/firebase/firebase_auth_repository_impl.dart';
import 'data/firebase/firestore_account_repository_impl.dart';
import 'domain/repositories/account_repository.dart';
import 'domain/repositories/auth_repository.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    // Firebase Local Emulator Suite (`firebase emulators:start`, ver
    // lineamientos/entorno-local.md). El emulador Android usa 10.0.2.2
    // para llegar al host; el resto (iOS) usa localhost.
    final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  }

  runApp(const DccApp());
}

class DccApp extends StatelessWidget {
  const DccApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(
          create: (_) => FirebaseAuthRepositoryImpl(
            FirebaseAuth.instance,
            FirebaseFirestore.instance,
          ),
        ),
        Provider<AccountRepository>(
          create: (_) => FirestoreAccountRepositoryImpl(FirebaseFirestore.instance),
        ),
      ],
      child: MaterialApp(
        title: 'DCC-BOGOTA',
        theme: buildDccTheme(),
        home: const AuthGate(),
      ),
    );
  }
}
