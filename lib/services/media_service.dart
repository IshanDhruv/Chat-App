import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MediaService{

  static MediaService instance = MediaService();

  Future getImageFromLibrary(){
    return ImagePicker.pickImage(source: ImageSource.gallery);
  }
}