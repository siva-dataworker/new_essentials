import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user_model.dart';
import '../utils/app_colors.dart';
import 'google_auth_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40.h),

              // Title
              Text(
                'Select Your Role',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 8.h),

              Text(
                'Choose your role to continue',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 40.h),

              // Role Cards - 2x2 Grid (Only Supervisor Active)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.9,
                padding: EdgeInsets.zero,
                children: [
                  _buildRoleCard(
                    context,
                    'Admin',
                    Icons.business_center_rounded,
                    AppColors.deepNavy,
                    UserRole.owner,
                    isEnabled: false,
                  ),
                  _buildRoleCard(
                    context,
                    'Supervisor',
                    Icons.construction_rounded,
                    AppColors.safetyOrange,
                    UserRole.supervisor,
                    isEnabled: true,
                  ),
                  _buildRoleCard(
                    context,
                    'Site Engineer',
                    Icons.engineering_rounded,
                    AppColors.engineerColor,
                    UserRole.siteEngineer,
                    isEnabled: false,
                  ),
                  _buildRoleCard(
                    context,
                    'Junior Accountant',
                    Icons.account_balance_wallet_rounded,
                    AppColors.accountantColor,
                    UserRole.accountant,
                    isEnabled: false,
                  ),
                ],
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    String title,
    IconData icon,
    Color roleColor,
    UserRole role, {
    required bool isEnabled,
  }) {
    final displayColor = isEnabled ? roleColor : Colors.grey.shade400;

    return Material(
      color: displayColor,
      borderRadius: BorderRadius.circular(16.r),
      elevation: isEnabled ? 2 : 0,
      shadowColor: isEnabled ? roleColor.withValues(alpha: 0.3) : Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? () => _navigateToGoogleAuth(context, role) : null,
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: isEnabled ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      icon,
                      size: 48.sp,
                      color: Colors.white.withValues(alpha: isEnabled ? 1.0 : 0.5),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: isEnabled ? 1.0 : 0.6),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!isEnabled)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'Coming Soon',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToGoogleAuth(BuildContext context, UserRole role) {
    // Navigate to Google Auth with selected role
    if (role == UserRole.supervisor) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GoogleAuthScreen(selectedRole: role),
        ),
      );
    }
  }
}
