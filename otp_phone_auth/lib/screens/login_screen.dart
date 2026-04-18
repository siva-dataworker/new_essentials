import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../models/user_model.dart';
import 'registration_screen.dart';
import 'pending_approval_screen.dart';
import 'supervisor_dashboard_feed.dart';
import 'site_engineer_dashboard.dart';
import 'accountant_dashboard.dart';
import 'architect_dashboard.dart';
import 'owner_dashboard.dart';
import 'admin_dashboard.dart';
import 'client_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      final user = authProvider.currentUser!;
      final role = user['role'];
      
      // Debug logs removed for performance
      
      Widget dashboard;
      
      // Normalize role for comparison (case-insensitive)
      final roleNormalized = role?.toString().toLowerCase() ?? '';
      
      switch (roleNormalized) {
        case 'admin':
          dashboard = const AdminDashboard();
          break;
        case 'supervisor':
          dashboard = const SupervisorDashboardFeed();
          break;
        case 'site engineer':
          final u = UserModel(
            uid: user['id'],
            phoneNumber: user['phone'] ?? '',
            name: user['full_name'],
            email: user['email'],
            role: UserRole.siteEngineer,
            createdAt: DateTime.now(),
          );
          dashboard = SiteEngineerDashboard(user: u);
          break;
        case 'accountant':
          final u = UserModel(
            uid: user['id'],
            phoneNumber: user['phone'] ?? '',
            name: user['full_name'],
            email: user['email'],
            role: UserRole.accountant,
            createdAt: DateTime.now(),
          );
          dashboard = AccountantDashboard(user: u);
          break;
        case 'architect':
          final u = UserModel(
            uid: user['id'],
            phoneNumber: user['phone'] ?? '',
            name: user['full_name'],
            email: user['email'],
            role: UserRole.architect,
            createdAt: DateTime.now(),
          );
          dashboard = ArchitectDashboard(user: u);
          break;
        case 'owner':
          final u = UserModel(
            uid: user['id'],
            phoneNumber: user['phone'] ?? '',
            name: user['full_name'],
            email: user['email'],
            role: UserRole.owner,
            createdAt: DateTime.now(),
          );
          dashboard = OwnerDashboard(user: u);
          break;
        case 'client':
          dashboard = const ClientDashboard();
          break;
        default:
          dashboard = const SupervisorDashboardFeed();
      }
      
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => dashboard));
    } else {
      if (authProvider.error?.contains('pending') == true ||
          authProvider.error?.contains('PENDING') == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PendingApprovalScreen(
                username: _usernameController.text.trim()),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(authProvider.error ?? 'Login failed'),
          backgroundColor: AppColors.statusOverdue,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Scaffold(
          body: Stack(
            children: [
              // ── Gradient background ──────────────────────────
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D1B2A), Color(0xFF1B3A5C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // ── Decorative circles ───────────────────────────
              Positioned(
                top: -60,
                right: -60,
                child: _circle(200, Colors.white.withValues(alpha: 0.04)),
              ),
              Positioned(
                top: 80,
                left: -40,
                child: _circle(140, Colors.white.withValues(alpha: 0.04)),
              ),

              // ── Main content ─────────────────────────────────
              SafeArea(
                child: Column(
                  children: [
                    // Logo area
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo container with frosted look
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/images/essential_homes_logo.png',
                                height: 150,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Welcome Back',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Sign in to continue',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── White card ───────────────────────────────
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(36),
                              topRight: Radius.circular(36),
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Username
                                _buildInputField(
                                  controller: _usernameController,
                                  label: 'Username',
                                  icon: Icons.person_outline_rounded,
                                  validator: (v) =>
                                      (v == null || v.isEmpty)
                                          ? 'Enter your username'
                                          : null,
                                ),
                                const SizedBox(height: 16),

                                // Password
                                _buildInputField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  icon: Icons.lock_outline_rounded,
                                  obscure: _obscurePassword,
                                  suffix: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword),
                                  ),
                                  validator: (v) =>
                                      (v == null || v.isEmpty)
                                          ? 'Enter your password'
                                          : null,
                                ),
                                const SizedBox(height: 28),

                                // Login button
                                _buildLoginButton(authProvider),

                                const SizedBox(height: 20),

                                // Register link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const RegistrationScreen()),
                                      ),
                                      child: const Text(
                                        'Register',
                                        style: TextStyle(
                                          color: AppColors.deepNavy,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(
          fontSize: 15, color: AppColors.deepNavy, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: AppColors.textSecondary, fontSize: 14),
        prefixIcon:
            Icon(icon, color: AppColors.deepNavy.withValues(alpha: 0.6), size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF4F6FA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: Color(0xFFE8ECF4), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: AppColors.deepNavy, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: AppColors.statusOverdue, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: AppColors.statusOverdue, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildLoginButton(AuthProvider authProvider) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: authProvider.isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        child: authProvider.isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white))
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 20),
                ],
              ),
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      );
}
