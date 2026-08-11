import 'package:cloud_firestore/cloud_firestore.dart';

/// A service wrapper for managing Firestore operations across the Kin Banking App.
class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// Singleton instance
  static final FirestoreService instance = FirestoreService();

  /// Reference to Firestore instance
  FirebaseFirestore get db => _db;

  // Collection References
  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get accountsCollection =>
      _db.collection('accounts');

  CollectionReference<Map<String, dynamic>> get transactionsCollection =>
      _db.collection('transactions');

  // --- Document Operations ---

  /// Save or update user profile data in Firestore
  Future<void> setUserProfile(String uid, Map<String, dynamic> data) async {
    await usersCollection.doc(uid).set(
          {
            ...data,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
  }

  /// Get user profile by UID
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final snapshot = await usersCollection.doc(uid).get();
    return snapshot.data();
  }

  /// Stream user profile for real-time updates
  Stream<Map<String, dynamic>?> streamUserProfile(String uid) {
    return usersCollection.doc(uid).snapshots().map((doc) => doc.data());
  }

  /// Add a banking transaction record
  Future<DocumentReference<Map<String, dynamic>>> addTransaction({
    required String userId,
    required double amount,
    required String type, // e.g. 'deposit', 'transfer', 'withdrawal'
    required String title,
    Map<String, dynamic>? metadata,
  }) async {
    return await transactionsCollection.add({
      'userId': userId,
      'amount': amount,
      'type': type,
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
      ...?metadata,
    });
  }

  /// Get real-time stream of transactions for a user
  Stream<List<Map<String, dynamic>>> streamUserTransactions(String userId) {
    return transactionsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  /// Utility health check method to test connection to Firestore
  Future<bool> checkConnection() async {
    try {
      final doc = await _db.collection('_health_check').doc('ping').get();
      return doc.exists || !doc.exists;
    } catch (_) {
      return false;
    }
  }
}
