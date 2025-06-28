import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:smart_trip_plannner/isar/itinerary.dart';
import 'package:smart_trip_plannner/main.dart';

final savedItinerariesProvider = FutureProvider<List<Itinerary>>((ref) async {
  final isar = ref.read(isarProvider);
  return await isar.itinerarys.where().sortByCreatedAtDesc().findAll();
});
