import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 📁 lib/presentation/screens/follow_up_chat_screen.dart

class FollowUpChatScreen extends ConsumerStatefulWidget {
  final String itineraryText;

  const FollowUpChatScreen({super.key, required this.itineraryText});

  @override
  ConsumerState<FollowUpChatScreen> createState() => _FollowUpChatScreenState();
}

class _FollowUpChatScreenState extends ConsumerState<FollowUpChatScreen> {
  final TextEditingController _controller = TextEditingController();

  String? response;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Refine Itinerary ✏️"),
        backgroundColor: const Color(0xFF00794E),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "🗒️ Current Itinerary",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(child: Text(widget.itineraryText)),
            ),
            const Divider(),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Add a follow-up query",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () async {
                // TODO: Call your Gemini function here
                // For now, simulate response
                setState(() {
                  response = "AI response: ✅ Your itinerary has been refined.";
                });
              },
              icon: const Icon(Icons.send),
              label: const Text("Refine"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00794E),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            if (response != null) ...[
              const Text(
                "Response",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(response!),
            ],
          ],
        ),
      ),
    );
  }
}
