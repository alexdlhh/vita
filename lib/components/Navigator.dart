import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Navigator {
  static const GoogleSearchUrl = 'https://www.google.com/search?q=';

  Future<String> searchOnGoogle(String search) async {
    final response = await http.get(Uri.parse(GoogleSearchUrl + search));
    return response.body;
  }

  Future<String> searchOnYoutube(String search) async {
    String youtubeApiKey = dotenv.env['YOUTUBE_API_KEY'] ?? 'NO API KEY';

    //tratamos search para que no rompa la url
    search = search.replaceAll(' ', '+');

    var request = http.Request(
        'GET',
        Uri.parse(
            'https://www.googleapis.com/youtube/v3/search?q=$search&maxResults=1&key=$youtubeApiKey'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String rawData = await response.stream.bytesToString();
      Map<String, dynamic> data = json.decode(rawData);
      List<String> results = [];
      for (var item in data['items']) {
        results.add(item['id']['videoId']);
      }
      return results[0];
    } else {
      print(response.reasonPhrase);
      return '';
    }
  }

  
}
