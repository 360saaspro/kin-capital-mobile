import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A service wrapper for managing Firestore operations across the Kin Banking App.
class FirestoreService {
  final FirebaseFirestore? _customDb;

  FirestoreService({FirebaseFirestore? firestore})
    : _customDb = firestore;

  /// Singleton instance
  static final FirestoreService instance = FirestoreService();

  /// In-memory cache fallback for seamless operation during network, Web SDK, or auth issues
  final Map<String, Map<String, dynamic>> _userCache = {};
  final Map<String, List<Map<String, dynamic>>> _transactionsCache = {};
  final Map<String, List<Map<String, dynamic>>> _potsCache = {};
  final Map<String, StreamController<List<Map<String, dynamic>>>> _potsControllers = {};
  final Map<String, List<Map<String, dynamic>>> _potContributorsCache = {};
  final Map<String, List<Map<String, dynamic>>> _potActivitiesCache = {};
  final Map<String, List<Map<String, dynamic>>> _notificationsCache = {};

  Map<String, dynamic>? getCachedUser(String uid) => _userCache[uid];
  List<Map<String, dynamic>> getCachedTransactions(String uid) =>
      _transactionsCache[uid] ?? [];
  List<Map<String, dynamic>> getCachedPots(String uid) => _potsCache[uid] ?? [];
  List<Map<String, dynamic>> getCachedPotContributors(String uid, String potId) =>
      _potContributorsCache['${uid}_$potId'] ?? [];
  List<Map<String, dynamic>> getCachedPotActivities(String uid, String potId) =>
      _potActivitiesCache['${uid}_$potId'] ?? [];
  List<Map<String, dynamic>> getCachedNotifications(String uid) => 
      _notificationsCache[uid] ?? [];

