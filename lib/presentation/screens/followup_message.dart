enum SenderType { user, ai }

class FollowUpMessage {
  final String text;
  final SenderType sender;
  final DateTime timestamp;
  final bool isLoading;
  final bool isError;

  FollowUpMessage({
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isLoading = false,
    this.isError = false,
  });
}
