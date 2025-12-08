import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/models/kid.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // user subcollection path: /users/{uid}/kids
  CollectionReference<Map<String, dynamic>> _kidsRef(String uid) {
    return _db.collection('users').doc(uid).collection('kids');
  }

  Future<String> addKid(String uid, Kid kid) async {
    final col = _kidsRef(uid);
    final now = DateTime.now();
    final data = kid.copyWith().toMap()
      ..removeWhere((key, value) => value == null)
      ..['createdAt'] = Timestamp.fromDate(now)
      ..['updatedAt'] = Timestamp.fromDate(now);
    final docRef = await col.add(data);
    return docRef.id;
  }

  Future<void> updateKid(String uid, Kid kid) async {
    final col = _kidsRef(uid);
    final data = kid.toMap();
    data['updatedAt'] = Timestamp.fromDate(DateTime.now());
    await col.doc(kid.id).update(data);
  }

  Future<void> deleteKid(String uid, String kidId) async {
    await _kidsRef(uid).doc(kidId).delete();
  }

  Stream<List<Kid>> streamKids(String uid) {
    return _kidsRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Kid.fromDoc(d)).toList());
  }

  Future<Kid?> getKid(String uid, String kidId) async {
    final doc = await _kidsRef(uid).doc(kidId).get();
    if (!doc.exists) return null;
    return Kid.fromDoc(doc as DocumentSnapshot<Map<String, dynamic>>);
  }
}
