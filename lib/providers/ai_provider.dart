import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_trip_plannner/services/gemini_service.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) => GeminiService());

final aiResponseProvider = FutureProvider.family<Map<String, dynamic>, String>((
  ref,
  prompt,
) async {
  final gemini = ref.read(geminiServiceProvider);
  return await gemini.generateItinerary(prompt);
});
