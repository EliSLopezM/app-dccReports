/// RF-1: grupo/comité fundado por un funcionario o líder funcionario.
class Comite {
  final String id;
  final String name;
  final String address;
  final String leaderId;

  /// RF-5: segundo al mando, null hasta que el líder lo asigne.
  final String? delegateId;

  final DateTime createdAt;

  const Comite({
    required this.id,
    required this.name,
    required this.address,
    required this.leaderId,
    this.delegateId,
    required this.createdAt,
  });
}
