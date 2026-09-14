import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/account_role.dart';
import '../../domain/exceptions.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/participation_repository.dart';

/// RF-5/RF-7/RF-8: sugiere la ubicación GPS de quien lo pone (sin
/// mini-mapa interactivo mientras no haya una API key real, ver
/// plan.md).
class MeetingPointPickerScreen extends StatefulWidget {
  const MeetingPointPickerScreen({
    super.key,
    required this.reportId,
    required this.requesterId,
    required this.requesterRole,
  });

  final String reportId;
  final String requesterId;
  final AccountRole requesterRole;

  @override
  State<MeetingPointPickerScreen> createState() =>
      _MeetingPointPickerScreenState();
}

class _MeetingPointPickerScreenState extends State<MeetingPointPickerScreen> {
  ({double latitude, double longitude})? _suggested;
  bool _loading = true;
  bool _confirming = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final location = await context
        .read<LocationRepository>()
        .getCurrentLocation();
    if (!mounted) return;
    setState(() {
      _suggested = location;
      _loading = false;
    });
  }

  Future<void> _confirm() async {
    final location = _suggested;
    if (location == null) return;
    setState(() => _confirming = true);
    try {
      await context.read<ParticipationRepository>().setMeetingPoint(
        reportId: widget.reportId,
        requesterId: widget.requesterId,
        requesterRole: widget.requesterRole,
        latitude: location.latitude,
        longitude: location.longitude,
      );
      if (mounted) Navigator.of(context).pop();
    } on MeetingPointBlockedException {
      setState(
        () => _errorMessage =
            'Ya hay un punto de encuentro puesto por otra persona.',
      );
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Punto de encuentro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ubica un punto de encuentro cerca de la emergencia para que los '
                    'demás voluntarios sepan dónde reunirse.',
                  ),
                  const SizedBox(height: 16),
                  if (_suggested != null)
                    Text(
                      'Ubicación sugerida: ${_suggested!.latitude.toStringAsFixed(5)}, '
                      '${_suggested!.longitude.toStringAsFixed(5)}',
                      key: const Key('suggested-location'),
                    )
                  else
                    const Text(
                      'No se pudo obtener tu ubicación. Intenta de nuevo más tarde.',
                      key: Key('no-location-message'),
                    ),
                  const SizedBox(height: 24),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      key: const Key('meeting-point-error'),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ElevatedButton(
                    key: const Key('confirm-meeting-point-button'),
                    onPressed: (_suggested == null || _confirming)
                        ? null
                        : _confirm,
                    child: Text(
                      _confirming ? 'Confirmando...' : 'Confirmar aquí',
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
