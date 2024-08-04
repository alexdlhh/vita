import 'package:flutter_tts/flutter_tts.dart';
import 'package:vita_seniors/components/Lang.dart';
import 'package:vita_seniors/brain/RememberFuntions.dart';

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

  Future<FlutterTts> speakText(String text) async {
    await flutterTts.speak(text);
    return flutterTts;
  }

  void stopSpeaking() async {
    await flutterTts.stop();
  }
}
