import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:vita_seniors/components/Lang.dart';
import 'package:vita_seniors/brain/RememberFuntions.dart';
import 'package:vita_seniors/components/Key.dart';

class Geminifuntions {
  final geminiModel = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: KeyStorageCustom.GEMINI_API_KEY,
  );
  final LangStrings langStrings = LangStrings();
  String lang = 'es-ES';

  Future<String> userFirstInteraction(String lang) async {
    String result = '';
    try {
      final content = [Content.text(LangStrings.hellowPrompt[lang]??'')];
      final response = await geminiModel.generateContent(content);
      result = response.text ?? '';
    } catch (e) {
      //print("Error is $e");
    }
    return result;
  }

  Future<String> userPromptDefault(String userSpeak, String lang) async {
    final rememberfuntions = Rememberfuntions();
    String result = '';
    try {
      final memories = await rememberfuntions.getMemoryForIA();
      final content = [
        Content.text(
            '${LangStrings.thisIsMemory[lang] ?? ''}$memories ${LangStrings.userSaid0[lang] ?? ''} $userSpeak ${LangStrings.userSaid2[lang] ?? ''}')
      ];
      final response = await geminiModel.generateContent(content);

      result = response.text ?? 'no texto de gemini';
      await rememberfuntions.setMemoryForIA(userSpeak, result);
    } catch (e) {
      //print("Error is $e");
    }
    return result;
  }

  Future<String> deciderGeminiPrompt(String prompt) async {
    String result = '';
    try {
      final content = [Content.text(prompt)];
      final response = await geminiModel.generateContent(content);

      result = response.text ?? 'no texto de gemini';
    } catch (e) {
      //print("Error is $e");
    }
    return result;
  }

  String searchOnGooglePrompt(lang) {
    if (lang == 'es-ES') {
      return """
        Hola Gemini voy a darte el texto crudo de una búsqueda en google, con esta información contesta la pregunta del usuario:
      """;
    } else if (lang == 'en-US') {
      return """
        Hi Gemini I will give you the raw text of a google search, with this information answer the user's question:
      """;
    }
    return '';
  }

  Future<String> formResponseFromHTML(
      String search, String userAsk, String lang) async {
    String result = '';
    try {
      final prompt = searchOnGooglePrompt(lang);
      final content = [Content.text('$prompt $search $userAsk')];
      final response = await geminiModel.generateContent(content);
      result = response.text ?? 'no texto de gemini';
    } catch (e) {
      //print("Error is $e");
    }
    return result;
  }

  String extractBestGoogleSearchPrompt(lang) {
    if (lang == 'es-ES') {
      return """
        Hola Gemini, voy a darte lo que el usuario me ha pedido, con esto debes formular lo que sería la busqueda más óptima para el usuario en Google, responde solo con la frase que buscarías para obtener la mejor respuesta:
      """;
    } else if (lang == 'en-US') {
      return """
        Hi Gemini, I am going to give you what the user has asked me, with this you should mock up what would be the most optimal search for the user on Google, just answer with the phrase you would search for to get the best answer:
      """;
    }
    return '';
  }

  Future<String> extractBestGoogleSearch(String userAsk) async {
    String result = '';
    try {
      final prompt = extractBestGoogleSearchPrompt(lang);
      final content = [Content.text('$prompt $userAsk')];
      final response = await geminiModel.generateContent(content);
      result = response.text ?? 'no texto de gemini';
    } catch (e) {
      //print("Error is $e");
    }
    return result;
  }

  String extractBestYoutubeSearchPrompt(lang) {
    if (lang == 'es-ES') {
      return """
        Hola Gemini, voy a darte lo que el usuario me ha pedido, con esto debes formular lo que sería la busqueda más óptima para el usuario en Youtube, responde solo con la frase que buscarías para obtener la mejor respuesta:
      """;
    } else if (lang == 'en-US') {
      return """
        Hi Gemini, I am going to give you what the user has asked me, with this you should mock up what would be the most optimal search for the user on Youtube, just answer with the phrase you would search for to get the best answer:
      """;
    }
    return '';
  }

  Future<String> extractBestYoutubeSearch(String userAsk) async {
    String result = '';
    try {
      final prompt = extractBestYoutubeSearchPrompt(lang);
      final content = [Content.text('$prompt $userAsk')];
      final response = await geminiModel.generateContent(content);
      result = response.text ?? 'no texto de gemini';
    } catch (e) {
      //print("Error is $e");
    }
    return result;
  }

  String memoriesResumePrompt(lang) {
    if (lang == 'es-ES') {
      return """
        Te voy a dar un historico en JSON de lo hablado con el usuario hasta ahora, necesito que me devuelvas un JSON resumido donde solo conserves lo fundamental para saber quien es el usuario y sus condiciones especiales, gustos. Responde solo con el JSON resumido
      """;
    } else if (lang == 'en-US') {
      return """
        I'm going to give you a JSON history of what I've talked to the user so far, I need you to give me back a summarized JSON where you only keep the basics to know who the user is and his special conditions, likes and dislikes. Reply only with the summarized JSON
      """;
    }
    return '';
  }

  Future<String> memoriesResume(String memories) async {
    String result = '';
    try {
      final prompt = memoriesResumePrompt(lang);
      final content = [Content.text('$prompt $memories')];
      final response = await geminiModel.generateContent(content);
      result = response.text ?? 'no texto de gemini';
    } catch (e) {
      //print("Error is $e");
    }
    return result;
  }
}
