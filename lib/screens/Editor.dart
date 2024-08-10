import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:json_editor_flutter/json_editor_flutter.dart';
import 'package:vita_seniors/brain/MemoryFunctions.dart';
import 'package:vita_seniors/brain/RememberFuntions.dart';
import 'package:vita_seniors/screens/VoiceInterface.dart';
import 'package:vita_seniors/screens/Settings.dart';
import 'package:vita_seniors/components/Lang.dart';
import 'package:vita_seniors/screens/RememberInterface.dart';

class JsonEditorView extends StatefulWidget {
  final String routeName;
  const JsonEditorView({super.key, required this.routeName});

  @override
  JsonEditorViewState createState() => JsonEditorViewState();
}

class JsonEditorViewState extends State<JsonEditorView> {
  String jsonString = '{}';
  final TextEditingController _controller = TextEditingController();
  final MemoryFunctions memoryFunctions = MemoryFunctions();
  final rememberFuntions = Rememberfuntions();
  final LangStrings langStrings = LangStrings();
  String lang = 'en-US';

  @override
  void initState() {
    super.initState();
    _loadData();
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

  void _loadData() async {
    String jsonStringAux = await memoryFunctions.readFile(widget.routeName);

    setState(() {
      jsonString = jsonStringAux;
      _controller.text = jsonEncode(jsonStringAux);
    });
  }

  void _saveChanges(Map<String, dynamic> value) {
    memoryFunctions.modifyFile(widget.routeName, jsonEncode(value));
    setState(() {
      jsonString = jsonEncode(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(85, 83, 202, 1),
          title: Text(
            LangStrings.memoryFunctions[lang] ?? '',
            style: const TextStyle(color: Colors.white),
          ),
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
        body: jsonString != '{}'
            ? JsonEditor(
                enableValueEdit: true,
                enableKeyEdit: true,
                enableMoreOptions: true,
                enableHorizontalScroll: true,
                hideEditorsMenuButton: true,
                duration: const Duration(milliseconds: 1000),
                onChanged: (value) {
                  if (jsonString != jsonEncode(value)) {
                    _saveChanges(value);
                  }
                },
                json: jsonString,
              )
            : const CircularProgressIndicator());
  }
}
