import 'package:vita_seniors/components/Lang.dart';
import 'package:vita_seniors/components/Navigator.dart';
import 'package:vita_seniors/brain/MemoryFunctions.dart';
import 'package:vita_seniors/brain/GeminiFunctions.dart';
import 'package:vita_seniors/brain/RememberFuntions.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:vita_seniors/components/MakeContact.dart';
import 'dart:convert';
import 'dart:core';

class DeciderFunctions {
  final gemini = Geminifuntions();
  final LangStrings langStrings = LangStrings();
  String lang = 'es-ES';
  final memory = MemoryFunctions();
  final rememberfuntions = Rememberfuntions();
  final navigator = Navigator();
  MakeContact makeContact = MakeContact();

  Future<Map<String, dynamic>> analizer(String userAsk) async {
    String today = DateTime.now().toString().split(' ')[0];
    String instructions = deciderPrompt(lang, today);
    String run = "gemini";
    String prompt = """
      $instructions
      $userAsk
    """;
    String response = await gemini.deciderGeminiPrompt(prompt);

    //detectamos si es un JSON o no
    if (response.contains('{') && response.contains('}')) {
      //como es posible que Gemini nos entremezcle texto antes o despues del JSON, nos quedamos solo con lo que hay desde el primer { al ultimo }
      response = response.substring(
          response.indexOf('{'), response.lastIndexOf('}') + 1);
      //decodificamos el JSON
      var data = json.decode(response);
      //comprobamos si existe data['key']
      if (data.containsKey('key')) {
        String key = data['key'];
        String instruction = '';
        switch (key) {
          case 'remember':
          case '#remember':
            rememberfuntions.setToRememberList(data);
            response = LangStrings.rememberAdded[lang] ?? '';
            instruction = "${LangStrings.informUserOf[lang] ?? ''} $response";
            break;
          case 'readremember':
          case '#readremember':
            response = await rememberfuntions.getRememberList();
            instruction =
                "${LangStrings.readRememberList[lang] ?? ''} $response";
            break;
          case 'toshop':
          case '#toshop':
            rememberfuntions.setToShopList(data);
            response = LangStrings.toShopAdded[lang] ?? '';
            instruction = "${LangStrings.informUserOf[lang] ?? ''} $response";
            break;
          case 'readtoshop':
          case '#readtoshop':
            response = await rememberfuntions.getShopList();
            instruction = "${LangStrings.readToShopList[lang] ?? ''} $response";
            break;
          case 'deletelisttoshop':
          case '#deletelisttoshop':
            rememberfuntions.cleanToShopListOldItems();
            response = LangStrings.toShopDeleted[lang] ?? '';
            instruction = "${LangStrings.informUserOf[lang] ?? ''} $response";
            break;
          case 'volumeup':
          case '#volumeup':
            volumeUp();
            instruction = LangStrings.volumeUp[lang] ?? '';
            break;
          case 'volumedown':
          case '#volumedown':
            volumeDowb();
            instruction = LangStrings.volumeDown[lang] ?? '';
            break;
          case 'search':
          case '#search':
            String search =
                await gemini.extractBestGoogleSearch(data['search']);
            String navigatorResponse = await navigator.searchOnGoogle(search);
            response = await gemini.formResponseFromHTML(
                navigatorResponse, userAsk, lang);
            break;
          case 'showmevideo':
          case '#showmevideo':
            String search =
                await gemini.extractBestYoutubeSearch(data['search']);
            response = await navigator.searchOnYoutube(search);
            run = 'youtube';
            break;
          case 'music':
          case '#music':
            String search =
                await gemini.extractBestYoutubeSearch(data['search']);
            response = await navigator.searchOnYoutube(search);
            run = 'music';
            break;
          case 'call':
          case '#call':
            String name = data['name'] ?? '';
            List<String> phoneNumbers = await makeContact.searchContact(name);
            //si phoneNumbers es mayor que 1 preguntamos a quien llamar, si no solo llamamos al numero
            if (phoneNumbers.length > 1) {
              String contactSelect =
                  contactSelectPrompt(lang, phoneNumbers, userAsk);
              response = await gemini.userPromptDefault(contactSelect, lang);
              //usamos expresiones regulares para obtener solo el numero
              RegExp expresionNumeros = RegExp(r'\d+');
              String numero =
                  expresionNumeros.firstMatch(response)?.group(0) ?? '0';
              await makeContact.makePhoneCall(numero);
              response = LangStrings.callSuccess[lang] ?? '';
            } else if (phoneNumbers.length == 1) {
              if (phoneNumbers[0] != '') {
                String phoneNumber = phoneNumbers[0].split(';;')[2];
                await makeContact.makePhoneCall(phoneNumber);
                response = LangStrings.callSuccess[lang] ?? '';
              }
            } else {
              response = LangStrings.callFailed[lang] ?? '';
            }
            break;
          case 'mail':
          case '#mail':
            String name = data['name'] ?? '';
            List<String> emails =
                await makeContact.searchContact(name, data: 'email');
            //si emails es mayor que 1 preguntamos a quien enviar el mensaje, si no solo enviamos
            if (emails.length > 1) {
              String contactSelect = emailSelectPrompt(lang, emails, userAsk);
              response = await gemini.userPromptDefault(contactSelect, lang);
              //usamos expresiones regulares para obtener solo el email
              RegExp expresionEmail = RegExp(r'\w+@\w+\.\w+');
              String email =
                  expresionEmail.firstMatch(response)?.group(0) ?? '';
              await makeContact.makeEmail(email);
              response = LangStrings.emailSuccess[lang] ?? '';
            } else if (emails.length == 1) {
              if (emails[0] != '') {
                String email = emails[0].split(';;')[2];
                await makeContact.makeEmail(email);
                response = LangStrings.emailSuccess[lang] ?? '';
              }
            } else {
              response = LangStrings.emailFailed[lang] ?? '';
            }
            break;
          case 'whatsapp':
          case '#whatsapp':
            String name = data['name'] ?? '';
            String message = data['message'] ?? '';
            List<String> phoneNumbers = await makeContact.searchContact(name);
            //si phoneNumbers es mayor que 1 preguntamos a quien enviar el mensaje, si no solo enviamos
            if (phoneNumbers.length > 1) {
              String contactSelect =
                  contactSelectPrompt(lang, phoneNumbers, userAsk);
              response = await gemini.userPromptDefault(contactSelect, lang);
              //usamos expresiones regulares para obtener solo el numero
              RegExp expresionNumeros = RegExp(r'\d+');
              String numero =
                  expresionNumeros.firstMatch(response)?.group(0) ?? '0';
              await makeContact.makeWhatsapp(numero, message);
              response = LangStrings.callSuccess[lang] ?? '';
            } else if (phoneNumbers.length == 1) {
              if (phoneNumbers[0] != '') {
                String phoneNumber = phoneNumbers[0].split(';;')[2];
                await makeContact.makeWhatsapp(phoneNumber, message);
                response = LangStrings.callSuccess[lang] ?? '';
              }
            } else {
              response = LangStrings.callFailed[lang] ?? '';
            }
            break;
          default:
            instruction = prompt;
        }
        if (instruction != '') {
          response = await gemini.userPromptDefault(instruction, lang);
        }
      } else {
        response = await gemini.userPromptDefault(prompt, lang);
      }
    }

    Map<String, dynamic> data = {"response": response, "run": run};

    return data;
  }

