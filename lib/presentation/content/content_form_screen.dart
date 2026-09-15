import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/account_role.dart';
import '../../domain/entities/content_kind.dart';
import '../../domain/entities/content_post.dart';
import '../../domain/repositories/content_repository.dart';

typedef PickImage = Future<String?> Function(ImageSource source);

Future<String?> defaultPickImage(ImageSource source) async {
  final file = await ImagePicker().pickImage(source: source);
  return file?.path;
}

/// RF-3/RF-4: crear o editar una publicación. Solo se navega aquí desde
/// `ContentListScreen` cuando `viewerRole.canManageContent`.
class ContentFormScreen extends StatefulWidget {
  const ContentFormScreen({
    super.key,
    required this.kind,
    required this.authorId,
    required this.authorRole,
    this.post,
    this.pickImage = defaultPickImage,
  });

  final ContentKind kind;
  final String authorId;
  final AccountRole authorRole;
  final ContentPost? post;
  final PickImage pickImage;

  @override
  State<ContentFormScreen> createState() => _ContentFormScreenState();
}

class _ContentFormScreenState extends State<ContentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(text: widget.post?.title);
  late final _bodyController = TextEditingController(text: widget.post?.body);

  String? _newPhotoPath;
  bool _photoRemoved = false;
  bool _submitting = false;

  bool get _isEditing => widget.post != null;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final path = await widget.pickImage(ImageSource.gallery);
    if (path != null) {
      setState(() {
        _newPhotoPath = path;
        _photoRemoved = false;
      });
    }
  }

  void _removePhoto() {
    setState(() {
      _newPhotoPath = null;
      _photoRemoved = true;
    });
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() => _submitting = true);
    final repository = context.read<ContentRepository>();
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (_isEditing) {
      await repository.update(
        postId: widget.post!.id,
        authorRole: widget.authorRole,
        title: title,
        body: body,
        localPhotoPath: _newPhotoPath,
        removePhoto: _photoRemoved,
      );
    } else {
      await repository.create(
        kind: widget.kind,
        authorId: widget.authorId,
        authorRole: widget.authorRole,
        title: title,
        body: body,
        localPhotoPath: _newPhotoPath,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final hasExistingPhoto = widget.post?.photoUrl != null && !_photoRemoved;
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar publicación' : 'Nueva publicación')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('content-form-title'),
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Ingresa un título' : null,
            ),
            TextFormField(
              key: const Key('content-form-body'),
              controller: _bodyController,
              decoration: const InputDecoration(labelText: 'Cuerpo'),
              maxLines: 6,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Ingresa el contenido' : null,
            ),
            const SizedBox(height: 16),
            if (_newPhotoPath != null)
              Text('Nueva foto seleccionada', key: const Key('content-form-new-photo'))
            else if (hasExistingPhoto)
              Text('Foto actual', key: const Key('content-form-existing-photo'))
            else
              const Text('Sin foto'),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _pickPhoto,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Elegir foto'),
                ),
                if (_newPhotoPath != null || hasExistingPhoto)
                  TextButton(
                    key: const Key('content-form-remove-photo'),
                    onPressed: _removePhoto,
                    child: const Text('Quitar foto'),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              key: const Key('content-form-submit'),
              onPressed: _submitting ? null : _submit,
              child: Text(_isEditing ? 'Guardar cambios' : 'Publicar'),
            ),
          ],
        ),
      ),
    );
  }
}
