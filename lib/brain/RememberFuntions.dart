import 'package:shared_preferences/shared_preferences.dart';
import 'package:vita_seniors/components/Lang.dart';
import 'package:vita_seniors/brain/MemoryFunctions.dart';
import 'package:vita_seniors/brain/GeminiFunctions.dart';
import "package:googleapis_auth/auth_io.dart";
import 'package:googleapis/calendar/v3.dart';
import 'package:vita_seniors/components/Key.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class Rememberfuntions {
  final LangStrings langStrings = LangStrings();
  String lang = 'es-ES';
  final memory = MemoryFunctions();
  final gemini = Geminifuntions();
  static final List<String> _scopes = [CalendarApi.calendarScope];
  final _credentials = ClientId(KeyStorageCustom.GOOGLE_OAUTH_KEY, "");

  Future<bool> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString("language", language);
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<String> getLanguage() async {
    String language = 'en-US';
    final prefs = await SharedPreferences.getInstance();
    try {
      language = prefs.getString("language") ?? 'en-US';
    } catch (e) {
      return 'en-US';
    }
    return language;
  }

  Future<void> setToRememberList(Map<String, dynamic> data) async {
    //primero leemos la lista de recordatorios
    String rememberList = await memory.readFile('rememberList');

    if (rememberList == '' || rememberList == '{}') {
      rememberList = '{"rememberList":[]}';
    } else {
      rememberList = rememberList.substring(
          rememberList.indexOf('{'), rememberList.lastIndexOf('}') + 1);
    }
    Map<String, dynamic> rememberListDefined = json.decode(rememberList);
    //por seguridad comprobamos si los campos date, hour, description existen en data
    if (data.containsKey('date')) {
      String today = DateTime.now().toString().split(' ')[0];
      if (data['date'] == 'hoy' || data['date'] == 'today') {
        data['date'] = today;
      }
    } else {
      String today = DateTime.now().toString().split(' ')[0];
      data['date'] = today;
    }
    if (data.containsKey('hour')) {
      if (data['hour'] == 'now') {
        data['hour'] = DateTime.now().toString().split(' ')[1];
      }
    } else {
      data['hour'] = DateTime.now().toString().split(' ')[1];
    }
    if (data.containsKey('description')) {
      if (data['description'] == 'none') {
        data['description'] = '';
      }
    } else {
      data['description'] = jsonEncode(data);
    }
    //createEvent(data); quitamos el guardado en google maps debido a que hay que programar logica de inicio sesion google
    //añadimos el recordatorio a la lista
    if (rememberListDefined['rememberList'].isNotEmpty) {
      rememberListDefined['rememberList'].add(data);
    } else {
      // Handle empty list case, e.g., create a new list
      rememberListDefined['rememberList'] = [data];
    }
    //convertimos rememberListDefined a JSON para su guardado
    String rememberListJSON = json.encode(rememberListDefined);
    //guardamos el JSON en el archivo rememberList
    await memory.modifyFile('rememberList', rememberListJSON);
  }

  Future<String> getRememberList() async {
    String rememberList = await memory.readFile('rememberList');
    rememberList = rememberList.substring(
        rememberList.indexOf('{'), rememberList.lastIndexOf('}') + 1);
    return rememberList;
  }

  Future<Map<String, dynamic>> cleanRememberListOldRemembers(
      Map<String, dynamic> rememberList) async {
    DateTime today = DateTime.now();
    String rememberListJSON = '';
    if (rememberList['rememberList'] != null) {
      for (int i = 0; i < rememberList['rememberList'].length; i++) {
        DateTime date = DateTime.parse(rememberList['rememberList'][i]['date']);
        if (date.isBefore(today)) {
          rememberList['rememberList'].removeAt(i);
        }
      }
      rememberListJSON = json.encode(rememberList);
    } else {
      rememberListJSON = '{"rememberList":[]}';
    }

    await memory.modifyFile('rememberList', rememberListJSON);

    return rememberList;
  }

  Future<void> setToShopList(Map<String, dynamic> data) async {
    //primero leemos la lista de compras
    String shopList = await memory.readFile('shopList');
    if (shopList == '' || shopList == '{}') {
      shopList = '{"shopList":[]}';
    } else {
      shopList = shopList.substring(
          shopList.indexOf('{'), shopList.lastIndexOf('}') + 1);
    }
    Map<String, dynamic> shopListDefined = jsonDecode(shopList);
    //por seguridad comprobamos si los campos item y quantity existen
    if (data.containsKey('item') && data.containsKey('quantity')) {
      if (shopListDefined['shopList'].isNotEmpty) {
        shopListDefined['shopList'].add(data);
      } else {
        // Handle empty list case, e.g., create a new list
        shopListDefined['shopList'] = [data];
      }
    }
    //convertimos shopListDefined a JSON para su guardado
    String shopListJSON = json.encode(shopListDefined);
    //guardamos el JSON en el archivo shopList
    await memory.modifyFile('shopList', shopListJSON);
  }

  Future<String> getShopList() async {
    String shopList = await memory.readFile('shopList');
    shopList = shopList.substring(
        shopList.indexOf('{'), shopList.lastIndexOf('}') + 1);
    return shopList;
  }

  Future<void> cleanToShopListOldItems() async {
    memory.modifyFile('shopList', '{"shopList":[]}');
  }

  Future<void> setMemoryForIA(String user, String assistant) async {
    String memoryTxt = await memory.readFile('memory');
    memoryTxt = memoryTxt.substring(
        memoryTxt.indexOf('{'), memoryTxt.lastIndexOf('}') + 1);
    Map<String, dynamic> memoryDefined = json.decode(memoryTxt);
    memoryDefined['user'] = user;
    memoryDefined['assistant'] = assistant;
    String memoryJSON = json.encode(memoryDefined);
    String resumeJSON = await gemini.memoriesResume(memoryJSON);
    await memory.modifyFile('memory', resumeJSON);
  }

  Future<String> getMemoryForIA() async {
    String memoryTxt = await memory.readFile('memory');
    memoryTxt = memoryTxt.substring(
        memoryTxt.indexOf('{'), memoryTxt.lastIndexOf('}') + 1);
    return memoryTxt;
  }

  Future<void> createEvent(Map<String, dynamic> rememberList) async {
    final authClient =
        await clientViaUserConsent(_credentials, _scopes, prompt);
    final calendar = CalendarApi(authClient);

    //creamos evento en Google Calendar a partir de rememberList
    final event = Event();
    event.summary = rememberList['description'];
    event.start = EventDateTime(
        dateTime:
            DateTime.parse(rememberList['date'] + ' ' + rememberList['hour']));
    event.end = EventDateTime(
        dateTime:
            DateTime.parse(rememberList['date'] + ' ' + rememberList['hour']));

    await calendar.events.insert(event, "primary");
  }

  void prompt(String url) async {
    Uri urlPaser = Uri.parse(url);
    if (await canLaunchUrl(urlPaser)) {
      await launchUrl(urlPaser);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<bool> checkUserFirstInteraction() async {
    final prefs = await SharedPreferences.getInstance();
    bool userFirstInteraction = prefs.getBool('userFirstInteraction') ?? false;
    return userFirstInteraction;
  }

  Future<void> setFirstInteraction() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('userFirstInteraction', true);
  }
}