  Future<void> volumeUp() async {
    double currentVolume = await VolumeController().getVolume();
    //si el volumen puede subirse lo subimos un 10%
    if (currentVolume < 1.0) {
      double newVolume = currentVolume + 0.1;
      VolumeController().setVolume(newVolume);
    }
  }

  Future<void> volumeDowb() async {
    double currentVolume = await VolumeController().getVolume();
    //si el volumen puede subirse lo subimos un 10%
    if (currentVolume > 0.0) {
      double newVolume = currentVolume - 0.1;
      VolumeController().setVolume(newVolume);
    }
  }

  String deciderPrompt(lang, today) {
    if (lang == 'es-ES') {
      return """
        Hola Gemini, voy a darte ciertos ejemplos que responderían a una acción concreta, esta acción tendrá una key, luego te pasaré lo que ha pedido el usuario y debes responder con la key que mejor responda. y un json donde estructures la petición, responde con eso y no des explicaciones ya que tu respuesta será guardada en un JSON para hacer otra interacción contigo en el futuro añadiendo esta información
        hoy es $today para que lo tengas en cuenta.

        key #remember
        ejemplos:
        Vita recuerdame que tengo que tomar la pastilla de las rodillas a las 8.
        Me habian dicho que echaban el programa de La Resistencia dentro de 6 días a las 12 recuerdamelo
        json:
        la estructura no esta escrita en piedra pero si viene una referencia a una hora, añade una key hour y si hay referencia a una fecha una key date, y crees un campo description y estaría muy bien si me calculas la fecha de cuando debería saltar el recordatorio

        key #readremember
        ejemplos:
        tengo algo apuntado para hoy
        tienes que recordarme algo
        json:
        la estructura de este json va a intentar determinar si se refiere a un dia/hora concreto y si no pide leer la lista entera

        key #toshop
        ejemplos:
        tengo que comprar leche que casi no queda
        apunta en la lista comprar suficiente carne y bebidas para la barbacoa este fin de semana, seremos 8 personas
        json:
        aqui la estructura si que importa algo en el sentido de que si detectas esta acción necesitaré que añadas una key item donde especificques un objeto en concreto y una key quantity si es posible (en ocasiones no darán una cantidad de forma clara y tendrás que estimarla)

        key #readtoshop
        ejemplos:
        estoy en el super dime que cosas tenia que comprar
        Vita dime que cosas tengo apuntadas para comprar
        json:
        la estructura de este json va centrarse en la key readtoshop la cual leerá la lista

        key #deletelisttoshop
        ejemplos:
        ya he comprado todo
        vita borra la lista de compras
        json:
        la estructura de este json va centrarse en la key deletelisttoshop la cual borrará la lista de compras      
        
        key #volumeup
        ejemplos:
        apenas te oigo
        no te escucho bien
        ¿puedes hablar más alto?
        json:
        aqui mas que la información en si me vale la key volumeup ya que esta incrementará el volumen un 10%

        key #volumedown
        ejemplos:
        baja un poco el volumen
        suena muy alto
        json:
        mismo caso que el anterior solo que en lugar de aumentar reduciré un 10% el volumen

        key #search
        ejemplos:
        buscame en internet cual es el monte más alto del mundo
        json:
        en este caso intenta extraer cual sería la búsqueda mas optima que hacer en google para responder esta pregunta y ponga en una key search, la app mandará esa busqueda obtendrá los primeros resultados y te los daré para que elabores una respuesta fundada en una segunda interacción

        key #showmevideo
        ejemplos:
        VITA buscame algún documental sobre animales
        me gustaría ver algo divertido
        json:
        necesitamos extraer un texto que sirva como busqueda en la app de youtube y que me crees la key search con ese texto

        key #music
        ejemplos:
        me gustaría escuchar musica
        me gustaría escuchar una cancion
        json:
        necesitamos extraer un texto que sirva como busqueda en music.youtube.com y que me crees la key search con ese texto
        
        key #call
        ejemplos:
        llama a mi hija
        llama a Laura
        me gustará hablar con Juan
        json:
        necesitamos extraer el nombre del contacto al que quiere llamar usa la key name para el nombre, si este es encontrado en la lista de contactos se le llamará

        key #mail
        ejemplos:
        quiero mandar un correo a carlos
        me gustaría hablar con Eva
        esto esta fallando me gustaría contactar con el soporte de mi compañia movil por correo
        json:
        necesitamos extraer el nombre del contacto al que quiere enviar un email usa la key name para el nombre, si este es encontrado en la lista de contactos se le abrirá la aplicación de email para que inicie la escritura del mismo

        key #whatsapp
        ejemplos:
        mandale un whatsapp a pepe y dile que traiga hielo y pan
        mandale un mensaje a mama diciendo que ya he llegado
        contesta a Jose en whastapp que ya está listo
        json:
        en este caso necesitamos identificar el nombre del contacto y además el mensaje si lo hubiese usa la key name para el nombre y la key message para el mensaje
        
        key #default
        cuando no coincida ninguna de las anteriores
        json:
        en este caso responde como VITA el asistente de personas mayores que busca entretenerlos y ayudarles a pasar el tiempo

        petición real:
      """;
    } else if (lang == 'en-US') {
      return """
        Hi Gemini, I will provide you with some examples that respond to a specific action. This action will have a key, then I will give you what the user has requested and you should respond with the key that best responds and a JSON where you structure the request. Respond with that and do not give explanations as your response will be saved in a JSON to make another interaction with you in the future adding this information.
        Today is $today so you can take it into account.

        key #remember
        Examples:
        Vita remind me to take my knee pill at 8.
        They told me that they were going to air the program La Resistencia in 6 days at 12, remind me.
        JSON:
        the structure is not written in stone but if there is a reference to a time, add a key hour and if there is a reference to a date, and description field, add a key date and it would be great if you could calculate the date when the reminder should be triggered.

        key #readremember
        examples:
        I have something written down for today
        you have to remind me of something
        json:
        the structure of this json will try to determine if it refers to a specific day/time and if not it asks to read the whole list.

        key #toshop
        examples:
        I have to buy milk, I'm almost out of milk
        note in the list to buy enough meat and drinks for the barbecue this weekend, we will be 8 persons
        json:
        here the structure does matter somewhat in the sense that if you detect this action I will need you to add a key item where you specify a particular object and a key quantity if possible (sometimes they will not give a clear quantity and you will have to estimate it)

        key #readtoshop
        examples:
        I am in the supermarket tell me what things I had to buy
        Vita tell me what things I had to buy
        json:
        the structure of this json is going to be centered on the key readtoshop which will read the list

        key #deletelisttoshop
        examples:
        I have already bought everything
        vita clears the shopping list
        json:
        the structure of this json is going to focus on the key deletelisttoshop which will delete the shopping list.      
        
        key #volumeup
        examples:
        I can barely hear you
        I can't hear you well
        can you speak louder?
        json:
        here more than the information itself I need the volumeup key because it will increase the volume by 10%.

        key #volumedown
        examples:
        lower the volume a little bit
        sounds too loud
        json:
        same case as above only instead of increasing I will reduce the volume by 10%.

        key #search
        examples:
        search for me on the internet which is the highest mountain in the world
        json:
        in this case try to extract what would be the best search to do in google to answer this question and put it in a key search, the app will send that search, get the first results and I will give them to you so you can elaborate an answer based on a second interaction.

        key #showmevideo
        examples:
        VITA find me a documentary about animals
        I would like to see something funny
        json:
        we need to extract a text that serves as a search in the youtube app and create the key search with that text

        key #music
        examples:
        i would like to listen to music
        I would like to listen to a song
        json:
        we need to extract a text that serves as a search in music.youtube.com and create the key search with that text
        
        key #call
        examples:
        call my daughter
        call Laura
        I would like to talk to Juan
        json:
        we need to extract the name of the contact you want to call, for name of contact use key name, if it is found in the contact list it will be called

        key #mail
        examples:
        i want to send an email to carlos
        I would like to talk to Eva
        this is failing i would like to contact my mobile company support by mail
        json:
        we need to extract the name of the contact you want to send an email to, for name of contact use key name, if it is found in the contact list it will open the email application for you to start writing it

        key #whatsapp
        examples:
        send a whatsapp to pepe and tell him to bring ice and bread
        send a message to mom saying that I have arrived
        reply to jose on whastapp that he is ready
        json:
        in this case we need to identify the name of the contact and also the message if there is one. , for name of contact use key name and for message use key message
        
        key #default
        when none of the above matches
        json:
        in this case responds as VITA the senior citizen assistant that seeks to entertain them and help them pass the time.

        actual request:
        """;
    }
    return '';
  }

