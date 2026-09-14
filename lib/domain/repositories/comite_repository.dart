import '../entities/comite.dart';
import '../exceptions.dart';

/// RF-1, RF-5.
abstract class ComiteRepository {
  /// RF-1/RF-3: crea el comité y su chat de tipo comité en la misma
  /// operación. Devuelve el id del comité.
  Future<String> create({
    required String name,
    required String address,
    required String leaderId,
  });

  Stream<List<Comite>> watchAllComites();

  Stream<Comite?> watchComite(String comiteId);

  /// RF-5: lanza [NotComiteLeaderException] si [requesterId] no es el
  /// `leaderId` del comité.
  Future<void> setDelegate({
    required String comiteId,
    required String requesterId,
    required String delegateId,
  });
}
