import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'dart:io';

class classes {
  final List entities;

  classes({required this.entities});

  factory classes.fromJson(Map<String, dynamic> json) {
    return classes(entities: json['entities']);
  }
}

class Storage {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Future<void> uploadFile(
    String filePath,
    String fileName,
  ) async {
    File file = File(filePath);

    try{
      await storage.ref('uploads/$fileName').putFile(file);
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
  }

  Future<String> downloadURL(String imageName) async {
    String downloadURL = await storage.ref('uploads/$imageName').getDownloadURL();
    return downloadURL;
  }
}
