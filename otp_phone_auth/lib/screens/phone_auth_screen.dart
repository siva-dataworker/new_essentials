import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../utils/app_colors.dart';
import 'otp_verification_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  final String roleTitle;

  const PhoneAuthScreen({
    super.key,
    this.roleTitle = 'Phone Verification',
  });

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _completePhoneNumber = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Mock OTP sending - simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);

      // Navigate to OTP verification with mock verification ID
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationScreen(
            verificationId: 'mock-verification-id',
            phoneNumber: _completePhoneNumber,
          ),
        ),
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Back Button
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10.r,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.deepNavy),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24.r),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo/Icon - Professional Navy
                        Container(
                          padding: EdgeInsets.all(24.r),
                          decoration: BoxDecoration(
                            color: AppColors.deepNavy,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.deepNavy.withValues(alpha: 0.15),
                                blurRadius: 12.r,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.phone_android,
                            size: 64.sp,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 32.h),

                        // Welcome Text - Professional
                        Text(
                          widget.roleTitle,
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12.h),
                        SizedBox(height: 32.h),

                        // Phone Input Card - Clean White
                        Container(
                          padding: EdgeInsets.all(24.r),
                          decoration: BoxDecoration(
                            color: AppColors.cleanWhite,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: AppColors.borderColor,
                              width: 0.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.deepNavy.withValues(alpha: 0.08),
                                blurRadius: 8.r,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Enter Your Phone Number',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'We will send you a verification code',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 24.h),

                              // Phone Field - Professional
                              IntlPhoneField(
                                controller: _phoneController,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16.sp,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Phone Number',
                                  hintText: '9876543210',
                                ),
                                initialCountryCode: 'IN',
                                dropdownTextStyle: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                                dropdownIconPosition: IconPosition.trailing,
                                onChanged: (phone) {
                                  _completePhoneNumber = phone.completeNumber;
                                },
                              ),
                              SizedBox(height: 24.h),

                              // Send OTP Button - Professional
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _sendOTP,
                                  child: _isLoading
                                      ? SizedBox(
                                          height: 20.h,
                                          width: 20.w,
                                          child: const CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text('Send OTP'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Info Text
                        Text(
                          'By continuing, you agree to our Terms & Privacy Policy',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
