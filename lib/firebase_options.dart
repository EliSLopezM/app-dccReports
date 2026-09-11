import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Opciones de Firebase para el proyecto de demostración local
/// `demo-dccbogota`, usado únicamente con el Firebase Local Emulator
/// Suite (constitución: sin credenciales reales en el repo; ver
/// `specs/001-fundacional/plan.md`). Cuando exista un proyecto real de
/// Firebase, este archivo se reemplaza corriendo `flutterfire configure`.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return android;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está configurado para esta plataforma.',
        );
    }
  }

  static const android = FirebaseOptions(
    apiKey: 'AIzaSy000000000000000000000000000000000',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'demo-dccbogota',
    storageBucket: 'demo-dccbogota.appspot.com',
  );

  static const ios = FirebaseOptions(
    apiKey: 'AIzaSy000000000000000000000000000000000',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'demo-dccbogota',
    storageBucket: 'demo-dccbogota.appspot.com',
    iosBundleId: 'co.dcc.bogota.appDccReports',
  );
}
