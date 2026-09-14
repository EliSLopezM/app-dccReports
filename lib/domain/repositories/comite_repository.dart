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
    double? latitude,
    double? longitude,
  });

  Stream<List<Comite>> watchAllComites();

  /// RF-3 (spec 005): comités con coordenadas conocidas a [radiusKm] o
  /// menos de ([latitude], [longitude]), ordenados por distancia.
  Stream<List<Comite>> watchNearbyComites({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  });

  Stream<Comite?> watchComite(String comiteId);

  /// RF-5: lanza [NotComiteLeaderException] si [requesterId] no es el
  /// `leaderId` del comité.
  Future<void> setDelegate({
    required String comiteId,
    required String requesterId,
    required String delegateId,
  });
}
