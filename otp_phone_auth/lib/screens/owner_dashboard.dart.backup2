import 'package:flutter/material.dart';
import '../models/user_model.dart';

class OwnerDashboard extends StatelessWidget {
  final UserModel user;

  const OwnerDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_center, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Owner Dashboard',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Coming soon...'),
          ],
        ),
      ),
    );
  }
}
