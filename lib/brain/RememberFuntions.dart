import 'package:shared_preferences/shared_preferences.dart';
import 'package:vita_seniors/components/Lang.dart';
import 'package:vita_seniors/brain/MemoryFunctions.dart';
import 'package:vita_seniors/brain/GeminiFunctions.dart';
import "package:googleapis_auth/auth_io.dart";
import 'package:googleapis/calendar/v3.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class Rememberfuntions {
  final LangStrings langStrings = LangStrings();
  String lang = 'es-ES';
  final memory = MemoryFunctions();
  final gemini = Geminifuntions();
  static final List<String> _scopes = [CalendarApi.calendarScope];
  final _credentials =
      new ClientId(dotenv.env['GOOGLE_OAUTH_KEY'] ?? 'NO API KEY', "");

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
    if (rememberList == '') {
      rememberList = '{"rememberList":[]}';
    }
    Map<String, dynamic> rememberListDefined = json.decode(rememberList);
    rememberListDefined =
        await cleanRememberListOldRemembers(rememberListDefined);
    //por seguridad comprobamos si los campos date, hour, description existen en data
    if (data.containsKey('date')) {
      String today = DateTime.now().toString().split(' ')[0];
      if (data['date'] == 'hoy' || data['date'] == 'today') {
        data['date'] = today;
      }
    }
    if (data.containsKey('hour')) {
      if (data['hour'] == 'now') {
        data['hour'] = DateTime.now().toString().split(' ')[1];
      }
    }
    if (data.containsKey('description')) {
      if (data['description'] == 'none') {
        data['description'] = '';
      }
    }
    createEvent(data);
    //añadimos el recordatorio a la lista
    rememberListDefined['rememberList'].add(data);
    //convertimos rememberListDefined a JSON para su guardado
    String rememberListJSON = json.encode(rememberListDefined);
    //guardamos el JSON en el archivo rememberList
    await memory.modifyFile('rememberList', rememberListJSON);
  }

  Future<String> getRememberList() async {
    String rememberList = await memory.readFile('rememberList');
    return rememberList;
  }

  Future<Map<String, dynamic>> cleanRememberListOldRemembers(
      Map<String, dynamic> RememberList) async {
    DateTime today = DateTime.now();
    for (int i = 0; i < RememberList['rememberList'].length; i++) {
      DateTime date = DateTime.parse(RememberList['rememberList'][i]['date']);
      if (date.isBefore(today)) {
        RememberList['rememberList'].removeAt(i);
      }
    }

    String rememberListJSON = json.encode(RememberList);
    await memory.modifyFile('rememberList', rememberListJSON);

    return RememberList;
  }

  Future<void> setToShopList(Map<String, dynamic> data) async {
    //primero leemos la lista de compras
    String shopList = await memory.readFile('shopList');
    Map<String, dynamic> shopListDefined = json.decode(shopList);
    //por seguridad comprobamos si los campos item y quantity existen
    if (data.containsKey('item') && data.containsKey('quantity')) {
      shopListDefined['shopList'].add(data);
    }
    //convertimos shopListDefined a JSON para su guardado
    String shopListJSON = json.encode(shopListDefined);
    //guardamos el JSON en el archivo shopList
    await memory.modifyFile('shopList', shopListJSON);
  }

  Future<String> getShopList() async {
    String shopList = await memory.readFile('shopList');
    return shopList;
  }

  Future<void> cleanToShopListOldItems() async {
    memory.modifyFile('shopList', '{"shopList":[]}');
  }

  Future<void> setMemoryForIA(String user, String assistant) async {
    String memoryTxt = await memory.readFile('memory');
    Map<String, dynamic> memoryDefined = json.decode(memoryTxt);
    memoryDefined['user'] = user;
    memoryDefined['assistant'] = assistant;
    String memoryJSON = json.encode(memoryDefined);
    String ResumeJSON = await gemini.memoriesResume(memoryJSON);
    await memory.modifyFile('memory', ResumeJSON);
  }

  Future<String> getMemoryForIA() async {
    String memoryTxt = await memory.readFile('memory');
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
}
