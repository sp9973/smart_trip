import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  final String? apiKey = dotenv.env['GEMINI_API_KEY'];

  Future<Map<String, dynamic>> generateItinerary(String prompt) async {
    if (apiKey == null) {
      throw Exception('GEMINI_API_KEY not found in environment variables');
    }

    const endpoint =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

    final response = await http.post(
      Uri.parse('$endpoint?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': '''
Generate a day-wise travel itinerary based on this prompt: "$prompt".

Return ONLY valid JSON in this exact format:
{
  "Day 1": {
    "activities": [
      {"title": "Visit Eiffel Tower", "time": "10:00 AM"},
      {"title": "Lunch near Seine", "time": "1:00 PM"}
    ]
  },
  "Day 2": {
    "activities": []
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
      final content = jsonDecode(response.body);
      final text = content['candidates']?[0]?['content']?['parts']?[0]?['text'];
      if (text != null) {
        try {
          String cleanText = text.trim();
          if (cleanText.startsWith('```json')) {
            cleanText = cleanText.substring(7);
          }
          if (cleanText.startsWith('```')) {
            cleanText = cleanText.substring(3);
          }
          if (cleanText.endsWith('```')) {
            cleanText = cleanText.substring(0, cleanText.length - 3);
          }
          return jsonDecode(cleanText.trim());
        } catch (e) {
          throw Exception('Failed to parse AI response as JSON: $e');
        }
      }
    }
    throw Exception('Failed to generate itinerary: ${response.statusCode}');
  }
}
