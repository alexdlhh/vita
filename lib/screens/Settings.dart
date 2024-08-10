import 'package:flutter/material.dart';
import 'package:vita_seniors/components/Lang.dart';
import 'package:vita_seniors/brain/RememberFuntions.dart';
import 'package:vita_seniors/brain/SpeakFunctions.dart';
import 'package:vita_seniors/screens/VoiceInterface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vita_seniors/screens/RememberInterface.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final rememberFuntions = Rememberfuntions();
  final LangStrings langStrings = LangStrings();
  final speakFunctions = Speakfuntions();
  String lang = 'en-US';
  Future<List<dynamic>>? _voicesFuture;
  Map<Object?, Object?> selectedVoice = {};
  double _currentSliderValue = 1.1;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    String ln = await rememberFuntions.getLanguage();
    await speakFunctions.getVoices();
    _voicesFuture = speakFunctions.getVoices();
    if (ln != lang) {
      setState(() {
        lang = ln;
        _voicesFuture = _voicesFuture;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(85, 83, 202, 1),
          title: Text(
            LangStrings.settings[lang] ?? 'not set',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: LangStrings.voiceInterface[lang] ?? '',
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const VoiceInterfacePage()));
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.voice_chat),
                        const SizedBox(width: 8),
                        Text(LangStrings.voiceInterface[lang] ?? ''),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: LangStrings.memory[lang] ?? '',
                    onTap: () {
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
            child:
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Center(
                child: Text(LangStrings.language[lang] ?? '',
                    style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(LangStrings.english[lang] ?? ''),
                  Switch(
                      activeColor: const Color.fromRGBO(255, 255, 255, 1),
                      activeTrackColor: const Color.fromRGBO(85, 83, 202, 1),
                      inactiveThumbColor: const Color.fromRGBO(255, 255, 255, 1),
                      inactiveTrackColor: const Color.fromRGBO(85, 83, 202, 1),
                      value: lang == 'es-ES' ? true : false,
                      onChanged: (value) {
                        changeLang(value);
                      }),
                  Text(LangStrings.spanish[lang] ?? ''),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 10),
                child: Text(LangStrings.voiceSelector[lang] ?? '',
                    style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: 300,
                width: MediaQuery.of(context).size.width * 0.7,
                child: FutureBuilder<List<dynamic>>(
                  future: _voicesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final voices = snapshot.data!;

                      return ListView.builder(
                        // Enable scrolling for a smooth user experience
                        shrinkWrap: false,
                        physics:
                        const ClampingScrollPhysics(), // Prevent overscrolling
                        itemCount: voices.length,
                        itemBuilder: (context, index) {
                          final voice = voices[index];

                          return RadioListTile<dynamic>(
                            // Set the value to the voice object for selection tracking
                            value: voice,
                            groupValue:
                            selectedVoice, // Maintain the selected voice state
                            title: Text(voice['name'],style: const TextStyle(color: Colors.black),), // Display voice details
                            onChanged: (newVoice) =>
                                _handleVoiceSelection(newVoice),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    // Display a loading indicator while fetching voices
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 10),
                child: Text(LangStrings.speechSpeed[lang] ?? '',
                    style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Slider(
                value: _currentSliderValue,
                max: 2,
                min: 0,
                divisions: 20,
                label: _currentSliderValue.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _currentSliderValue = value;
                  });
                },
              ),
            ])));
  }

  Future<void> changeLang(bool langAux) async {
    await rememberFuntions.setLanguage(langAux ? 'es-ES' : 'en-US');
    setState(() {
      lang = langAux ? 'es-ES' : 'en-US';
    });
  }

  void _handleVoiceSelection(Map<Object?, Object?> voice) {
    Map<String, String> voiceAux = {
      'name': voice['name'] as String,
      'locale': voice['locale'] as String
    };
    // Actualiza la voz seleccionada en el motor de texto a voz
    speakFunctions.setVoice(voiceAux);

    // Actualiza el estado para indicar qué voz está seleccionada
    setState(() {
      selectedVoice = voice;
    });

    // Guarda la preferencia del usuario (opcional)
    // Puedes usar SharedPreferences, Hive o cualquier otro método de almacenamiento local
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('selectedVoice', voice['name'] as String);
    });

    // Realiza otras acciones necesarias, como:
    // - Mostrar un mensaje de confirmación
    // - Actualizar la interfaz de usuario para reflejar la selección
    // - Llamar a una función para configurar la voz seleccionada en el motor de texto a voz
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Se seleccionó la voz: ${voice['name']}'),
      ),
    );
  }
}

class VoiceListTile extends StatefulWidget {
  final Map<Object?, Object?> voice;
  final Function(bool) onSelected;
  final VoidCallback onTap;

  const VoiceListTile({
    super.key,
    required this.voice,
    required this.onSelected,
    required this.onTap,
  });

  @override
  State<VoiceListTile> createState() => _VoiceListTileState();
}

class _VoiceListTileState extends State<VoiceListTile> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // Center the content horizontally
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Text with custom styling
          Text(
            widget.voice['name'] as String,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          IconButton(
            icon: Icon(
              isSelected ? Icons.check_circle : Icons.circle,
              color: Colors.blue,
            ),
            onPressed: () {
              setState(() {
                isSelected = !isSelected;
                widget.onSelected(isSelected); // Call onSelected callback
              });
            },
          ),
        ],
      ),
    );
  }
}
