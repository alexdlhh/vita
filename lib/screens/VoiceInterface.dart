import 'package:flutter/material.dart';
import 'package:vita_seniors/brain/RememberFuntions.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:vita_seniors/components/Lang.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceInterfacePage extends StatefulWidget{
  const VoiceInterfacePage({super.key});

  @override
  State<VoiceInterfacePage> createState() => _VoiceInterfacePageState();
}

class _VoiceInterfacePageState extends State<VoiceInterfacePage>{
  final String yourApiKey = 'AIzaSyDKBKvr5rbMlYWdrwuP4NFmLHEFMnsq3PE';
  final rememberFuntions = Rememberfuntions();
  String textToShow = '';
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  final LangStrings langStrings = LangStrings();
  String lang = 'en-US';
  bool listen = false;
  bool userFisrtInteraction = false;

  @override
  void initState(){
    super.initState();
    _initSpeech();
    init();
  }

  void init() async{
    String ln = await rememberFuntions.getLanguage();    
    Map<String, List<String>> txt = await rememberFuntions.loadUserInformation();
    if(txt['toAsk']!=null && txt['toAsk']!.isNotEmpty){
      textToShow = await rememberFuntions.preparetToAsk();
      FlutterTts flutterTts = await rememberFuntions.speakText(textToShow);    
      int wordCount = textToShow.split(' ').length;
      int secs = (wordCount * 0.47).toInt()-1;
      await flutterTts.awaitSpeakCompletion(true).whenComplete(() async {
        Future.delayed(Duration(seconds: secs), () {
          _startListening();      
        });  
      });
      userFisrtInteraction = true;
    }
    setState(() {
      textToShow = textToShow;
      lang = ln;
      userFisrtInteraction = userFisrtInteraction;
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(85, 83, 202, 1),
        title: Center(child: Text(LangStrings.voiceInterface[lang]??'',style:const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: const Color.fromRGBO(85, 83, 202, 1),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Center(
                  child: Text(
                    _speechToText.isListening
                        ? _lastWords
                        : _speechEnabled
                            ? (listen?LangStrings.iCanHearYou[lang]??'':LangStrings.tapToTalk[lang]??'')
                            : LangStrings.iCantHearYou[lang]??'',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 208, 207, 207),
                    ),
                  )),
                Center(
                  child: Text(textToShow,
                    style:const TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.bold))),
            ]),
          )
        )
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(36, 35, 84, 1),
          onPressed:
              _speechToText.isNotListening ? _startListening : _stopListening,
          tooltip: LangStrings.listen[lang]??'',
          child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic,color: Colors.white,),
        ),
      );
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      listen = true;
      textToShow = '';
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    
    if(userFisrtInteraction){
      String response = await rememberFuntions.userFirstInteraction(_lastWords);
      textToShow = response;
      FlutterTts flutterTts = await rememberFuntions.speakText(response);
      int wordCount = textToShow.split(' ').length;
      int secs = (wordCount * 0.47).toInt()-1;
      await flutterTts.awaitSpeakCompletion(true).whenComplete(() async {
        Future.delayed(Duration(seconds: secs), () {
          _startListening();      
        });  
      });
      setState(() {
        _lastWords = '';
        userFisrtInteraction = false;
      });
    }else{
      if(_lastWords!=''){
        String response = await rememberFuntions.userPrompt(_lastWords);
        textToShow = response;
        FlutterTts flutterTts = await rememberFuntions.speakText(response);
        int wordCount = textToShow.split(' ').length;
        int secs = (wordCount * 0.47).toInt()-1;
        await flutterTts.awaitSpeakCompletion(true).whenComplete(() async {
          Future.delayed(Duration(seconds: secs), () {
            _startListening();      
          });  
        });
      }
    }
    setState(() {
      _lastWords = '';
      listen = false;
      textToShow = textToShow;
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {    
    Future.delayed(const Duration(seconds: 3), () {
      if(_lastWords == result.recognizedWords){
        _stopListening();
      }      
    });
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }
}