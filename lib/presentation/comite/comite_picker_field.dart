import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/comite.dart';
import '../../domain/repositories/comite_repository.dart';

/// RF-2: selector de comité existente para voluntario/líder. Si no hay
/// ninguno todavía, se puede continuar sin elegir uno.
class ComitePickerField extends StatelessWidget {
  const ComitePickerField({super.key, required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Comite>>(
      stream: context.read<ComiteRepository>().watchAllComites(),
      builder: (context, snapshot) {
        final comites = snapshot.data ?? const [];
        if (comites.isEmpty) {
          return const Text(
            'Todavía no hay comités creados — puedes registrarte sin elegir uno.',
            key: Key('no-comites-message'),
          );
        }
        return DropdownButtonFormField<String?>(
          key: const Key('comite-dropdown'),
          initialValue: value,
          decoration: const InputDecoration(labelText: 'Tu comité (opcional)'),
          items: [
            const DropdownMenuItem(value: null, child: Text('Sin comité por ahora')),
            for (final comite in comites)
              DropdownMenuItem(value: comite.id, child: Text(comite.name)),
          ],
          onChanged: onChanged,
        );
      },
    );
  }
}
