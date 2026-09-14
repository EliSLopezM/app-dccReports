class Course {
  final String id;
  final String label;

  const Course({required this.id, required this.label});
}

/// Catálogo cerrado de cursos DCC (RF-2). Lista provisional — se ajusta
/// cuando exista la lista oficial (ver "Dudas abiertas" en spec.md).
const List<Course> kCourseCatalog = [
  Course(id: 'primeros_auxilios', label: 'Primeros auxilios'),
  Course(id: 'busqueda_rescate', label: 'Búsqueda y rescate'),
  Course(
    id: 'incendios_estructurales',
    label: 'Manejo de incendios estructurales',
  ),
  Course(id: 'rcp_basico', label: 'RCP básico'),
  Course(id: 'atencion_desastres', label: 'Atención y prevención de desastres'),
  Course(id: 'radiocomunicaciones', label: 'Radiocomunicaciones'),
];
