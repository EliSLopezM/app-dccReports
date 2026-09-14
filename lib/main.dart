import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/auth_gate.dart';
import 'app/theme.dart';
import 'data/firebase/firebase_auth_repository_impl.dart';
import 'data/firebase/firestore_account_repository_impl.dart';
import 'data/firebase/firestore_chat_repository_impl.dart';
import 'data/firebase/firestore_comite_repository_impl.dart';
import 'data/firebase/firestore_emergency_report_repository_impl.dart';
import 'data/location/geolocator_location_repository_impl.dart';
import 'domain/repositories/account_repository.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/chat_repository.dart';
import 'domain/repositories/comite_repository.dart';
import 'domain/repositories/emergency_report_repository.dart';
import 'domain/repositories/location_repository.dart';
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
    await FirebaseStorage.instance.useStorageEmulator(host, 9199);
  }

  runApp(const DccApp());
}

Future<String> _uploadReportPhoto(String reportId, String localPath, int index) async {
  final ref = FirebaseStorage.instance.ref('report_photos/$reportId/$index.jpg');
  await ref.putFile(File(localPath));
  return ref.getDownloadURL();
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
        Provider<EmergencyReportRepository>(
          create: (_) => FirestoreEmergencyReportRepositoryImpl(
            FirebaseFirestore.instance,
            uploadPhoto: _uploadReportPhoto,
          ),
        ),
        Provider<LocationRepository>(create: (_) => GeolocatorLocationRepositoryImpl()),
        Provider<ComiteRepository>(
          create: (_) => FirestoreComiteRepositoryImpl(FirebaseFirestore.instance),
        ),
        Provider<ChatRepository>(
          create: (_) => FirestoreChatRepositoryImpl(FirebaseFirestore.instance),
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
