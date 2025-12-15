import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/models/kid.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _kidsRef(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('kids');
  }

  // ADD KID
  Future<String> addKid(String uid, Kid kid) async {
    final now = DateTime.now();

    final data = kid.toMap()
      ..removeWhere((key, value) => value == null)
      ..['createdAt'] = Timestamp.fromDate(now)
      ..['updatedAt'] = Timestamp.fromDate(now);

    final docRef = await _kidsRef(uid).add(data);
    return docRef.id;
  }

  // UPDATE KID
  Future<void> updateKid(String uid, Kid kid) async {
    final data = kid.toMap()
      ..removeWhere((key, value) => value == null)
      ..['updatedAt'] = Timestamp.fromDate(DateTime.now());

    await _kidsRef(uid).doc(kid.id).update(data);
  }

  // DELETE KID
  Future<void> deleteKid(String uid, String kidId) async {
    await _kidsRef(uid).doc(kidId).delete();
  }

  // STREAM KIDS
  Stream<List<Kid>> streamKids(String uid) {
    return _kidsRef(uid)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Kid.fromDoc(doc))
              .toList(),
        );
  }
}
