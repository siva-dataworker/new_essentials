import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'phone_auth_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? name;
  final int? age;
  final String? email;
  final String? address;

  const HomeScreen({
    super.key,

    this.name,
    this.age,
    this.email,
    this.address,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _signOut(BuildContext context) async {
    // Mock sign out
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PhoneAuthScreen(),
        ),
      );
    }
  }

  void _editProfile() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ProfileFormScreen(
    //       phoneNumber: widget.name ?? '',
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final phoneNumber = widget.name ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.check_circle,
              size: 80.sp,
              color: Colors.green,
            ),
            SizedBox(height: 24.h),
            Text(
              'Welcome, ${widget.name ?? 'User'}! 👋',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),

            // Profile Card
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Profile Information',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: _editProfile,
                          tooltip: 'Edit Profile',
                        ),
                      ],
                    ),
                    const Divider(),
                    SizedBox(height: 16.h),
                    _buildInfoRow(
                      Icons.person,
                      'Name',
                      widget.name ?? 'Not set',
                    ),
                    SizedBox(height: 12.h),
                    _buildInfoRow(
                      Icons.phone,
                      'Phone',
                      phoneNumber,
                    ),
                    SizedBox(height: 12.h),
                    _buildInfoRow(
                      Icons.cake,
                      'Age',
                      widget.age?.toString() ?? 'Not set',
                    ),
                    if (widget.email != null && widget.email!.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      _buildInfoRow(
                        Icons.email,
                        'Email',
                        widget.email!,
                      ),
                    ],
                    if (widget.address != null && widget.address!.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      _buildInfoRow(
                        Icons.location_on,
                        'Address',
                        widget.address!,
                      ),
                    ],
                    SizedBox(height: 12.h),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Member Since',
                      _formatDate(DateTime.now()),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Edit Profile Button
            OutlinedButton.icon(
              onPressed: _editProfile,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
            ),
            SizedBox(height: 12.h),

            // Sign Out Button
            ElevatedButton.icon(
              onPressed: () => _signOut(context),
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20.sp, color: Colors.blue),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}
