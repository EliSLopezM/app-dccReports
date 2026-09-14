import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/difficulty_level.dart';
import '../../domain/repositories/participation_repository.dart';

typedef PickImage = Future<String?> Function(ImageSource source);

Future<String?> defaultPickImage(ImageSource source) async {
  final file = await ImagePicker().pickImage(source: source);
  return file?.path;
}

const _difficultyLabels = {
  DifficultyLevel.baja: 'Baja',
  DifficultyLevel.media: 'Media',
  DifficultyLevel.alta: 'Alta',
};

/// RF-10/RF-11: "Ya terminé" (foto + nivel) o "Debo retirarme" (razón +
/// nivel).
class FinishParticipationScreen extends StatefulWidget {
  const FinishParticipationScreen({
    super.key,
    required this.reportId,
    required this.accountId,
    this.pickImage = defaultPickImage,
  });

  final String reportId;
  final String accountId;
  final PickImage pickImage;

  @override
  State<FinishParticipationScreen> createState() =>
      _FinishParticipationScreenState();
}

enum _FinishMode { completed, withdrawn }

class _FinishParticipationScreenState extends State<FinishParticipationScreen> {
  _FinishMode _mode = _FinishMode.completed;
  DifficultyLevel _difficultyLevel = DifficultyLevel.media;
  final _reasonController = TextEditingController();
  String? _photoPath;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final path = await widget.pickImage(ImageSource.camera);
    if (path != null) setState(() => _photoPath = path);
  }

  Future<void> _submit() async {
    final repository = context.read<ParticipationRepository>();
    if (_mode == _FinishMode.completed && _photoPath == null) {
      setState(() => _errorMessage = 'Agrega una foto para terminar.');
      return;
    }
    if (_mode == _FinishMode.withdrawn &&
        _reasonController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Escribe la razón de tu retiro.');
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    if (_mode == _FinishMode.completed) {
      await repository.finishCompleted(
        reportId: widget.reportId,
        accountId: widget.accountId,
        localPhotoPath: _photoPath!,
        difficultyLevel: _difficultyLevel,
      );
    } else {
      await repository.finishWithdrawn(
        reportId: widget.reportId,
        accountId: widget.accountId,
        reason: _reasonController.text.trim(),
        difficultyLevel: _difficultyLevel,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar mi participación')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<_FinishMode>(
            key: const Key('finish-mode-selector'),
            segments: const [
              ButtonSegment(
                value: _FinishMode.completed,
                label: Text('Ya terminé'),
              ),
              ButtonSegment(
                value: _FinishMode.withdrawn,
                label: Text('Debo retirarme'),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (selection) =>
                setState(() => _mode = selection.first),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<DifficultyLevel>(
            key: const Key('difficulty-dropdown'),
            initialValue: _difficultyLevel,
            decoration: const InputDecoration(labelText: 'Nivel de dificultad'),
            items: [
              for (final level in DifficultyLevel.values)
                DropdownMenuItem(
                  value: level,
                  child: Text(_difficultyLabels[level]!),
                ),
            ],
            onChanged: (level) =>
                setState(() => _difficultyLevel = level ?? _difficultyLevel),
          ),
          const SizedBox(height: 16),
          if (_mode == _FinishMode.completed) ...[
            Text(
              _photoPath == null ? 'Sin foto todavía' : 'Foto lista',
              key: const Key('photo-status'),
            ),
            TextButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Agregar foto'),
            ),
          ] else
            TextFormField(
              key: const Key('reason-field'),
              controller: _reasonController,
              decoration: const InputDecoration(labelText: 'Razón del retiro'),
              maxLines: 3,
            ),
          const SizedBox(height: 24),
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              key: const Key('finish-error'),
              style: const TextStyle(color: Colors.red),
            ),
          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: Text(_submitting ? 'Enviando...' : 'Confirmar'),
          ),
        ],
      ),
    );
  }
}
