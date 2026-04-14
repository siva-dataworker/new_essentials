import 'package:flutter/material.dart';
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Title
                const Text(
                  'Select Your Role',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepNavy,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                const Text(
                  'Choose your role to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
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
      borderRadius: BorderRadius.circular(16),
      elevation: isEnabled ? 2 : 0,
      shadowColor: isEnabled ? roleColor.withValues(alpha: 0.3) : Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? () => _navigateToGoogleAuth(context, role) : null,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: isEnabled ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 48,
                      color: Colors.white.withValues(alpha: isEnabled ? 1.0 : 0.5),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Coming Soon',
                    style: TextStyle(
                      fontSize: 10,
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
