import 'package:flutter/material.dart';
import 'phone_auth_screen.dart';
import 'profile_form_screen.dart';

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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome, ${widget.name ?? 'User'}! 👋',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Profile Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Profile Information',
                          style: TextStyle(
                            fontSize: 20,
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
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.person,
                      'Name',
                      widget.name ?? 'Not set',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.phone,
                      'Phone',
                      phoneNumber,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.cake,
                      'Age',
                      widget.age?.toString() ?? 'Not set',
                    ),
                    if (widget.email != null && widget.email!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.email,
                        'Email',
                        widget.email!,
                      ),
                    ],
                    if (widget.address != null && widget.address!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.location_on,
                        'Address',
                        widget.address!,
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Member Since',
                      _formatDate(DateTime.now()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Edit Profile Button
            OutlinedButton.icon(
              onPressed: _editProfile,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            
            // Sign Out Button
            ElevatedButton.icon(
              onPressed: () => _signOut(context),
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
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
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
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
