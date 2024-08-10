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
    await flutterTts.setSpeechRate(0.8);
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
    print(voices);
    List<dynamic> voicesAux = [];
    //recorremos voices, el elemento voice es como {name: cmn-tw-x-cte-network, locale: zh-TW}, solo nos qiedamos es- y en-
    for (int i = 0; i < voices.length; i++) {
      if (voices[i]['locale'].contains(lang) ||
          voices[i]['locale'].contains('spa') ||
          voices[i]['locale'].contains('eng')) {
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

  String clearSpeech(String texto) {
    // Expresión regular para eliminar etiquetas HTML
    final regexEtiquetas = RegExp(r'<[^>]*>');
    // Expresión regular para eliminar URL's
    final regexUrls = RegExp(r'https?://\S+');
    // Expresión regular para eliminar emojis (aproximación básica)
    final RegExp REGEX_EMOJI = RegExp(
        r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])');
    // Eliminar etiquetas, URL's y emojis, preservando espacios
    String textoLimpio = texto
        .replaceAll(regexEtiquetas, ' ')
        .replaceAll(regexUrls, '')
        .replaceAll(REGEX_EMOJI, '')
        .trim();

    texto.replaceAll('*', '');

    // Eliminar caracteres especiales restantes (si es necesario)
    // final caracteresEspeciales = RegExp(r'[^\w\s,.!?]'); // Ya está cubierto en regexEmojis

    return textoLimpio;
  }

  Future<FlutterTts> speakText(String text) async {
    text = clearSpeech(text);
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
