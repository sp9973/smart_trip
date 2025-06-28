import 'package:isar/isar.dart';

part 'itinerary.g.dart';

@collection
class Itinerary {
  Id id = Isar.autoIncrement;

  late String title;
  late DateTime createdAt;

  late List<String> days;
  late List<String> activities;
}
