import 'chat_kind.dart';

class Chat {
  final String id;
  final String name;
  final ChatKind kind;
  final List<String> memberIds;

  /// Solo para [ChatKind.comite]: comité del que nace este chat (RF-3).
  final String? comiteId;

  /// Solo para [ChatKind.custom]: funcionario que lo creó (RF-7/RF-8/RF-9).
  final String? createdBy;

  final DateTime createdAt;

  Chat({
    required this.id,
    required this.name,
    required this.kind,
    this.memberIds = const [],
    this.comiteId,
    this.createdBy,
    required this.createdAt,
  }) : assert(
         (kind == ChatKind.comite) == (comiteId != null),
         'comiteId solo se define para chats de tipo comite',
       ),
       assert(
         (kind == ChatKind.custom) == (createdBy != null),
         'createdBy solo se define para chats de tipo custom',
       );
}
