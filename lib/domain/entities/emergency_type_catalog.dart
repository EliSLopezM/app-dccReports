class EmergencyType {
  final String id;
  final String label;

  /// RF-4: recomendaciones de seguridad, texto provisional (ver
  /// plan.md de la spec 003 — se reemplaza con contenido oficial de la
  /// DCC cuando exista).
  final List<String> recommendations;

  const EmergencyType({
    required this.id,
    required this.label,
    required this.recommendations,
  });
}

/// Catálogo cerrado de tipos de emergencia (spec.md, "Dudas abiertas").
/// Lista provisional — se ajusta cuando exista la lista oficial de la DCC.
const List<EmergencyType> kEmergencyTypeCatalog = [
  EmergencyType(
    id: 'incendio',
    label: 'Incendio',
    recommendations: [
      'Aléjate del fuego y el humo.',
      'No uses ascensores.',
      'Cubre nariz y boca con un paño húmedo.',
      'Si tu ropa se incendia, detente, tírate al piso y rueda.',
    ],
  ),
  EmergencyType(
    id: 'sismo_estructura_afectada',
    label: 'Sismo / estructura afectada',
    recommendations: [
      'Aléjate de fachadas, ventanas y cables.',
      'Busca un lugar despejado o agáchate junto a un mueble bajo y resistente.',
      'No uses ascensores.',
      'Revisa si hay heridos antes de mover escombros.',
    ],
  ),
  EmergencyType(
    id: 'accidente_estructural',
    label: 'Accidente estructural',
    recommendations: [
      'No ingreses a la zona afectada.',
      'Mantén distancia de columnas o techos visiblemente dañados.',
      'Espera instrucciones del personal de la Defensa Civil en el lugar.',
    ],
  ),
  EmergencyType(
    id: 'inundacion',
    label: 'Inundación',
    recommendations: [
      'No cruces zonas con agua en movimiento.',
      'Corta la energía eléctrica si es seguro hacerlo.',
      'Aléjate de orillas de ríos o canales crecidos.',
    ],
  ),
  EmergencyType(
    id: 'otro',
    label: 'Otro',
    recommendations: [
      'Mantén distancia de la zona reportada.',
      'Espera instrucciones del personal de la Defensa Civil en el lugar.',
    ],
  ),
];
