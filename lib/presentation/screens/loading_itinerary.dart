import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_trip_plannner/providers/ai_provider.dart';

class LoadingItineraryScreen extends ConsumerStatefulWidget {
  final String prompt;

  const LoadingItineraryScreen({super.key, required this.prompt});

  @override
  ConsumerState<LoadingItineraryScreen> createState() =>
      _LoadingItineraryScreenState();
}

class _LoadingItineraryScreenState
    extends ConsumerState<LoadingItineraryScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.listenManual(aiResponseProvider(widget.prompt), (previous, next) {
        next.when(
          data: (data) {
            if (!_hasNavigated && mounted) {
              _hasNavigated = true;
              context.go('/itinerary', extra: data);
            }
          },
          error: (err, _) {
            if (!_hasNavigated && mounted) {
              _hasNavigated = true;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("❌ Error: $err")));
              context.go('/chat');
            }
          },
          loading: () {}, // Optional: already showing loader in UI
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // final aiResponse = ref.watch(aiResponseProvider(widget.prompt));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Creating Itinerary"),
        leading: BackButton(onPressed: () => context.go('/chat')),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(child: Text("S")),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Center(
            child: Text(
              "Creating Itinerary...",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 30),
          const CircularProgressIndicator(color: Color(0xFF00794E)),
          const SizedBox(height: 16),
          const Text("Curating a perfect plan for you..."),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text("Follow up to refine"),
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: const Color.fromARGB(
                      255,
                      113,
                      225,
                      128,
                    ),
                    foregroundColor: Colors.black54,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text("Save Offline"),
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: Colors.grey,
                    foregroundColor: Colors.black38,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
