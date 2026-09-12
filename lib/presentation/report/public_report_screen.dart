import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../data/device/device_id_provider.dart';
import '../../domain/entities/emergency_type_catalog.dart';
import '../../domain/exceptions.dart';
import '../../domain/repositories/emergency_report_repository.dart';
import '../../domain/repositories/location_repository.dart';

typedef PickImage = Future<String?> Function(ImageSource source);

Future<String?> defaultPickImage(ImageSource source) async {
  final file = await ImagePicker().pickImage(source: source);
  return file?.path;
}

const _minPhotos = 2;

/// RF-1: alcanzable sin sesión — no depende de AuthRepository.
class PublicReportScreen extends StatefulWidget {
  const PublicReportScreen({
    super.key,
    this.pickImage = defaultPickImage,
    DeviceIdProvider? deviceIdProvider,
    // ignore: prefer_initializing_formals
  }) : _deviceIdProvider = deviceIdProvider;

  final PickImage pickImage;
  final DeviceIdProvider? _deviceIdProvider;

  @override
  State<PublicReportScreen> createState() => _PublicReportScreenState();
}

class _PublicReportScreenState extends State<PublicReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _reporterNameController = TextEditingController();
  final _reporterPhoneController = TextEditingController();

  String _emergencyTypeId = kEmergencyTypeCatalog.first.id;
  final List<String> _photoPaths = [];
  bool _submitting = false;
  String? _errorMessage;
  bool _submitted = false;

  late final DeviceIdProvider _deviceIdProvider = widget._deviceIdProvider ?? DeviceIdProvider();

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _reporterNameController.dispose();
    _reporterPhoneController.dispose();
    super.dispose();
  }

  Future<void> _addPhoto(ImageSource source) async {
    final path = await widget.pickImage(source);
    if (path != null) setState(() => _photoPaths.add(path));
  }

  Future<void> _pickPhotoSource() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.of(context).pop();
                _addPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de la galería'),
              onTap: () {
                Navigator.of(context).pop();
                _addPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    if (_photoPaths.length < _minPhotos) {
      setState(() => _errorMessage = 'Se requieren mínimo $_minPhotos fotos.');
      return;
    }

    final repository = context.read<EmergencyReportRepository>();
    final locationRepository = context.read<LocationRepository>();

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final deviceId = await _deviceIdProvider.getOrCreate();
      // RF-13/RF-14: la ubicación es best-effort — null nunca bloquea el envío.
      final location = await locationRepository.getCurrentLocation();
      await repository.submit(
            title: _titleController.text.trim(),
            address: _addressController.text.trim(),
            emergencyTypeId: _emergencyTypeId,
            localPhotoPaths: _photoPaths,
            reporterName:
                _reporterNameController.text.trim().isEmpty ? null : _reporterNameController.text.trim(),
            reporterPhone: _reporterPhoneController.text.trim().isEmpty
                ? null
                : _reporterPhoneController.text.trim(),
            deviceId: deviceId,
            latitude: location?.latitude,
            longitude: location?.longitude,
          );
      if (mounted) setState(() => _submitted = true);
    } on InvalidReportException catch (e) {
      setState(() => _errorMessage = e.message);
    } on SpamLimitExceededException {
      setState(() => _errorMessage = 'Ya enviaste varios reportes recientemente. Intenta más tarde.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reportar emergencia')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Gracias. Tu reporte fue enviado y será revisado por la Defensa Civil.',
              key: Key('report-submitted-message'),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Reportar emergencia')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título del reporte'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Ingresa un título' : null,
            ),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Dirección'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Ingresa la dirección' : null,
            ),
            DropdownButtonFormField<String>(
              key: const Key('emergency-type-dropdown'),
              initialValue: _emergencyTypeId,
              decoration: const InputDecoration(labelText: 'Tipo de emergencia'),
              items: [
                for (final type in kEmergencyTypeCatalog)
                  DropdownMenuItem(value: type.id, child: Text(type.label)),
              ],
              onChanged: (id) => setState(() => _emergencyTypeId = id ?? _emergencyTypeId),
            ),
            const SizedBox(height: 16),
            Text('Fotos (mínimo $_minPhotos)', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('${_photoPaths.length} foto(s) agregada(s)', key: const Key('photo-count')),
            TextButton.icon(
              onPressed: _pickPhotoSource,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Agregar foto'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reporterNameController,
              decoration: const InputDecoration(labelText: 'Tu nombre (opcional)'),
            ),
            TextFormField(
              controller: _reporterPhoneController,
              decoration: const InputDecoration(labelText: 'Tu teléfono de contacto (opcional)'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                key: const Key('report-error'),
                style: const TextStyle(color: Colors.red),
              ),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: Text(_submitting ? 'Enviando...' : 'Enviar reporte'),
            ),
          ],
        ),
      ),
    );
  }
}
