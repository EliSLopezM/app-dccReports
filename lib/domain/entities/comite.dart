/// RF-1: grupo/comité fundado por un funcionario o líder funcionario.
class Comite {
  final String id;
  final String name;
  final String address;
  final String leaderId;

  /// RF-5: segundo al mando, null hasta que el líder lo asigne.
  final String? delegateId;

  final DateTime createdAt;

  /// RF-13/RF-14 (Enmienda 1, motivada por la spec 005): null si no se
  /// pudo capturar la ubicación al fundar el comité — no cuenta para
  /// cercanía hasta que se agregue por otro medio.
  final double? latitude;
  final double? longitude;

  bool get hasLocation => latitude != null && longitude != null;

  const Comite({
    required this.id,
    required this.name,
    required this.address,
    required this.leaderId,
    this.delegateId,
    required this.createdAt,
    this.latitude,
    this.longitude,
  });
}
