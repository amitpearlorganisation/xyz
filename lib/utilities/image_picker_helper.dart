import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

/*
class ImagePickerHelper {
  static Future<XFile?> pickImage({required ImageSource imageSource}) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: imageSource);
      return image;
    } catch (e) {
      print('${e} ======> error while pick image');
    }
  }


  static Future<XFile?> pickVideo({required ImageSource imageSource}) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickVideo(source: imageSource);
      return image;
    } catch (e) {
      print('${e} ======> error while pick video');
    }
  }

  static Future<String?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
         print("We press the audio section");
    if (result != null) {
      PlatformFile file = result.files.first;
      return file.path!;
    } else {
      // User canceled the file picker
      return null;
    }
  }
}
*/


class ImagePickerHelper {
  static Future<XFile?> pickImage({required ImageSource imageSource}) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: imageSource);
      return image;
    } catch (e) {
      print('${e} ======> error while pick image');
      return null;
    }
  }

  static Future<XFile?> pickVideo({required ImageSource imageSource}) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? video = await picker.pickVideo(source: imageSource);
      return video;
    } catch (e) {
      print('${e} ======> error while pick video');
      return null;
    }
  }

  static Future<String?> pickFile() async {
    print("################### this is audio file chooose ");
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,

    );
    print("We press the audio section");
    if (result != null) {
      PlatformFile file = result.files.first;
      return file.path!;
    } else {
      // User canceled the file picker
      return null;
    }
  }
}
