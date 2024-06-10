import 'package:flutter/material.dart';
import 'package:vita_seniors/screens/VoiceInterface.dart';
import 'package:vita_seniors/brain/RememberFuntions.dart';
import 'package:vita_seniors/components/Lang.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  final rememberFuntions = Rememberfuntions();
  final LangStrings langStrings = LangStrings();
  String lang = 'es-ES';

  @override
  void initState() {
    super.initState();    
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const VoiceInterfacePage()),
      );
    });
  }

  void setLang(lang) async{
    setState(() {
      lang = lang;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);
    if (currentLocale.languageCode == 'es') {
      rememberFuntions.setLanguage('es-ES');
      setLang('es-ES');
    } else {
      rememberFuntions.setLanguage('es-ES');
      //rememberFuntions.setLanguage('en-US');
      setLang('es-ES');
      //setLang('en-US');
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(85, 83, 202, 1),
        title: const Center(child: Text('Vita', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold))),
      ),
      body: Container(
        color: const Color.fromRGBO(85, 83, 202, 1),        
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/logo.png',
                width: 200,
                height: 200,
              ),
              Text(
                LangStrings.voiceInterface[lang]??'',
                style:const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                LangStrings.poweredBy[lang]??'',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),  
        ),
      ),

    );
  }
}
