import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/comite.dart';

const comitesCollection = 'comites';

Map<String, dynamic> newComiteToFirestore({
  required String name,
  required String address,
  required String leaderId,
}) {
  return {
    'name': name,
    'address': address,
    'leaderId': leaderId,
    'delegateId': null,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

Comite comiteFromFirestore(String id, Map<String, dynamic> data) {
  return Comite(
    id: id,
    name: data['name'] as String,
    address: data['address'] as String,
    leaderId: data['leaderId'] as String,
    delegateId: data['delegateId'] as String?,
    createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}
