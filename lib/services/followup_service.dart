import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class FollowUpService {
  final String? apiKey = dotenv.env['GEMINI_API_KEY'];

  Future<String> getAIResponse(String prompt, String context) async {
    const endpoint =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

    final uri = Uri.parse('$endpoint?key=$apiKey');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': '''
You're an AI travel assistant. The user provided a previous itinerary and now wants to refine it. Use the previous plan to update or improve it.

PREVIOUS ITINERARY:
$context

USER FOLLOW-UP:
$prompt

Now return only the updated full itinerary as JSON, like:
{
  "Day 1": {
    "activities": [
      {"title": "Visit Eiffel Tower", "time": "10:00 AM"},
      {"title": "Lunch near Seine", "time": "1:00 PM"}
    ]
  }
}
''',
              },
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final text = body['candidates']?[0]?['content']?['parts']?[0]?['text'];
      if (text != null) return text;

      throw Exception('No valid response from Gemini.');
    } else {
      throw Exception('Failed to generate response: ${response.body}');
    }
  }
}
