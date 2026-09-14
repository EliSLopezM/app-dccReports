import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../../domain/entities/account_role.dart';
import '../../domain/entities/emergency_report.dart';
import '../../domain/entities/participation.dart';
import '../../domain/entities/participation_status.dart';
import '../../domain/repositories/participation_repository.dart';
import 'finish_participation_screen.dart';
import 'meeting_point_picker_screen.dart';

typedef LaunchUrl = Future<bool> Function(Uri uri);

Future<bool> defaultLaunchUrl(Uri uri) =>
    launcher.launchUrl(uri, mode: launcher.LaunchMode.externalApplication);

const _roleLabels = {
  AccountRole.voluntario: 'Voluntario',
  AccountRole.funcionario: 'Funcionario',
  AccountRole.lider: 'Líder',
  AccountRole.liderFuncionario: 'Líder funcionario',
  AccountRole.admin: 'Admin',
};

const _statusLabels = {
  ParticipationStatus.going: 'En camino',
  ParticipationStatus.arrived: 'En el sitio',
  ParticipationStatus.finished: 'Finalizó',
};

/// RF-1, RF-2, RF-4, RF-5, RF-6, RF-9, RF-10: responder a una emergencia.
class EmergencyResponseScreen extends StatefulWidget {
  const EmergencyResponseScreen({
    super.key,
    required this.report,
    required this.accountId,
    required this.accountName,
    required this.accountRole,
    this.launchUrl = defaultLaunchUrl,
  });

  final EmergencyReport report;
  final String accountId;
  final String accountName;
  final AccountRole accountRole;
  final LaunchUrl launchUrl;

  @override
  State<EmergencyResponseScreen> createState() =>
      _EmergencyResponseScreenState();
}

class _EmergencyResponseScreenState extends State<EmergencyResponseScreen> {
  late final Stream<Participation?> _myParticipationStream;
  late final Stream<List<Participation>> _participantsStream;

  @override
  void initState() {
    super.initState();
    final repository = context.read<ParticipationRepository>();
    _myParticipationStream = repository.watchMyParticipation(
      reportId: widget.report.id,
      accountId: widget.accountId,
    );
    _participantsStream = repository.watchParticipations(widget.report.id);
  }

  Uri get _directionsUri {
    final report = widget.report;
    final query = report.hasLocation
        ? '${report.latitude},${report.longitude}'
        : report.address;
    return Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': query,
    });
  }

  Future<void> _goTo(BuildContext context) async {
    await context.read<ParticipationRepository>().goTo(
      reportId: widget.report.id,
      accountId: widget.accountId,
      accountName: widget.accountName,
      accountRole: widget.accountRole,
    );
    await widget.launchUrl(_directionsUri);
  }

  Future<void> _arrive(BuildContext context) async {
    final repository = context.read<ParticipationRepository>();
    await repository.arrive(
      reportId: widget.report.id,
      accountId: widget.accountId,
    );
    if (!context.mounted) return;
    final meetingPoint = await repository
        .watchMeetingPoint(widget.report.id)
        .first;
    if (meetingPoint == null && context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MeetingPointPickerScreen(
            reportId: widget.report.id,
            requesterId: widget.accountId,
            requesterRole: widget.accountRole,
          ),
        ),
      );
    }
  }

  Future<void> _requestAmbulance(BuildContext context) async {
    await context.read<ParticipationRepository>().requestAmbulance(
      reportId: widget.report.id,
      accountId: widget.accountId,
    );
    await widget.launchUrl(Uri(scheme: 'tel', path: '123'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.report.title)),
      body: StreamBuilder<Participation?>(
        stream: _myParticipationStream,
        builder: (context, mySnapshot) {
          final myParticipation = mySnapshot.data;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (myParticipation == null)
                ElevatedButton(
                  key: const Key('go-button'),
                  onPressed: () => _goTo(context),
                  child: const Text('Ir'),
                )
              else ...[
                if (myParticipation.status == ParticipationStatus.going)
                  ElevatedButton(
                    key: const Key('arrive-button'),
                    onPressed: () => _arrive(context),
                    child: const Text('Ya llegué'),
                  ),
                if (myParticipation.status != ParticipationStatus.finished) ...[
                  OutlinedButton(
                    key: const Key('ambulance-button'),
                    onPressed: () => _requestAmbulance(context),
                    child: const Text('Pedir ambulancia'),
                  ),
                  if (myParticipation.status == ParticipationStatus.arrived)
                    ElevatedButton(
                      key: const Key('finish-button'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FinishParticipationScreen(
                            reportId: widget.report.id,
                            accountId: widget.accountId,
                          ),
                        ),
                      ),
                      child: const Text('Finalizar mi participación'),
                    ),
                ],
              ],
              const SizedBox(height: 24),
              const Text(
                'Participantes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              StreamBuilder<List<Participation>>(
                stream: _participantsStream,
                builder: (context, snapshot) {
                  final participants = snapshot.data ?? const [];
                  if (participants.isEmpty) {
                    return const Text('Todavía nadie ha confirmado.');
                  }
                  return Column(
                    children: [
                      for (final participant in participants)
                        ListTile(
                          title: Text(participant.accountName),
                          subtitle: Text(
                            '${_roleLabels[participant.accountRole]} · ${_statusLabels[participant.status]}',
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
