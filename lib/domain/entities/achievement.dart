class Achievement {
  final String id;
  final String label;
  final String description;

  const Achievement({required this.id, required this.label, required this.description});
}

/// Catálogo cerrado de insignias (spec.md, "Dudas abiertas"). Lista
/// provisional — se ajusta cuando la DCC defina la suya.
const List<Achievement> kAchievementCatalog = [
  Achievement(
    id: 'primeros_pasos',
    label: 'Primeros pasos',
    description: 'Participaste en tu primera emergencia.',
  ),
  Achievement(
    id: 'comprometido',
    label: 'Comprometido',
    description: 'Participaste en 5 emergencias.',
  ),
  Achievement(
    id: 'veterano',
    label: 'Veterano',
    description: 'Participaste en 20 emergencias.',
  ),
  Achievement(
    id: 'cien_horas',
    label: '100 horas de servicio',
    description: 'Acumulaste 100 horas de servicio en emergencias.',
  ),
];
