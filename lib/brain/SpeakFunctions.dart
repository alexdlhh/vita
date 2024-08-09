import 'package:flutter_tts/flutter_tts.dart';
import 'package:vita_seniors/components/Lang.dart';
import 'package:vita_seniors/brain/RememberFuntions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Speakfuntions {
  FlutterTts flutterTts = FlutterTts();
  final LangStrings langStrings = LangStrings();
  String lang = 'es-ES';
  final rememberfuntions = Rememberfuntions();

  Future<void> configureTts() async {
    String ln = await rememberfuntions.getLanguage();
    lang = ln;
    await flutterTts.setLanguage(lang);
    await flutterTts.setSpeechRate(1.1);
    await flutterTts.setVolume(1.0);
  }

  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString("language", language);
    } catch (e) {
      return;
    }
  }

  //get Voices
  Future<List<dynamic>> getVoices() async {
    List<dynamic> voices = await flutterTts.getVoices;
    List<dynamic> voicesAux = [];
    //recorremos voices, el elemento voice es como {name: cmn-tw-x-cte-network, locale: zh-TW}, solo nos qiedamos es- y en-
    for (int i = 0; i < voices.length; i++) {
      if (voices[i]['locale'].contains(lang)) {
        voicesAux.add(voices[i]);
      }
    }
    return voicesAux;
  }

  //set voice
  Future<void> setVoice(Map<String, String> voice) async {
    await flutterTts.setVoice(voice);
  }

  //get actual voice
  Future<Map<String, String>> getVoice() async {
    Map<String, String> voice = await flutterTts.getDefaultVoice;
    return voice;
  }

  Future<FlutterTts> speakText(String text) async {
    await flutterTts.speak(text);
    return flutterTts;
  }

  //play selected voice to test
  Future<void> playSelectedVoice(Map<Object?, Object?> voice) async {
    Map<String, String> voiceAux = {
      'name': voice['name'] as String,
      'locale': voice['locale'] as String                                     
    };
    await flutterTts.setVoice(voiceAux);
    await flutterTts.speak(LangStrings.testingVoice[lang] ?? '');
  }

  void stopSpeaking() async {
    await flutterTts.stop();
  }
}