  /// Reference to Firestore instance
  FirebaseFirestore? get db {
    if (_customDb != null) return _customDb;
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseFirestore.instance;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Collection References
  CollectionReference<Map<String, dynamic>>? get usersCollection {
    try {
      return db?.collection('users');
    } catch (_) {
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? get accountsCollection {
    try {
      return db?.collection('accounts');
    } catch (_) {
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? get transactionsCollection {
    try {
      return db?.collection('transactions');
    } catch (_) {
      return null;
    }
  }

  // --- Document Operations ---

  /// Save or update user profile data in Firestore
  Future<void> setUserProfile(String uid, Map<String, dynamic> data) async {
    if (uid.isEmpty) return;
    final nowIso = DateTime.now().toIso8601String();

    _userCache[uid] = {...?_userCache[uid], ...data, 'updatedAt': nowIso};

    try {
      final col = usersCollection;
      if (col != null) {
        final docRef = col.doc(uid);
        await docRef.set({...data, 'updatedAt': nowIso}, SetOptions(merge: true));
      }
    } catch (_) {
      // Catch synchronous and asynchronous exceptions silently
    }
  }

  /// Get user profile by UID
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    if (uid.isEmpty) return null;
    try {
      final col = usersCollection;
      if (col != null) {
        final docRef = col.doc(uid);
        final snapshot = await docRef.get();
        if (snapshot.exists && snapshot.data() != null) {
          _userCache[uid] = snapshot.data()!;
          return snapshot.data();
        }
      }
    } catch (_) {
      // Fallback to cache on error
    }
    return _userCache[uid];
  }

  /// Update the user's credit profile (e.g., after an API assessment)
  Future<void> updateCreditProfile(String uid, Map<String, dynamic> creditData) async {
    if (uid.isEmpty) return;
    try {
      await setUserProfile(uid, {
        'creditProfile': creditData,
      });
    } catch (_) {}
  }

  /// Stream user profile for real-time updates
  Stream<Map<String, dynamic>?> streamUserProfile(String uid) {
    if (uid.isEmpty) return Stream.value(_userCache[uid]);
    final col = usersCollection;
    if (col == null) return Stream.value(_userCache[uid]);
    try {
      return col
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
      final col = transactionsCollection;
      if (col != null) {
        return await col.add(txData);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Get real-time stream of transactions for a user
  Stream<List<Map<String, dynamic>>> streamUserTransactions(String userId) {
    if (userId.isEmpty) return Stream.value(_transactionsCache[userId] ?? []);
    final col = transactionsCollection;
    if (col == null) return Stream.value(_transactionsCache[userId] ?? []);
    try {
      return col
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

  CollectionReference<Map<String, dynamic>>? _userPots(String uid) =>
      usersCollection?.doc(uid).collection('pots');

  Stream<List<Map<String, dynamic>>> streamUserPots(String uid) {
    if (uid.isEmpty) return Stream.value(_potsCache[uid] ?? []);

    if (!_potsControllers.containsKey(uid) || _potsControllers[uid]!.isClosed) {
      _potsControllers[uid] = StreamController<List<Map<String, dynamic>>>.broadcast();
    }

    try {
      final potsRef = _userPots(uid);
      if (potsRef != null) {
        potsRef.snapshots().listen((snapshot) {
          final list = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
          if (list.isNotEmpty || _potsCache[uid] == null) {
            _potsCache[uid] = list;
          }
          if (_potsControllers.containsKey(uid) && !_potsControllers[uid]!.isClosed) {
            _potsControllers[uid]!.add(_potsCache[uid] ?? []);
          }
        }, onError: (_) {
          if (_potsControllers.containsKey(uid) && !_potsControllers[uid]!.isClosed) {
            _potsControllers[uid]!.add(_potsCache[uid] ?? []);
          }
        });
      }
    } catch (_) {}

    Future.microtask(() {
      if (_potsControllers.containsKey(uid) && !_potsControllers[uid]!.isClosed) {
        _potsControllers[uid]!.add(_potsCache[uid] ?? []);
      }
    });

    return _potsControllers[uid]!.stream;
  }

  Future<void> createOrUpdatePot(
    String uid,
    String potId,
    Map<String, dynamic> potData,
  ) async {
    if (uid.isEmpty) return;
    final nowIso = DateTime.now().toIso8601String();
    final data = {
      'id': potId,
      ...potData,
      'updatedAt': nowIso,
    };

    _potsCache.putIfAbsent(uid, () => []);
    final existingIndex = _potsCache[uid]!.indexWhere((p) => p['id'] == potId);
    if (existingIndex >= 0) {
      _potsCache[uid]![existingIndex] = data;
    } else {
      _potsCache[uid]!.insert(0, data);
    }

    if (_potsControllers.containsKey(uid) && !_potsControllers[uid]!.isClosed) {
      _potsControllers[uid]!.add(_potsCache[uid]!);
    }

    try {
      final potsRef = _userPots(uid);
      if (potsRef != null) {
        await potsRef.doc(potId).set(data, SetOptions(merge: true));
      }
    } catch (_) {}
  }

  Future<void> addPotFunds(String uid, String potId, double amount) async {
    if (uid.isEmpty) return;
    _potsCache.putIfAbsent(uid, () => []);
    final existingIndex = _potsCache[uid]!.indexWhere((p) => p['id'] == potId);
    if (existingIndex >= 0) {
      final currentSaved =
          (_potsCache[uid]![existingIndex]['savedAmount'] as num?)?.toDouble() ?? 0.0;
      _potsCache[uid]![existingIndex]['savedAmount'] = currentSaved + amount;
      _potsCache[uid]![existingIndex]['updatedAt'] = DateTime.now().toIso8601String();
      if (_potsControllers.containsKey(uid) && !_potsControllers[uid]!.isClosed) {
        _potsControllers[uid]!.add(_potsCache[uid]!);
      }
    }

    try {
      final potsRef = _userPots(uid);
      if (potsRef != null) {
        final potRef = potsRef.doc(potId);
        final snapshot = await potRef.get();
        final currentSaved =
            (snapshot.data()?['savedAmount'] as num?)?.toDouble() ?? 0.0;
        await potRef.set({
          'savedAmount': currentSaved + amount,
          'updatedAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
      }
    } catch (_) {}

    // Record activity record for this pot
    await addPotActivity(uid, potId, {
      'type': 'Deposit',
      'title': 'Fund Contribution',
      'amount': amount,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // --- Pot Contributors & Activities ---

  CollectionReference<Map<String, dynamic>>? _potContributors(String uid, String potId) =>
      _userPots(uid)?.doc(potId).collection('contributors');

  CollectionReference<Map<String, dynamic>>? _potActivities(String uid, String potId) =>
      _userPots(uid)?.doc(potId).collection('activities');

  Stream<List<Map<String, dynamic>>> streamPotContributors(String uid, String potId) {
    final cacheKey = '${uid}_$potId';
    if (uid.isEmpty || potId.isEmpty) {
      return Stream.value(_potContributorsCache[cacheKey] ?? []);
    }
    final ref = _potContributors(uid, potId);
    if (ref == null) {
      return Stream.value(_potContributorsCache[cacheKey] ?? []);
    }
    try {
      return ref
          .snapshots()
          .map((snapshot) {
            final list = snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList();
            if (list.isNotEmpty) {
              _potContributorsCache[cacheKey] = list;
            }
            return list.isNotEmpty ? list : (_potContributorsCache[cacheKey] ?? []);
          })
          .handleError((_) => _potContributorsCache[cacheKey] ?? []);
    } catch (_) {
      return Stream.value(_potContributorsCache[cacheKey] ?? []);
    }
  }

  Future<void> addPotContributor(
    String uid,
    String potId,
    Map<String, dynamic> contributorData,
  ) async {
    if (uid.isEmpty || potId.isEmpty) return;
    final cacheKey = '${uid}_$potId';
    final nowIso = DateTime.now().toIso8601String();
    final data = {
      ...contributorData,
      'createdAt': nowIso,
    };

    _potContributorsCache.putIfAbsent(cacheKey, () => []);
    _potContributorsCache[cacheKey]!.add(data);

    try {
      final ref = _potContributors(uid, potId);
      if (ref != null) {
        await ref.add(data);
      }
    } catch (_) {}
  }

  Stream<List<Map<String, dynamic>>> streamPotActivities(String uid, String potId) {
    final cacheKey = '${uid}_$potId';
    if (uid.isEmpty || potId.isEmpty) {
      return Stream.value(_potActivitiesCache[cacheKey] ?? []);
    }
    final ref = _potActivities(uid, potId);
    if (ref == null) {
      return Stream.value(_potActivitiesCache[cacheKey] ?? []);
    }
    try {
      return ref
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
              _potActivitiesCache[cacheKey] = list;
            }
            return list.isNotEmpty ? list : (_potActivitiesCache[cacheKey] ?? []);
          })
          .handleError((_) => _potActivitiesCache[cacheKey] ?? []);
    } catch (_) {
      return Stream.value(_potActivitiesCache[cacheKey] ?? []);
    }
  }

  Future<void> addPotActivity(
    String uid,
    String potId,
    Map<String, dynamic> activityData,
  ) async {
    if (uid.isEmpty || potId.isEmpty) return;
    final cacheKey = '${uid}_$potId';
    final nowIso = DateTime.now().toIso8601String();
    final data = {
      ...activityData,
      'createdAt': activityData['createdAt'] ?? nowIso,
    };

    _potActivitiesCache.putIfAbsent(cacheKey, () => []);
    _potActivitiesCache[cacheKey]!.insert(0, data);

    try {
      final ref = _potActivities(uid, potId);
      if (ref != null) {
        await ref.add(data);
      }
    } catch (_) {}
  }

  // --- Cards & Controls ---

  CollectionReference<Map<String, dynamic>>? _userCards(String uid) =>
      usersCollection?.doc(uid).collection('cards');

  Stream<List<Map<String, dynamic>>> streamUserCards(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    final ref = _userCards(uid);
    if (ref == null) return Stream.value([]);
    try {
      return ref
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
      final ref = _userCards(uid);
      if (ref != null) {
        await ref.doc(cardId).set({
          ...cardData,
          'updatedAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
      }
    } catch (_) {}
  }

  // --- Recipients ---

  CollectionReference<Map<String, dynamic>>? _userRecipients(String uid) =>
      usersCollection?.doc(uid).collection('recipients');

  Stream<List<Map<String, dynamic>>> streamUserRecipients(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    final ref = _userRecipients(uid);
    if (ref == null) return Stream.value([]);
    try {
      return ref
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
      final ref = _userRecipients(uid);
      if (ref != null) {
        await ref.add({...recipientData, 'createdAt': DateTime.now().toIso8601String()});
      }
    } catch (_) {}
  }

  /// Save KYC verification record for a user
  Future<void> saveKycRecord(String uid, Map<String, dynamic> kycData) async {
    if (uid.isEmpty) return;
    final nowIso = DateTime.now().toIso8601String();
    final fullData = {...kycData, 'updatedAt': nowIso};
    
    // Update main user profile status
    await setUserProfile(uid, {
      'uid': uid,
      'role': kycData['role'] ?? 'user',
      'accountType': kycData['accountType'] ?? 'personal',
      'tier': kycData['tier'] ?? 'standard',
      'kycStatus': kycData['kycStatus'] ?? kycData['status'] ?? 'verified',
      if (kycData['fullName'] != null || kycData['full_name'] != null)
        'fullName': kycData['fullName'] ?? kycData['full_name'],
      if (kycData['email'] != null) 'email': kycData['email'],
      if (kycData['phone'] != null) 'phone': kycData['phone'],
      if (kycData['address'] != null) 'address': kycData['address'],
      if (kycData['street'] != null) 'street': kycData['street'],
      if (kycData['city'] != null) 'city': kycData['city'],
      if (kycData['country'] != null) 'country': kycData['country'],
      if (kycData['residenceDuration'] != null || kycData['residence_duration'] != null)
        'residenceDuration': kycData['residenceDuration'] ?? kycData['residence_duration'],
      if (kycData['dateOfBirth'] != null || kycData['date_of_birth'] != null)
        'dateOfBirth': kycData['dateOfBirth'] ?? kycData['date_of_birth'],
      if (kycData['countryOfResidence'] != null || kycData['country_of_residence'] != null)
        'countryOfResidence': kycData['countryOfResidence'] ?? kycData['country_of_residence'],
      if (kycData['nationality'] != null) 'nationality': kycData['nationality'],
      if (kycData['employmentStatus'] != null || kycData['employment_status'] != null)
        'employmentStatus': kycData['employmentStatus'] ?? kycData['employment_status'],
      if (kycData['industry'] != null) 'industry': kycData['industry'],
      if (kycData['monthlyIncome'] != null || kycData['monthly_income'] != null)
        'monthlyIncome': kycData['monthlyIncome'] ?? kycData['monthly_income'],
      if (kycData['identityType'] != null || kycData['identity_type'] != null)
        'identityType': kycData['identityType'] ?? kycData['identity_type'],
      if (kycData['identityNumber'] != null || kycData['identity_number'] != null)
        'identityNumber': kycData['identityNumber'] ?? kycData['identity_number'],
      'updatedAt': nowIso,
    });

    // Write to kyc subcollection
    try {
      final ref = usersCollection?.doc(uid).collection('kyc');
      if (ref != null) {
        await ref.add(fullData);
      }
    } catch (_) {}
  }

  // --- Notifications ---

  CollectionReference<Map<String, dynamic>>? _userNotifications(String uid) =>
      usersCollection?.doc(uid).collection('notifications');

  Stream<List<Map<String, dynamic>>> streamUserNotifications(String uid) {
    if (uid.isEmpty) return Stream.value(_notificationsCache[uid] ?? []);
    final ref = _userNotifications(uid);
    if (ref == null) return Stream.value(_notificationsCache[uid] ?? []);
    try {
      return ref
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
              _notificationsCache[uid] = list;
            }
            return list.isNotEmpty ? list : (_notificationsCache[uid] ?? []);
          })
          .handleError((_) => _notificationsCache[uid] ?? []);
    } catch (_) {
      return Stream.value(_notificationsCache[uid] ?? []);
    }
  }

  Future<void> addNotification(String uid, Map<String, dynamic> notificationData) async {
    if (uid.isEmpty) return;
    try {
      final ref = _userNotifications(uid);
      if (ref != null) {
        await ref.add({
          ...notificationData,
          'createdAt': DateTime.now().toIso8601String(),
          'isRead': false,
        });
      }
    } catch (_) {}
  }

  Future<void> markNotificationAsRead(String uid, String notificationId) async {
    if (uid.isEmpty || notificationId.isEmpty) return;
    try {
      final ref = _userNotifications(uid);
      if (ref != null) {
        await ref.doc(notificationId).set({
          'isRead': true,
          'updatedAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
      }
    } catch (_) {}
  }

  // --- Support Chats ---

  CollectionReference<Map<String, dynamic>>? get supportChatsCollection =>
      db?.collection('support_chats');

  Stream<List<Map<String, dynamic>>> streamSupportChats() {
    final col = supportChatsCollection;
    if (col == null) return Stream.value([]);
    try {
      return col.orderBy('updatedAt', descending: true).snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    } catch (_) {
      return Stream.value([]);
    }
  }

  Stream<List<Map<String, dynamic>>> streamSupportMessages(String chatId) {
    if (chatId.isEmpty) return Stream.value([]);
    final col = supportChatsCollection;
    if (col == null) return Stream.value([]);
    try {
      return col.doc(chatId).collection('messages')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    } catch (_) {
      return Stream.value([]);
    }
  }

  Future<void> sendSupportMessage(String chatId, String senderId, String text) async {
    final col = supportChatsCollection;
    if (col == null) return;
    try {
      final now = DateTime.now().toIso8601String();
      await col.doc(chatId).set({
        'updatedAt': now,
        'userId': chatId, // For user chats, the document ID is their uid
      }, SetOptions(merge: true));

      await col.doc(chatId).collection('messages').add({
        'senderId': senderId,
        'text': text,
        'createdAt': now,
        'isRead': false,
      });
    } catch (_) {}
  }

  /// Utility health check method to test connection to Firestore
  Future<bool> checkConnection() async {
    try {
      final firestore = db;
      if (firestore == null) return false;
      final doc = await firestore.collection('_health_check').doc('ping').get();
      return doc.exists || !doc.exists;
    } catch (_) {
      return false;
    }
  }
}
