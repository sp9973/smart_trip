import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_trip_plannner/isar/itinerary.dart';
import 'package:smart_trip_plannner/main.dart';
import 'package:url_launcher/url_launcher.dart';

class ItineraryScreen extends ConsumerWidget {
  final Map<String, dynamic> data;

  const ItineraryScreen({super.key, required this.data});

  Future<void> _launchMap(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedQuery',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch map for $query';
    }
  }

  String _generateSummaryTitle(Map<String, dynamic> data, DateTime now) {
    final firstDay = data.keys.first;
    final activities = data[firstDay]['activities'] as List<dynamic>;

    if (activities.isNotEmpty) {
      final firstActivity = activities.first;
      final location = firstActivity['title'] ?? 'Trip';
      return "$location Itinerary (${data.length} days)";
    } else {
      return "Trip on ${now.toLocal().toString().split(' ').first}";
    }
  }

  Future<void> _saveOffline(BuildContext context, WidgetRef ref) async {
    final isar = ref.read(isarProvider);
    final now = DateTime.now();
    final List<String> allDays = [];
    final List<String> allActivities = [];

    data.forEach((day, value) {
      allDays.add(day);
      final activities = value['activities'] as List;
      for (final activity in activities) {
        final title = activity['title'] ?? 'Unknown';
        final time = activity['time'] ?? '';
        allActivities.add('$time - $title');
      }
    });

    final itinerary =
        Itinerary()
          ..title = _generateSummaryTitle(data, now)
          ..createdAt = now
          ..days = allDays
          ..activities = allActivities;

    await isar.writeTxn(() async {
      await isar.itinerarys.put(itinerary);
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Itinerary saved offline")),
      );
    }
  }

  String _formatItinerary(Map<String, dynamic> data) {
    final buffer = StringBuffer();

    data.forEach((day, info) {
      buffer.writeln('$day:');
      final activities = info['activities'] as List;
      for (var activity in activities) {
        final title = activity['title'] ?? '';
        final time = activity['time'] ?? '';
        buffer.writeln('• $time - $title');
      }
      buffer.writeln(); // newline between days
    });

    return buffer.toString().trim();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = data.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Itinerary Created 🌴"),
        leading: BackButton(onPressed: () => context.go('/chat')),
        backgroundColor: const Color(0xFF00794E),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final dayLabel = days[index].key;
                  final dayData = days[index].value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayLabel,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...List<Widget>.from(
                        (dayData['activities'] as List).map((activity) {
                          final title = activity['title'] ?? 'Unknown Place';
                          final time = activity['time'] ?? '';
                          return ListTile(
                            leading: const Icon(Icons.circle, size: 13),
                            title: Text(title),
                            subtitle: Text(time),
                            onTap: () => _launchMap(title),
                          );
                        }),
                      ),
                      const Divider(thickness: 1.5, color: Colors.green),
                      const SizedBox(height: 12),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Map Footer
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _launchMap('Ubud Bali'),
                    child: const Text(
                      "📍 Open example location in maps",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Mumbai to Bali, Indonesia | 11hrs 5mins",
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Follow-up Button
            ElevatedButton.icon(
              onPressed: () {
                final itineraryText = _formatItinerary(data);
                context.push('/follow-up', extra: itineraryText);
              },
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text("Follow up to refine"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00794E),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 10),

            // Save Button
            ElevatedButton.icon(
              onPressed: () => _saveOffline(context, ref),
              icon: const Icon(Icons.save_alt),
              label: const Text("Save Offline"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black54,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
