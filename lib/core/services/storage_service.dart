import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService._();
  static final instance = StorageService._();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a KYC document or selfie to Firebase Storage and returns the public download URL.
  /// Target Path: kyc/{uid}/{docType}_{timestamp}.{ext}
  Future<String> uploadKycDocument(String uid, String filePath, String docType) async {
    if (filePath.isEmpty) {
      throw ArgumentError('File path cannot be empty');
    }

    // If already a remote URL, bypass upload
    if (filePath.startsWith('http://') || filePath.startsWith('https://')) {
      return filePath;
    }

    final file = File(filePath);
    if (!await file.exists()) {
      debugPrint('[StorageService] File not found at path: $filePath');
      throw FileSystemException('KYC file does not exist at path', filePath);
    }

    final ext = filePath.contains('.') ? '.${filePath.split('.').last}' : '.jpg';
    final isPng = ext.toLowerCase().contains('png');
    final fileName = '${docType}_${DateTime.now().millisecondsSinceEpoch}$ext';
    final storagePath = 'kyc/$uid/$fileName';
    final ref = _storage.ref().child(storagePath);

    final metadata = SettableMetadata(
      contentType: isPng ? 'image/png' : 'image/jpeg',
      customMetadata: {
        'docType': docType,
        'userId': uid,
        'uploadedAt': DateTime.now().toIso8601String(),
      },
    );

    debugPrint('[StorageService] Uploading $docType to $storagePath...');
    final taskSnapshot = await ref.putFile(file, metadata);
    final downloadUrl = await taskSnapshot.ref.getDownloadURL();
    debugPrint('[StorageService] Upload succeeded for $docType: $downloadUrl');
    return downloadUrl;
  }
}
