import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_trip_plannner/isar/itinerary.dart';
import 'package:smart_trip_plannner/routes/app_router.dart';

/// Global Isar provider used across the app
final isarProvider = Provider<Isar>((ref) => throw UnimplementedError());

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  await dotenv.load();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Isar with application document directory
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([ItinerarySchema], directory: dir.path);

  // Start the app with isar injected into provider scope
  runApp(
    ProviderScope(
      overrides: [isarProvider.overrideWithValue(isar)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Smart Trip Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      routerConfig: router,
    );
  }
}
