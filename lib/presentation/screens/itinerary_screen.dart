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

  Future<void> _launchDirections(String destination) async {
    final encodedDestination = Uri.encodeComponent(destination);
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$encodedDestination&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch directions to $destination';
    }
  }

  void _showLocationOptions(BuildContext context, String placeName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.map),
                title: const Text("View on Map"),
                onTap: () {
                  Navigator.pop(context);
                  _launchMap(placeName);
                },
              ),
              ListTile(
                leading: const Icon(Icons.directions),
                title: const Text("Get Directions"),
                onTap: () {
                  Navigator.pop(context);
                  _launchDirections(placeName);
                },
              ),
            ],
          ),
    );
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
      buffer.writeln();
    });
    return buffer.toString().trim();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = data.entries.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        title: const Text("Itinerary Created 🌴"),
        leading: BackButton(onPressed: () => context.go('/chat')),
        backgroundColor: const Color(0xFF00794E),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: days.length,
                      itemBuilder: (context, index) {
                        final dayLabel = days[index].key;
                        final dayData = days[index].value;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dayLabel,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00794E),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...List<Widget>.from(
                                (dayData['activities'] as List).map((activity) {
                                  final title =
                                      activity['title'] ?? 'Unknown Place';
                                  final time = activity['time'] ?? '';
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(
                                      Icons.place,
                                      size: 20,
                                      color: Colors.green,
                                    ),
                                    title: Text(title),
                                    subtitle: Text(time),
                                    onTap:
                                        () => _showLocationOptions(
                                          context,
                                          title,
                                        ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Flight section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFFDF3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFB4E1C3)),
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => _launchMap('Delhi'),
                            child: const Text(
                              "📍 Open example location in maps",
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Search for your Destination",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    ElevatedButton.icon(
                      onPressed: () => _saveOffline(context, ref),
                      icon: const Icon(Icons.save_alt),
                      label: const Text("Save Offline"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black87,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
