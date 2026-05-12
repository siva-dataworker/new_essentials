import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
            Icon(Icons.business_center, size: 64.sp, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              'Owner Dashboard',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8.h),
            Text('Coming soon...'),
          ],
        ),
      ),
    );
  }
}
