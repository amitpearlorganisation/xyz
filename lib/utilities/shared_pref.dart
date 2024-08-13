import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static late SharedPreferences _preferences;

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  String tokenkey = "token";

  Future<void> saveToken(String getToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(tokenkey, getToken);
  }
  Future<void> saveUserId(String userId) async {
    _preferences.setString("userId", userId);

  }


  Future<void> savesubcateId(String subcatid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('subcatid', subcatid);
  }

  Future<void> savesubcate1Id(String savesubcate1Id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('subcate1id', savesubcate1Id);
  }

  Future<void> savesubcate2Id(String savesubcate2Id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('subcate2id', savesubcate2Id);
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(tokenkey);
    return token;
  }


  Future<void> clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  Future<String?> getsubcateid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('subcatid');
    return token;
  }

  Future<String?> getsubcate1id() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('subcate1id');
    return token;
  }

  Future<String?> getsubcate2id() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('subcate2id');
    return token;
  }

  Future<void> sClear() async{
    _preferences.remove(tokenkey);
    _preferences.remove("userId");
    _preferences.clear();

  }

}

