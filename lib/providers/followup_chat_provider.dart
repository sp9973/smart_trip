import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_trip_plannner/presentation/screens/followup_message.dart';

import '../services/followup_service.dart';

final followUpChatProvider =
    StateNotifierProvider<FollowUpChatNotifier, List<FollowUpMessage>>(
      (ref) => FollowUpChatNotifier(),
    );

class FollowUpChatNotifier extends StateNotifier<List<FollowUpMessage>> {
  FollowUpChatNotifier() : super([]);

  final _service = FollowUpService();

  Future<void> sendMessage(String userMessage, String originalItinerary) async {
    final userMsg = FollowUpMessage(
      text: userMessage,
      sender: SenderType.user,
      timestamp: DateTime.now(),
    );
    final loadingMsg = FollowUpMessage(
      text: 'Thinking...',
      sender: SenderType.ai,
      timestamp: DateTime.now(),
      isLoading: true,
    );

    state = [...state, userMsg, loadingMsg];

    try {
      final reply = await _service.getAIResponse(
        userMessage,
        originalItinerary,
      );

      state = [
        ...state..remove(loadingMsg),
        FollowUpMessage(
          text: reply,
          sender: SenderType.ai,
          timestamp: DateTime.now(),
        ),
      ];
    } catch (_) {
      state = [
        ...state..remove(loadingMsg),
        FollowUpMessage(
          text: "Oops! The LLM failed to generate answer. Please regenerate.",
          sender: SenderType.ai,
          timestamp: DateTime.now(),
          isError: true,
        ),
      ];
    }
  }
}
