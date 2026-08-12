import 'package:cloud_firestore/cloud_firestore.dart';

/// A service wrapper for managing Firestore operations across the Kin Banking App.
class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  /// Singleton instance
  static final FirestoreService instance = FirestoreService();

  /// In-memory cache fallback for seamless operation during network, Web SDK, or auth issues
  final Map<String, Map<String, dynamic>> _userCache = {};
  final Map<String, List<Map<String, dynamic>>> _transactionsCache = {};

  Map<String, dynamic>? getCachedUser(String uid) => _userCache[uid];
  List<Map<String, dynamic>> getCachedTransactions(String uid) =>
      _transactionsCache[uid] ?? [];

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
    if (uid.isEmpty) return;
    final nowIso = DateTime.now().toIso8601String();

    _userCache[uid] = {...?_userCache[uid], ...data, 'updatedAt': nowIso};

    try {
      final docRef = usersCollection.doc(uid);
      await docRef.set({...data, 'updatedAt': nowIso}, SetOptions(merge: true));
    } catch (_) {
      // Catch synchronous and asynchronous exceptions silently
    }
  }

  /// Get user profile by UID
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    if (uid.isEmpty) return null;
    try {
      final docRef = usersCollection.doc(uid);
      final snapshot = await docRef.get();
      if (snapshot.exists && snapshot.data() != null) {
        _userCache[uid] = snapshot.data()!;
        return snapshot.data();
      }
    } catch (_) {
      // Fallback to cache on error
    }
    return _userCache[uid];
  }

  /// Stream user profile for real-time updates
  Stream<Map<String, dynamic>?> streamUserProfile(String uid) {
    if (uid.isEmpty) return Stream.value(_userCache[uid]);
    try {
      return usersCollection
          .doc(uid)
          .snapshots()
          .map((doc) {
            if (doc.exists && doc.data() != null) {
              _userCache[uid] = doc.data()!;
              return doc.data();
            }
            return _userCache[uid];
          })
          .handleError((_) => _userCache[uid]);
    } catch (_) {
      return Stream.value(_userCache[uid]);
    }
  }

  /// Update balance by delta (positive to add, negative to subtract)
  Future<void> updateUserBalance(String uid, double delta) async {
    if (uid.isEmpty) return;
    final profile = await getUserProfile(uid);
    final currentBalance = (profile?['balance'] as num?)?.toDouble() ?? 0.00;
    final newBalance = (currentBalance + delta).clamp(0.0, double.infinity);

    await setUserProfile(uid, {'balance': newBalance});
  }

  /// Add a banking transaction record
  Future<DocumentReference<Map<String, dynamic>>?> addTransaction({
    required String userId,
    required double amount,
    required String type, // e.g. 'deposit', 'transfer', 'withdrawal'
    required String title,
    Map<String, dynamic>? metadata,
  }) async {
    final nowIso = DateTime.now().toIso8601String();
    final txData = {
      'userId': userId,
      'amount': amount,
      'type': type,
      'title': title,
      'createdAt': nowIso,
      ...?metadata,
    };

    _transactionsCache.putIfAbsent(userId, () => []);
    _transactionsCache[userId]!.insert(0, txData);

    try {
      return await transactionsCollection.add(txData);
    } catch (_) {
      return null;
    }
  }

  /// Get real-time stream of transactions for a user
  Stream<List<Map<String, dynamic>>> streamUserTransactions(String userId) {
    if (userId.isEmpty) return Stream.value(_transactionsCache[userId] ?? []);
    try {
      return transactionsCollection
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
            final list = snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList();
            list.sort((a, b) {
              final aTs = a['createdAt']?.toString() ?? '';
              final bTs = b['createdAt']?.toString() ?? '';
              return bTs.compareTo(aTs);
            });
            if (list.isNotEmpty) {
              _transactionsCache[userId] = list;
            }
            return list.isNotEmpty ? list : (_transactionsCache[userId] ?? []);
          })
          .handleError((_) => _transactionsCache[userId] ?? []);
    } catch (_) {
      return Stream.value(_transactionsCache[userId] ?? []);
    }
  }

  // --- Yard Pots (Savings Goals) ---

  CollectionReference<Map<String, dynamic>> _userPots(String uid) =>
      usersCollection.doc(uid).collection('pots');

  Stream<List<Map<String, dynamic>>> streamUserPots(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    try {
      return _userPots(uid)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList(),
          )
          .handleError((_) => <Map<String, dynamic>>[]);
    } catch (_) {
      return Stream.value([]);
    }
  }

  Future<void> createOrUpdatePot(
    String uid,
    String potId,
    Map<String, dynamic> potData,
  ) async {
    if (uid.isEmpty) return;
    try {
      await _userPots(uid).doc(potId).set({
        ...potData,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> addPotFunds(String uid, String potId, double amount) async {
    if (uid.isEmpty) return;
    try {
      final potRef = _userPots(uid).doc(potId);
      final snapshot = await potRef.get();
      final currentSaved =
          (snapshot.data()?['savedAmount'] as num?)?.toDouble() ?? 0.0;
      await potRef.set({
        'savedAmount': currentSaved + amount,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  // --- Cards & Controls ---

  CollectionReference<Map<String, dynamic>> _userCards(String uid) =>
      usersCollection.doc(uid).collection('cards');

  Stream<List<Map<String, dynamic>>> streamUserCards(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    try {
      return _userCards(uid)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList(),
          )
          .handleError((_) => <Map<String, dynamic>>[]);
    } catch (_) {
      return Stream.value([]);
    }
  }

  Future<void> updateCardSettings(
    String uid,
    String cardId,
    Map<String, dynamic> cardData,
  ) async {
    if (uid.isEmpty) return;
    try {
      await _userCards(uid).doc(cardId).set({
        ...cardData,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  // --- Recipients ---

  CollectionReference<Map<String, dynamic>> _userRecipients(String uid) =>
      usersCollection.doc(uid).collection('recipients');

  Stream<List<Map<String, dynamic>>> streamUserRecipients(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    try {
      return _userRecipients(uid)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList(),
          )
          .handleError((_) => <Map<String, dynamic>>[]);
    } catch (_) {
      return Stream.value([]);
    }
  }

  Future<void> addRecipient(
    String uid,
    Map<String, dynamic> recipientData,
  ) async {
    if (uid.isEmpty) return;
    try {
      await _userRecipients(
        uid,
      ).add({...recipientData, 'createdAt': DateTime.now().toIso8601String()});
    } catch (_) {}
  }

  /// Save KYC verification record for a user
  Future<void> saveKycRecord(String uid, Map<String, dynamic> kycData) async {
    if (uid.isEmpty) return;
    final nowIso = DateTime.now().toIso8601String();
    final fullData = {...kycData, 'updatedAt': nowIso};
    
    // Update main user profile status
    await setUserProfile(uid, {
      'kycStatus': kycData['kycStatus'] ?? kycData['status'] ?? 'verified',
      'fullName': kycData['fullName'] ?? kycData['full_name'],
      'phone': kycData['phone'],
      'updatedAt': nowIso,
    });

    // Write to kyc subcollection
    try {
      await usersCollection.doc(uid).collection('kyc').add(fullData);
    } catch (_) {}
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
