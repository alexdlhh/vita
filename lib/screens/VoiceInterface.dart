import 'package:flutter/material.dart';
import 'package:vita_seniors/brain/GeminiFunctions.dart';
import 'package:vita_seniors/brain/RememberFuntions.dart';
import 'package:vita_seniors/brain/SpeakFunctions.dart';
import 'package:vita_seniors/brain/DeciderFunctions.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:vita_seniors/components/Lang.dart';
import 'package:vita_seniors/components/WebView.dart';
import 'package:vita_seniors/screens/Settings.dart';
import 'package:vita_seniors/screens/RememberInterface.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceInterfacePage extends StatefulWidget {
  const VoiceInterfacePage({super.key});

  @override
  State<VoiceInterfacePage> createState() => _VoiceInterfacePageState();
}

class _VoiceInterfacePageState extends State<VoiceInterfacePage> {
  final rememberFuntions = Rememberfuntions();
  final speakFunctions = Speakfuntions();
  final deciderFunctions = DeciderFunctions();
  final geminifuntions = Geminifuntions();
  String textToShow = '';
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  final LangStrings langStrings = LangStrings();
  String lang = 'en-US';
  bool listen = false;
  bool userFisrtInteraction = false;
  bool sendToIA = true;
  bool playVideo = false;
  String vitaImage = 'assets/images/closing_eyes.gif';
  String url = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
    init();
  }

  void init() async {
    String ln = await rememberFuntions.getLanguage();
    await requestPermission();
    if (ln != lang) {
      setState(() {
        lang = ln;
      });
    }
  }

  Future<void> requestPermission() async {
    final permission = Permission.contacts;

    if (await permission.isDenied) {
      await permission.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(85, 83, 202, 1),
        title: Center(
            child: Text(
          LangStrings.voiceInterface[lang] ?? '',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        )),
        actions: [
          PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                    PopupMenuItem(
                      value: LangStrings.settings[lang] ?? '',
                      onTap: () {
                        //abrimos settingPage()
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SettingsPage()));
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.settings),
                          const SizedBox(width: 8),
                          Text(LangStrings.settings[lang] ?? ''),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: LangStrings.memory[lang] ?? '',
                      onTap: () {
                        //abrimos settingPage()
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RememberPage()));
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.memory),
                          const SizedBox(width: 8),
                          Text(LangStrings.memory[lang] ?? ''),
                        ],
                      ),
                    ),
                  ]),
        ],
      ),
      body: SingleChildScrollView(
          child: Container(
              height: MediaQuery.of(context).size.height*1.4,
              color: const Color.fromRGBO(85, 83, 202, 1),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50, // Ajusta el radio según el tamaño deseado
                      backgroundImage: AssetImage(vitaImage),
                    ),
                  ),
                  Center(
                    child: _speechToText.isNotListening?
                        Text(LangStrings.iCanHearYou[lang]??'',style: TextStyle(color: Colors.white),):
                        Text(LangStrings.tapToTalk[lang]??'',style: TextStyle(color: Colors.white),)
                  ),
                  Center(
                      child: Text(_lastWords ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 208, 207, 207),
                        ),
                      )),
                  playVideo
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        playVideo = false;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                              Text(url),
                              WebViewBox(
                                url: url,
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: Text(textToShow,
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
                ]),
              ))),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(36, 35, 84, 1),
        onPressed:
            _speechToText.isNotListening ? _startListening : _stopListening,
        tooltip: LangStrings.listen[lang] ?? '',
        child: Icon(
          _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
          color: Colors.white,
        ),
      ),
    );
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    _startListening();
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      listen = true;
      textToShow = '';
      vitaImage = 'assets/images/escribiendo.gif';
    });
  }

  Future<Map<String, dynamic>> analizerFunction(String words) async {
    setState(() {
      vitaImage = 'assets/images/searching.gif';
    });
    Map<String, dynamic> response = await deciderFunctions.analizer(words,textToShow);
    print(response);
    return response;
  }

  void _stopListening() async {
    await _speechToText.stop();

    if (_lastWords != '') {
      Map<String, dynamic> response = await analizerFunction(_lastWords);
      if (response["run"] == "gemini") {
        textToShow = response["response"];
        listen = false;
        setState(() {
          _lastWords = '';
          listen = false;
          textToShow = textToShow;
          vitaImage = 'assets/images/closing_eyes.gif';
        });
      }
      if (response["run"] == "youtube") {
        setState(() {
          textToShow = LangStrings.thereIsWhatIHaveFound[lang] ?? '';
          url = 'https://www.youtube.com/embed/${response["response"]}';
          playVideo = true;
          vitaImage = 'assets/images/closing_eyes.gif';
          listen = false;
        });
      }
      if (response['run'] == 'music') {
        setState(() {
          textToShow = LangStrings.thereIsWhatIHaveFound[lang] ?? '';
          url = 'https://music.youtube.com/watch?v=${response["response"]}';
          vitaImage = 'assets/images/closing_eyes.gif';
          playVideo = true;
          listen = false;
        });
      }
      speakFunctions.speakText(textToShow);
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
    if (result.finalResult) {
      Future.delayed(const Duration(seconds: 3), () {
        if (result.finalResult) {
          print('LLAMAMOS A GEMINI DESDE FUTURE DELAYED');
          _stopListening();
        }
      });
    }
  }

  void _detectUserStopSeggestion() {
    // Dividir el texto a mostrar y las últimas palabras en listas
    List<String> wordsToShow = textToShow.split(' ');
    List<String> listenedWords = _lastWords.split(' ');

    // Crear un conjunto para una búsqueda más rápida
    Set<String> stopWordsSet = {
      'Vita',
      'para',
      'stop',
      'lisen',
      'escucha',
      'pero',
      'but',
      'perdona',
      'sorry',
      'no',
      'yes',
      'detente',
      'calla',
      'wait',
      'espera',
      'second',
      'momento'
    }; // Agregar el resto de las palabras

    // Comparar las últimas palabras con las palabras de parada
    // Priorizar palabras de parada al final de la frase
    int stoppedTimes = 0;
    for (int i = listenedWords.length - 1; i >= 0; i--) {
      if (stopWordsSet.contains(listenedWords[i].toLowerCase())) {
        /*speakFunctions.stopSpeaking();
        _startListening();*/
        stoppedTimes++;
        print('veces que hemos querido parar $stoppedTimes');
        return; // Detener la búsqueda si se encuentra una palabra de parada
      }
    }
  }
}
