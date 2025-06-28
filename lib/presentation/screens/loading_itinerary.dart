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
          loading: () {}, // Already showing loader
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        title: const Text("Creating Itinerary"),
        leading: BackButton(onPressed: () => context.go('/chat')),
        backgroundColor: const Color(0xFF00794E),
        foregroundColor: Colors.white,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text("S", style: TextStyle(color: Colors.green)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.05),
                      Icon(
                        Icons.map_outlined,
                        size: screenWidth * 0.15,
                        color: const Color(0xFF00794E),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Creating Itinerary...",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(color: Color(0xFF00794E)),
                      const SizedBox(height: 12),
                      const Text(
                        "Curating a perfect plan for you...",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      const Spacer(),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(top: 20, bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.chat_bubble_outline),
                              label: const Text("Follow up to refine"),
                              style: ElevatedButton.styleFrom(
                                disabledBackgroundColor: const Color(
                                  0xFFB7E5C4,
                                ),
                                foregroundColor: Colors.black54,
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.save_outlined),
                              label: const Text("Save Offline"),
                              style: ElevatedButton.styleFrom(
                                disabledBackgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black38,
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
