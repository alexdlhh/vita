import 'package:flutter/material.dart';
import 'package:vita_seniors/brain/RememberFuntions.dart';
import 'package:vita_seniors/brain/SpeakFunctions.dart';
import 'package:vita_seniors/brain/DeciderFunctions.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:vita_seniors/components/Lang.dart';
import 'package:vita_seniors/components/WebView.dart';
import 'package:vita_seniors/screens/Settings.dart';
import 'package:vita_seniors/screens/RememberInterface.dart';

class VoiceInterfacePage extends StatefulWidget {
  const VoiceInterfacePage({super.key});

  @override
  State<VoiceInterfacePage> createState() => _VoiceInterfacePageState();
}

class _VoiceInterfacePageState extends State<VoiceInterfacePage> {
  final rememberFuntions = Rememberfuntions();
  final speakFunctions = Speakfuntions();
  final deciderFunctions = DeciderFunctions();
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
    if (ln != lang) {
      setState(() {
        lang = ln;
      });
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
              height: MediaQuery.of(context).size.height,
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
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.56,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: LangStrings.typeAnithing[lang] ?? '',
                            labelStyle: const TextStyle(color: Colors.white),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese su nombre';
                            }
                            return null;
                          },
                          style: const TextStyle(color: Colors.white),
                          onChanged: (value) {
                            _lastWords = value;
                          },
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: ElevatedButton(
                            onPressed: fake,
                            child: Text(LangStrings.preguntar[lang] ?? '')),
                      )
                    ],
                  ),
                  Center(
                      child: Text(
                    _speechToText.isListening
                        ? _lastWords
                        : _speechEnabled
                            ? (listen
                                ? LangStrings.iCanHearYou[lang] ?? ''
                                : LangStrings.tapToTalk[lang] ?? '')
                            : LangStrings.iCantHearYou[lang] ?? '',
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
    //aqui comprobaremos si el usuario ha interaccionado ya, en caso de no haberlo hecho nos presentaremos
    //_startListening();
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
    Map<String, dynamic> response = await deciderFunctions.analizer(words);

    return response;
  }

  void _stopListening() async {
    await _speechToText.stop();

    if (_lastWords != '') {
      Map<String, dynamic> response = await analizerFunction(_lastWords);
      if (response["run"] == "gemini") {
        textToShow = response["response"];
        speakFunctions.speakText(response["response"]);
      }
      if (response["run"] == "youtube") {
        setState(() {
          textToShow = LangStrings.thereIsWhatIHaveFound[lang] ?? '';
          url = 'https://www.youtube.com/embed/${response["response"]}';
          playVideo = true;
          vitaImage = 'assets/images/closing_eyes.gif';
        });
      }
      if (response['run'] == 'music') {
        setState(() {
          textToShow = LangStrings.thereIsWhatIHaveFound[lang] ?? '';
          url = 'https://music.youtube.com/watch?v=${response["response"]}';
          vitaImage = 'assets/images/closing_eyes.gif';
          playVideo = true;
        });
      }
    }
    setState(() {
      _lastWords = '';
      listen = false;
      textToShow = textToShow;
      vitaImage = 'assets/images/closing_eyes.gif';
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    Future.delayed(const Duration(seconds: 3), () {
      if (_lastWords == result.recognizedWords) {
        _stopListening();
      }
      _detectUserStopSeggestion();
    });
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  void _detectUserStopSeggestion() {
    //buscamos en lo que oye el microfono y lo comparamos con lo que mandamos al tts, si la diferencia es, vita,para,si pero, etc.. entonces paramos el spech
    List<String> stopWords = [
      'Vita',
      'para',
      'stop',
      'lisen',
      'escocha',
      'si pero',
      'yes but',
      'perdona',
      'sorry but'
    ];
    //a partir de textToShow separamos todo por un espacio y comparamos parabra a palabra con _lastWords si alguna es diferente y ademas aparece en stopstring
    List<String> waitedWords = textToShow.split(' ');
    List<String> lisenWords = _lastWords.split(' ');
    for (int i = 0; i < waitedWords.length; i++) {
      if (waitedWords[i] != lisenWords[i] && stopWords.contains(_lastWords)) {
        speakFunctions.stopSpeaking();
        _startListening();
      }
    }
  }

  void fake() async {
    await _speechToText.stop();

    if (_lastWords != '') {
      Map<String, dynamic> response =
          await deciderFunctions.analizer(_lastWords);
      if (response["run"] == "gemini") {
        textToShow = response["response"];
        speakFunctions.speakText(response["response"]);
      }
      if (response["run"] == "youtube") {
        setState(() {
          textToShow = LangStrings.thereIsWhatIHaveFound[lang] ?? '';
          url = 'https://www.youtube.com/watch?v=${response["response"]}';
          playVideo = true;
        });
      }
      if (response['run'] == 'music') {
        setState(() {
          textToShow = LangStrings.thereIsWhatIHaveFound[lang] ?? '';
          url = 'https://music.youtube.com/watch?v=${response["response"]}';
          playVideo = true;
        });
      }
    }
    setState(() {
      _lastWords = '';
      listen = false;
      textToShow = textToShow;
    });
  }
}
