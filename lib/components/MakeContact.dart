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
    Uri url = Uri.parse('https://api.whatsapp.com/send?phone=$phoneNumber&text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Mostrar un mensaje de error
    }
  }

  Future<List<String>> searchContact(String name,
      {String data = 'phone'}) async {
    List<Contact> contacts = await FlutterContacts.getContacts();
    List<String> phoneNumbers = [];
    List<String> emails = [];
    for (Contact contact in contacts) {
      if (contact.displayName.contains(name)) {
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
