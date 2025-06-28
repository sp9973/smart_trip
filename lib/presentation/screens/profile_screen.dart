import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    // Sample token data - replace with actual logic if needed
    const int requestTokens = 100;
    const int responseTokens = 75;
    const int maxTokens = 1000;
    const double cost = 0.07;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), leading: const BackButton()),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile header
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green.shade700,
                        radius: 24,
                        child: Text(
                          user?.displayName?.substring(0, 1).toUpperCase() ??
                              "S",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? "prashant",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user?.email ?? "solo@gmail.com",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Request Tokens
                  const Text("Request Tokens"),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: requestTokens / maxTokens,
                    backgroundColor: Colors.grey[300],
                    color: Colors.green,
                  ),
                  const SizedBox(height: 4),
                  Text("$requestTokens/$maxTokens"),

                  const SizedBox(height: 16),

                  // Response Tokens
                  const Text("Response Tokens"),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: responseTokens / maxTokens,
                    backgroundColor: Colors.grey[300],
                    color: Colors.red,
                  ),
                  const SizedBox(height: 4),
                  Text("$responseTokens/$maxTokens"),

                  const SizedBox(height: 16),

                  // Cost
                  const Text("Total Cost"),
                  const SizedBox(height: 4),
                  Text(
                    "\$${cost.toStringAsFixed(2)} USD",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Logout button
            ElevatedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text("Log Out"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red.shade800,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
