class EmergencyType {
  final String id;
  final String label;

  const EmergencyType({required this.id, required this.label});
}

/// Catálogo cerrado de tipos de emergencia (spec.md, "Dudas abiertas").
/// Lista provisional — se ajusta cuando exista la lista oficial de la DCC.
const List<EmergencyType> kEmergencyTypeCatalog = [
  EmergencyType(id: 'incendio', label: 'Incendio'),
  EmergencyType(id: 'sismo_estructura_afectada', label: 'Sismo / estructura afectada'),
  EmergencyType(id: 'accidente_estructural', label: 'Accidente estructural'),
  EmergencyType(id: 'inundacion', label: 'Inundación'),
  EmergencyType(id: 'otro', label: 'Otro'),
];
