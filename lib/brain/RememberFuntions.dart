import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vita_seniors/components/Lang.dart';

class Rememberfuntions{
  final geminiModel = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: 'AIzaSyDKBKvr5rbMlYWdrwuP4NFmLHEFMnsq3PE',
  );
  FlutterTts flutterTts = FlutterTts();
  final LangStrings langStrings = LangStrings();
  String lang = 'es-ES';

  Future<Map<String, List<String>>> loadUserInformation() async{
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString("name");
    final sex = prefs.getString('sex');
    final age = prefs.getString('age');
    final birthDate = prefs.getString('birthDate');
    final height = prefs.getString('height');
    final weight = prefs.getString('weight');
    final bloodType = prefs.getString('bloodType');
    final allergies = prefs.getString('allergies');
    final medications = prefs.getString('medications');
    final notes = prefs.getString('notes');
    final canWalk = prefs.getString('canWalk');
    final canRun = prefs.getString('canRun');
    final canSwim = prefs.getString('canSwim');
    final useWalkingSteak = prefs.getString('useWalingSteak');

    List<String> thingsToAsk = [];
    List<String> UserData = [];
    Map<String, List<String>> returnData = {
      'userData' : UserData,
      'thingsToAsk' : thingsToAsk
    };
    if(name == null || name.isEmpty){
      thingsToAsk.add('name');
    }else{
      UserData.add(name);
    }
    if(sex==null || sex.isEmpty){
      thingsToAsk.add('sex');
    }else{
      UserData.add(sex);
    }
    if(age == null || age.isEmpty){
      thingsToAsk.add('age');
    }else{
      UserData.add(age);
    }
    if(birthDate == null || birthDate.isEmpty){
      thingsToAsk.add('birthDate');
    }else{
      UserData.add(birthDate);
    }
    if(height == null || height.isEmpty){
      thingsToAsk.add('height');
    }else{
      UserData.add(height);
    }
    if(weight == null || weight.isEmpty){
      thingsToAsk.add('weight');
    }else{
      UserData.add(weight);
    }
    if(bloodType == null || bloodType.isEmpty){
      thingsToAsk.add('bloodType');
    }else{
      UserData.add(bloodType);
    }
    if(allergies == null || allergies.isEmpty){
      thingsToAsk.add('allergies');
    }else{
      UserData.add(allergies);
    }
    if(medications == null || medications.isEmpty){
      thingsToAsk.add('medications');
    }else{
      UserData.add(medications);
    }
    if(notes == null || notes.isEmpty){
      thingsToAsk.add('notes');
    }else{
      UserData.add(notes);
    }
    if(canWalk == null || canWalk.isEmpty){
      thingsToAsk.add('canWalk');
    }else{
      UserData.add(canWalk);
    }
    if(canRun == null || canRun.isEmpty){
      thingsToAsk.add('canRun');
    }else{
      UserData.add(canRun);
    }
    if(canSwim == null || canSwim.isEmpty){
      thingsToAsk.add('canSwim');
    }else{
      UserData.add(canSwim);
    }
    if(useWalkingSteak == null || useWalkingSteak.isEmpty){
      thingsToAsk.add('useWalkingSteak');
    }else{
      UserData.add(useWalkingSteak);
    }
    if(name == null){
      returnData['toAsk'] = [''];
    }
    returnData['userData'] = UserData;
    returnData['thingsToAsk'] = thingsToAsk;
    return returnData;    
  }

  Future<void> configureTts() async {
    String ln = await getLanguage();
    lang = ln;
    await flutterTts.setLanguage(lang);
    await flutterTts.setSpeechRate(1.1);
    await flutterTts.setVolume(1.0);
  }

  Future<FlutterTts> speakText(String text) async {
    await flutterTts.speak(text);
    return flutterTts;
  }

  Future<bool> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    try{
      await prefs.setString("language", language);
    }catch(e){
      return false;
    }
    return true;
  }

  Future<String> getLanguage() async{
    String language = 'en-US';
    final prefs = await SharedPreferences.getInstance();
    try{
      language = prefs.getString("language") ?? 'en-US';
    }catch(e){
      return 'en-US';
    }
    return language;
  }

  void stopSpeaking() async {
    await flutterTts.stop();
  }

  Future<String> preparetToAsk() async{
    String result = '';
    try {
      lang = await getLanguage();
      final content = [Content.text(LangStrings.hellowPrompt[lang]??'')];
      final response = await geminiModel.generateContent(content);
      result = response.text ?? '';
    } catch (e) {
      print("Error is $e");
    }
    return result;
  }

  Future<String> userFirstInteraction(String userSpeak) async{
    String result = '';
    try {
      lang = await getLanguage();
      final content = [Content.text('${LangStrings.userSaid0[lang]??''} $userSpeak ${LangStrings.userSaid1[lang]??''}')];
      final response = await geminiModel.generateContent(content);

      result = response.text ?? 'no texto de gemini';
    } catch (e) {
      print("Error is $e");
    }
    return result;
  }

  Future<String> userPrompt(String userSpeak) async{
    String result = '';
    try {
      lang = await getLanguage();
      final content = [Content.text('${LangStrings.userSaid0[lang]??''} $userSpeak ${LangStrings.userSaid2[lang]??''}')];
      final response = await geminiModel.generateContent(content);

      result = response.text ?? 'no texto de gemini';
    } catch (e) {
      print("Error is $e");
    }
    return result;
  }
}