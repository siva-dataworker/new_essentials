import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';
import 'admin_labour_count_screen.dart';
import 'admin_bills_view_screen.dart';
import 'admin_profit_loss_screen.dart';

class AdminSpecializedLoginScreen extends StatefulWidget {
  const AdminSpecializedLoginScreen({Key? key}) : super(key: key);

  @override
  State<AdminSpecializedLoginScreen> createState() =>
      _AdminSpecializedLoginScreenState();
}

class _AdminSpecializedLoginScreenState
    extends State<AdminSpecializedLoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  String _selectedAccessType = 'LABOUR_COUNT';
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final List<_AccessOption> _accessOptions = const [
    _AccessOption(
      key: 'LABOUR_COUNT',
      title: 'Labour Count View',
      description: 'View labour count data only',
      icon: Icons.people_alt_outlined,
      color: Color(0xFF2ECC71),
    ),
    _AccessOption(
      key: 'BILLS_VIEW',
      title: 'Bills Viewing',
      description: 'View material bills only',
      icon: Icons.receipt_long_outlined,
      color: Color(0xFFFF6B2C),
    ),
    _AccessOption(
      key: 'FULL_ACCOUNTS',
      title: 'Complete Accounts',
      description: 'Full P/L and accounts access',
      icon: Icons.account_balance_outlined,
      color: Color(0xFF0D1B2A),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
            CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/admin/specialized-login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _usernameController.text.trim(),
          'password': _passwordController.text,
          'access_type': _selectedAccessType,
        }),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        await _authService.clearAuthData();
        if (mounted) {
          Widget target;
          switch (_selectedAccessType) {
            case 'LABOUR_COUNT':
              target = const AdminLabourCountScreen();
              break;
            case 'BILLS_VIEW':
              target = const AdminBillsViewScreen();
              break;
            case 'FULL_ACCOUNTS':
              target = const AdminProfitLossScreen();
              break;
            default:
              target = const AdminLabourCountScreen();
          }
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => target));
        }
      } else {
        if (mounted) {
          _showError(data['error'] ?? 'Login failed');
        }
      }
    } catch (e) {
      if (mounted) _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Gradient background ──────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D1B2A), Color(0xFF1B3A5C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ── Decorative circles ───────────────────────────────
          Positioned(
            top: -50,
            right: -50,
            child: _circle(180, Colors.white.withValues(alpha: 0.04)),
          ),
          Positioned(
            top: 100,
            left: -30,
            child: _circle(120, Colors.white.withValues(alpha: 0.04)),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Specialized Access',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // balance back button
                    ],
                  ),
                ),

                // ── Logo ─────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.20),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/essential_homes_logo.png',
                    height: 110,
                    fit: BoxFit.contain,
                  ),
                ),

                // ── White scroll card ────────────────────────────
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(36),
                            topRight: Radius.circular(36),
                          ),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Section label
                                Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        gradient: AppColors.orangeGradient,
                                        borderRadius:
                                            BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Select Access Type',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.deepNavy,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Access type cards
                                ..._accessOptions.map((opt) =>
                                    _buildAccessCard(opt)),

                                const SizedBox(height: 24),

                                // Divider
                                Row(children: [
                                  Expanded(
                                      child: Divider(
                                          color: Colors.grey.shade200,
                                          thickness: 1.5)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Text('Credentials',
                                        style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12)),
                                  ),
                                  Expanded(
                                      child: Divider(
                                          color: Colors.grey.shade200,
                                          thickness: 1.5)),
                                ]),
                                const SizedBox(height: 20),

                                // Username
                                _buildInputField(
                                  controller: _usernameController,
                                  label: 'Username',
                                  icon: Icons.person_outline_rounded,
                                  validator: (v) =>
                                      (v == null || v.isEmpty)
                                          ? 'Enter username'
                                          : null,
                                ),
                                const SizedBox(height: 14),

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
                                          ? 'Enter password'
                                          : null,
                                ),
                                const SizedBox(height: 28),

                                // Login button
                                _buildLoginButton(),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
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
  }

  Widget _buildAccessCard(_AccessOption opt) {
    final selected = _selectedAccessType == opt.key;
    return GestureDetector(
      onTap: () => setState(() => _selectedAccessType = opt.key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? opt.color.withValues(alpha: 0.07)
              : const Color(0xFFF4F6FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? opt.color : const Color(0xFFE8ECF4),
            width: selected ? 2 : 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: opt.color.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: opt.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(opt.icon, color: opt.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opt.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: selected ? opt.color : AppColors.deepNavy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    opt.description,
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: selected
                  ? Icon(Icons.check_circle_rounded,
                      key: const ValueKey('check'), color: opt.color, size: 22)
                  : Icon(Icons.circle_outlined,
                      key: const ValueKey('empty'),
                      color: Colors.grey.shade300,
                      size: 22),
            ),
          ],
        ),
      ),
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
          fontSize: 15,
          color: AppColors.deepNavy,
          fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: AppColors.textSecondary, fontSize: 14),
        prefixIcon: Icon(icon,
            color: AppColors.deepNavy.withValues(alpha: 0.6), size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF4F6FA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
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

  Widget _buildLoginButton() {
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
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white))
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Access Dashboard',
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
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

class _AccessOption {
  final String key;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  const _AccessOption({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
