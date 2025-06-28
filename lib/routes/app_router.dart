import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_trip_plannner/presentation/screens/chat.dart';
import 'package:smart_trip_plannner/presentation/screens/followup_chat_screen.dart'; // ✅ Add this import
import 'package:smart_trip_plannner/presentation/screens/forgot_password.dart';
import 'package:smart_trip_plannner/presentation/screens/itinerary_screen.dart';
import 'package:smart_trip_plannner/presentation/screens/loading_itinerary.dart';
import 'package:smart_trip_plannner/presentation/screens/login.dart';
import 'package:smart_trip_plannner/presentation/screens/profile_screen.dart';
import 'package:smart_trip_plannner/presentation/screens/savedtrips.dart';
import 'package:smart_trip_plannner/presentation/screens/signup.dart';
import 'package:smart_trip_plannner/providers/auth_provider.dart';
import 'package:smart_trip_plannner/utils/go_router_refresh_stream.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),

    /// 🔐 Redirect unauthenticated users to login
    redirect: (context, state) {
      final user = authState.asData?.value;
      final isLoggingIn =
          state.uri.path == '/login' || state.uri.path == '/signup';

      if (user == null && !isLoggingIn) return '/login';
      if (user != null && isLoggingIn) return '/chat';
      return null;
    },

    /// 📦 App Routes
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
      GoRoute(
        path: '/saved-trips',
        builder: (context, state) => const SavedtripsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      /// 🚀 Load itinerary via AI (from Chat)
      GoRoute(
        path: '/loading-itinerary',
        builder: (context, state) {
          final prompt = state.extra as String;
          return LoadingItineraryScreen(prompt: prompt);
        },
      ),

      /// 📋 Show final itinerary screen
      GoRoute(
        path: '/itinerary',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return ItineraryScreen(data: data);
        },
      ),

      /// 💬 Follow-up Chat screen (prompt refinements)
      GoRoute(
        path: '/follow-up',
        builder: (context, state) {
          final data = state.extra as String;
          return FollowUpChatScreen(itineraryText: data);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
