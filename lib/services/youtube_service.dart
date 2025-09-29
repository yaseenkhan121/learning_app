import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class YoutubeService {
  final String apiKey = dotenv.env['YOUTUBE_API_KEY']!;

  Future<List<Map<String, dynamic>>> fetchVideos(String query) async {
    final url =
        'https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=10&q=$query&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final videos = data['items'] as List;

      return videos.map((video) {
        return {
          'videoId': video['id']['videoId'],
          'title': video['snippet']['title'],
          'thumbnail': video['snippet']['thumbnails']['high']['url'],
          'channel': video['snippet']['channelTitle'],
        };
      }).toList();
    } else {
      throw Exception("Failed to load videos");
    }
  }
}
