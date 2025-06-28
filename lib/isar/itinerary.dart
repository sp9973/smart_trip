import 'package:isar/isar.dart';

part 'itinerary.g.dart'; // Don't forget this

@collection
class Itinerary {
  Id id = Isar.autoIncrement;

  late String title; // Example: "Trip to Bali"
  late DateTime createdAt;

  late List<String> days; // ["Day 1", "Day 2", ...]
  late List<String> activities; // Flattened for simplicity
}
