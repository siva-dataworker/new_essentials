import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import 'login_screen.dart';

class PendingApprovalScreen extends StatefulWidget {
  final String username;
  
  const PendingApprovalScreen({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  final _authService = AuthService();
  Timer? _timer;
  String _status = 'PENDING';
  String _message = 'Your account is pending admin approval';
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    // Auto-check status every 30 seconds
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkStatus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    if (_isChecking) return;
    
    setState(() => _isChecking = true);

    final result = await _authService.checkApprovalStatus(widget.username);

    setState(() => _isChecking = false);

    if (result['success']) {
      setState(() {
        _status = result['status'];
        _message = result['message'];
      });

      if (_status == 'APPROVED') {
        // Show success message and navigate to login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your account has been approved! Please login.'),
            backgroundColor: Colors.green,
          ),
        );
        
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        });
      } else if (_status == 'REJECTED') {
        // Show rejection message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your account has been rejected.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _status == 'APPROVED'
                        ? Colors.green.withOpacity(0.1)
                        : _status == 'REJECTED'
                            ? Colors.red.withOpacity(0.1)
                            : AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _status == 'APPROVED'
                        ? Icons.check_circle
                        : _status == 'REJECTED'
                            ? Icons.cancel
                            : Icons.hourglass_empty,
                    size: 80,
                    color: _status == 'APPROVED'
                        ? Colors.green
                        : _status == 'REJECTED'
                            ? Colors.red
                            : AppColors.primary,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Title
                Text(
                  _status == 'APPROVED'
                      ? 'Account Approved!'
                      : _status == 'REJECTED'
                          ? 'Account Rejected'
                          : 'Pending Approval',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Message
                Text(
                  _message,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48),
                
                // Check Status Button
                if (_status == 'PENDING')
                  ElevatedButton.icon(
                    onPressed: _isChecking ? null : _checkStatus,
                    icon: _isChecking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.refresh, color: Colors.white),
                    label: Text(
                      _isChecking ? 'Checking...' : 'Check Status',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Auto-refresh indicator
                if (_status == 'PENDING')
                  Text(
                    'Auto-checking every 30 seconds...',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                
                const SizedBox(height: 32),
                
                // Back to Login
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
