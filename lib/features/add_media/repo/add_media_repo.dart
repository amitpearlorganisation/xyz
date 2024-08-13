import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:self_learning_app/utilities/constants.dart';
import 'dart:io';
import '../../../utilities/shared_pref.dart';
import 'package:http_parser/http_parser.dart';

class AddMediaRepo {
  static Future<String?> addQuickAddwithResources(
      {String? imagePath,
        required String title,
        required int contenttype}) async {
    print('quickadd');
    try {
      final token = await SharedPref().getToken();
      var request = http.MultipartRequest(
        "POST",
        Uri.parse('https://backend.savant.app/web/resource/quickAdd/'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      switch (contenttype) {
        case 0:
          {
            request.fields['type'] = 'QUICKADD-text';
          }
          break;
        case 1:
          {
            request.fields['type'] = 'QUICKADD-image';
          }
          break;
        case 2:
          {
            request.fields['type'] = 'QUICKADD-audio';
          }
          break;
        case 3:
          {
            request.fields['type'] = 'QUICKADD-video';
          }
      }
      request.fields['title'] = title;
      print(imagePath!.length);

      if (imagePath.isNotEmpty) {
        print('inide');
        var file = File(imagePath);
        var mimeType = lookupMimeType(file.path);
        request.files.add(http.MultipartFile.fromBytes(
          'content',
          await file.readAsBytes(),
          filename: file.path.split('/').last,
          contentType: MediaType.parse(mimeType!),
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print(response.body);
      print('response of quick add');
      return response.body;
    } catch (e) {
      print(e);
      print('erroeer');
      return null;
    }
  }

  static Future<String?> addPrompt({
    String? imagePath,
    required String resourcesId,
    required String name,
  }) async {
    //
    print('addpromt');
    try {
      final token = await SharedPref().getToken();
      var request = http.MultipartRequest(
        "POST",
        Uri.parse('https://backend.savant.app/web/prompt/'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['resourceId'] = resourcesId;
      request.fields['name'] = name;

      //     {
      //       "name":"Prompts with sides",
      //   "side1":"64b649384f06b00c437880d2",
      //   "side2":"64b6489f4f06b00c437880cf",
      //   "resourceId":"64a6635d357f6dcd51a83526"
      //
      // }

      if (imagePath != null) {
        var file = File(imagePath);
        var mimeType = lookupMimeType(file.path);

        request.files.add(http.MultipartFile(
          'content',
          file.openRead(),
          await file.length(),
          filename: file.path.split('/').last,
          contentType: MediaType.parse(mimeType!),
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);
      print(data);
      print('gg');
      return data[''];
    } catch (e) {
      print(e);
    }
  }
  static Future<String?> addResources(
      {String? imagePath,
        required String resourceId,
        String? title,
        required int mediaType}) async {
    print(resourceId);
    print('resource inside add reouse');
    print('add resources');
    String endPoint = "resource";
    String Url = DEVELOPMENT_BASE_URL+endPoint;
    final token = await SharedPref().getToken();
    var request = http.MultipartRequest(
      "POST",
      Uri.parse('$Url'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['rootId'] = resourceId;
    request.fields['title'] = title??"unititled";
    switch (mediaType) {
      case 0:
        {
          request.fields['type'] = 'text';
        }
        break;
      case 1:
        {
          request.fields['type'] = 'image';
        }
        break;
      case 2:
        {
          request.fields['type'] = 'audio';
        }
        break;
      case 3:
        {
          request.fields['type'] = 'video';
        }
    }
    print(imagePath!.isEmpty);
    print('imagePath');

    if (imagePath.isNotEmpty) {
      print('inside multitpart');
      var file = File(imagePath);
      var mimeType = lookupMimeType(file.path);
      print("what is mimetype $mimeType");
      request.files.add(http.MultipartFile.fromBytes(
        'content',
        await file.readAsBytes(),
        filename: file.path.split('/').last,
        contentType: MediaType.parse(mimeType!),
      ));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    print("check response ${response.body}");
    return response.body;
  }
// static Future<void> addResources({
//   String? imagePath,
//   required String resourceId,
//   String? title,
//   required int mediaType}) async {
//   try {
//     print("resource api ---");
//     print("Image path $imagePath");
//
//     // Ensure imagePath is not null
//     if (imagePath == null) {
//       print("Image path is null");
//       return;
//     }
//
//     var file = File(imagePath);
//     if (!await file.exists()) {
//       print("File does not exist at path: $imagePath");
//       return;
//     }
//
//     final token = await SharedPref().getToken();
//     if (token == null) {
//       print("Token is null");
//       return;
//     }
//
//     var request = http.MultipartRequest('POST', Uri.parse("http://18.224.28.180:8000/web/user/upload"));
//     request.headers.addAll({
//       'Authorization': 'Bearer $token',
//       'Content-Type': 'multipart/form-data',
//       'Accept': 'application/json',
//     });
//
//     request.files.add(await http.MultipartFile.fromPath('file', file.path));
//
//     var streamedResponse = await request.send();
//     var response = await http.Response.fromStream(streamedResponse);
//     print("Response status: ${response.statusCode}");
//     print("Response body: ${response.body}");
//
//     if (response.statusCode == 200) {
//       print("Upload successful");
//     } else {
//       print("Upload failed with status code: ${response.statusCode}");
//       // Handle error
//     }
//   } catch (e) {
//     print("An error occurred: $e");
//   }
// }

}