  String contactSelectPrompt(
      String lang, List<String> list, String userRequest) {
    if (lang == 'es-ES') {
      return """
        Hola Gemini, un usuario ha pedido llamar a una persona y la app ha encontrado a estos usuarios:
        ${list.join('\n')}
        
        En base a esa lista elige que usuario es el más probable para la petición del usuario, responde solo con la posición en la lista de usuarios.      
        $userRequest
      """;
    } else if (lang == 'en-US') {
      return """
        Hi Gemini, a user has asked to call a person and the app has found these users:
        ${list.join('\n')}
        
        Based on that list it chooses which user is the most likely user for the user's request, it will respond only with the position in the list of users.      
        $userRequest
        """;
    }
    return '';
  }

  String emailSelectPrompt(String lang, List<String> list, String userRequest) {
    if (lang == 'es-ES') {
      return """
        Hola Gemini, un usuario ha pedido enviar un correo a una persona y la app ha encontrado a estos usuarios:
        ${list.join('\n')}
        
        En base a esa lista elige que usuario es el más probable para la petición del usuario, responde solo con la posición en la lista de usuarios.      
        $userRequest
      """;
    } else if (lang == 'en-US') {
      return """
        Hi Gemini, a user has asked to send a email to a person and the app has found these users:
        ${list.join('\n')}
        
        Based on that list it chooses which user is the most likely user for the user's request, it will respond only with the position in the list of users.      
        $userRequest
        """;
    }
    return '';
  }
}
