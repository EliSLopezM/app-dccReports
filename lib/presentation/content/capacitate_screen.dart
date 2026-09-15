import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../../app/capacitate_config.dart';

typedef LaunchUrl = Future<bool> Function(Uri uri);

Future<bool> defaultLaunchUrl(Uri uri) =>
    launcher.launchUrl(uri, mode: launcher.LaunchMode.externalApplication);

/// RF-5/RF-6: información para unirse a la Defensa Civil y enlace externo
/// (Google Forms) de postulación.
class CapacitateScreen extends StatelessWidget {
  const CapacitateScreen({
    super.key,
    this.formUrl = kCapacitateFormUrl,
    this.launchUrl = defaultLaunchUrl,
  });

  final String formUrl;
  final LaunchUrl launchUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capacítate')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Si quieres unirte a la Defensa Civil Colombiana, seccional '
            'Bogotá, revisa los requisitos y postúlate desde el '
            'formulario oficial.',
          ),
          const SizedBox(height: 24),
          if (formUrl.isEmpty)
            const Text(
              'El formulario de postulación no está disponible todavía.',
              key: Key('capacitate-unavailable-message'),
            )
          else
            ElevatedButton(
              key: const Key('capacitate-apply-button'),
              onPressed: () => launchUrl(Uri.parse(formUrl)),
              child: const Text('Postúlate'),
            ),
        ],
      ),
    );
  }
}
