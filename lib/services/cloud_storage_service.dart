import 'dart:io';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CloudStorageService {
  static CloudStorageService instance = CloudStorageService();

  FirebaseStorage _storage;
  StorageReference _baseRef;
  String _messages = "messages";
  String _images = "images";
  String _profileImages = "profile_images";

  CloudStorageService() {
    _storage = FirebaseStorage.instance;
    _baseRef = _storage.ref();
  }

  Future uploadUserImage(String _uid, File _image) {
    try {
      return _baseRef
          .child(_profileImages)
          .child(_uid)
          .putFile(_image)
          .onComplete;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<StorageTaskSnapshot> uploadMediaMessage(String _uid, File _file) {
    var _timestamp = DateTime.now();
    var _fileName = basename(_file.path);

    _fileName += "${_timestamp.toString()}";
    try {
      return _baseRef
          .child(_messages)
          .child(_uid)
          .child(_images)
          .child(_fileName)
          .putFile(_file)
          .onComplete;
    }catch(e){
      print(e);
      return null;
    }
  }


}
