import 'package:http/http.dart' as http;

class SubcategoryRepo {
  static Future<void> getResources(String rootId) async {
    final response = await http
        .get(Uri.parse('https://backend.savant.app/web/resource/'));
    print(response);
  }
}
