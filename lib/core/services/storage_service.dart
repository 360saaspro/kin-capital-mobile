import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  StorageService._();
  static final instance = StorageService._();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadKycDocument(String uid, String filePath, String docType) async {
    final file = File(filePath);
    final ext = filePath.contains('.') ? path.extension(filePath) : '.jpg';
    final fileName = '${docType}_${DateTime.now().millisecondsSinceEpoch}$ext';
    final ref = _storage.ref().child('kyc/$uid/$fileName');
    
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
