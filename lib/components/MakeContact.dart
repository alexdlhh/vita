import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class MakeContact {
  Future<void> makePhoneCall(String phoneNumber) async {
    Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Mostrar un mensaje de error
    }
  }

  Future<void> makeEmail(String email) async {
    Uri url = Uri.parse('mailto:$email');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Mostrar un mensaje de error
    }
  }

  Future<void> makeWhatsapp(String phoneNumber, String message) async {
    Uri url = Uri.parse(
        'https://api.whatsapp.com/send?phone=$phoneNumber&text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Mostrar un mensaje de error
    }
  }

  bool compararTextosSimples(String texto1, String texto2) {
    // Eliminar acentos y convertir a minúsculas
    String normalizar(String texto) => texto
        .toLowerCase()
        .replaceAll(RegExp(r'[àáâãäå]', caseSensitive: false), 'a')
        .replaceAll(RegExp(r'[èéêë]', caseSensitive: false), 'e')
        .replaceAll(RegExp(r'[ìíîï]', caseSensitive: false), 'i')
        .replaceAll(RegExp(r'[òóôõö]', caseSensitive: false), 'o')
        .replaceAll(RegExp(r'[ùúûü]', caseSensitive: false), 'u');

    texto1 = normalizar(texto1);
    texto2 = normalizar(texto2);

    // Comparar longitudes
    if (texto1.length != texto2.length) {
      return false;
    }

    // Comparar carácter a carácter
    for (int i = 0; i < texto1.length; i++) {
      if (texto1[i] != texto2[i]) {
        return false;
      }
    }

    return true;
  }

  Future<List<String>> searchContact(String name,
      {String data = 'phone'}) async {
    print(name);
    List<Contact> contacts = await FlutterContacts.getContacts();
    List<String> phoneNumbers = [];
    List<String> emails = [];
    for (Contact contact in contacts) {
      if (compararTextosSimples(contact.displayName, name)) {
        if (data == 'phone') {
          for (Phone phone in contact.phones) {
            phoneNumbers
                .add("${contact.displayName};;${phone.label};;${phone.number}");
          }
          return phoneNumbers;
        } else {
          for (Email email in contact.emails) {
            emails.add(
                "${contact.displayName};;${email.label};;${email.address}");
          }
          return emails;
        }
      }
    }
    return [];
  }
}
