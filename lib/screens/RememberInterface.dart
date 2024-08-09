import 'package:flutter/material.dart';
import 'package:vita_seniors/components/Lang.dart';
import 'package:vita_seniors/screens/Editor.dart';
import 'package:vita_seniors/brain/RememberFuntions.dart';
import 'package:vita_seniors/screens/VoiceInterface.dart';
import 'package:vita_seniors/screens/Settings.dart';

class RememberPage extends StatefulWidget {
  const RememberPage({super.key});

  @override
  State<RememberPage> createState() => _RememberPageState();
}

class _RememberPageState extends State<RememberPage> {
  final rememberFuntions = Rememberfuntions();
  final LangStrings langStrings = LangStrings();
  String lang = 'en-US';

  @override
  void initState() {
    super.initState();
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
                  ]),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: const Icon(Icons.list),
                  title: Text(LangStrings.rememberList[lang] ?? ''),
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const JsonEditorView(
                                routeName: 'rememberList')));
                  },
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: const Icon(Icons.shopping_cart),
                  title: Text(LangStrings.shopList[lang] ?? ''),
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const JsonEditorView(routeName: 'shopList')));
                  },
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: const Icon(Icons.memory),
                  title: Text(LangStrings.memory[lang] ?? ''),
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const JsonEditorView(routeName: 'memory')));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
