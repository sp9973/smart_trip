import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserHeader extends StatelessWidget {
  const UserHeader({super.key});

  String _getInitialsFromEmail(String email) {
    final localPart = email.split('@').first;
    final nameParts = localPart.split(RegExp(r'[._]'));
    final initials =
        nameParts
            .where((part) => part.isNotEmpty)
            .map((part) => part[0].toUpperCase())
            .join();
    return initials.length > 2 ? initials.substring(0, 2) : initials;
  }

  String _getUsernameFromEmail(String email) {
    final localPart = email.split('@').first;
    return localPart[0].toUpperCase() + localPart.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';
    final initials = _getInitialsFromEmail(email);
    final name = _getUsernameFromEmail(email);

    return Row(
      children: [
        Expanded(
          child: Text(
            "Hey $name 👋",
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => context.go('/profile'),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.green.shade800,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
