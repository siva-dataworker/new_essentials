import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences key shared with admin dashboard
const kGuestVisitorsKey = 'guest_visitors_local';

class GuestRegistrationScreen extends StatefulWidget {
  const GuestRegistrationScreen({super.key});

  @override
  State<GuestRegistrationScreen> createState() => _GuestRegistrationScreenState();
}

class _GuestRegistrationScreenState extends State<GuestRegistrationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();

  bool _isSubmitting = false;
  bool _isSubmitted = false;
  String _refNumber = '';

  late AnimationController _welcomeCtrl;
  late Animation<double> _welcomeFade;
  late Animation<Offset> _welcomeSlide;

  static const _navy = Color(0xFF1A1A2E);
  static const _accent = Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    _welcomeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _welcomeFade = CurvedAnimation(parent: _welcomeCtrl, curve: Curves.easeOut);
    _welcomeSlide =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
            .animate(CurvedAnimation(parent: _welcomeCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _purposeCtrl.dispose();
    _welcomeCtrl.dispose();
    super.dispose();
  }

  String _generateRef() {
    final rand = Random();
    final num = 1000 + rand.nextInt(9000);
    return 'GV$num';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final ref = _generateRef();
    final now = DateTime.now().toIso8601String();
    final entry = {
      'name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'purpose': _purposeCtrl.text.trim(),
      'visit_time': now,
      'ref': ref,
      'is_new': true,
    };

    // ── Step 1: Save to SharedPreferences (always works, no backend needed) ──
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getString(kGuestVisitorsKey);
      final List<dynamic> list =
          existing != null ? json.decode(existing) as List : [];
      list.insert(0, entry); // newest first
      await prefs.setString(kGuestVisitorsKey, json.encode(list));
    } catch (e) {
      debugPrint('SharedPreferences save error: $e');
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _isSubmitted = true;
        _refNumber = ref;
      });
      _welcomeCtrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200.h,
            pinned: true,
            backgroundColor: _navy,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_navy, Color(0xFF16213E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 20.h),
                      Container(
                        width: 72.w,
                        height: 72.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3), width: 2),
                        ),
                        child: Icon(Icons.person_add_alt_1,
                            color: Colors.white, size: 36.sp),
                      ),
                      SizedBox(height: 12.h),
                      Text('Guest Check-In',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 4.h),
                      Text('Welcome — please register your visit',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13.sp)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                children: [
                  // ── Form card ────────────────────────────────
                  if (!_isSubmitted) _buildFormCard(),

                  // ── Welcome card (after submission) ──────────
                  if (_isSubmitted)
                    FadeTransition(
                      opacity: _welcomeFade,
                      child: SlideTransition(
                          position: _welcomeSlide, child: _buildWelcomeCard()),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.08),
            blurRadius: 20.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.all(24.r),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: _navy.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.assignment_ind, color: _navy, size: 20.sp),
                ),
                SizedBox(width: 10.w),
                Text('Visitor Details',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: _navy)),
              ],
            ),
            SizedBox(height: 20.h),

            // Name
            _buildField(
              controller: _nameCtrl,
              label: 'Full Name',
              hint: 'Enter your full name',
              icon: Icons.person_outline,
              inputType: TextInputType.name,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
            ),
            SizedBox(height: 14.h),

            // Phone
            _buildField(
              controller: _phoneCtrl,
              label: 'Phone Number',
              hint: 'Enter your phone number',
              icon: Icons.phone_outlined,
              inputType: TextInputType.phone,
              formatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter your phone number';
                if (v.trim().length < 10) return 'Enter a valid phone number';
                return null;
              },
            ),
            SizedBox(height: 14.h),

            // Purpose
            _buildField(
              controller: _purposeCtrl,
              label: 'Purpose of Visit (optional)',
              hint: 'e.g. Site inspection, Meeting',
              icon: Icons.notes_outlined,
              inputType: TextInputType.text,
              maxLines: 2,
            ),
            SizedBox(height: 24.h),

            // Submit button
            SizedBox(
              height: 52.h,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _navy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 22.w,
                        height: 22.h,
                        child: const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.how_to_reg, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text('Check In',
                              style: TextStyle(
                                  fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    return Column(
      children: [
        // ── Success banner ─────────────────────────────────
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF059669), Color(0xFF047857)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF059669).withValues(alpha: 0.3),
                blurRadius: 14.r,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 52.sp),
              SizedBox(height: 10.h),
              Text(
                'Welcome, ${_nameCtrl.text.trim()}!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6.h),
              Text('You are checked in. Admin has been notified.',
                  style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                  textAlign: TextAlign.center),
              SizedBox(height: 12.h),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Ref: $_refNumber  ·  $timeStr  ·  $dateStr',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // ── Visitor details recap ──────────────────────────
        _infoCard(
          title: 'Your Visit Details',
          icon: Icons.badge_outlined,
          children: [
            _infoRow(Icons.person_outline, 'Name', _nameCtrl.text.trim()),
            _infoRow(Icons.phone_outlined, 'Phone', _phoneCtrl.text.trim()),
            if (_purposeCtrl.text.trim().isNotEmpty)
              _infoRow(Icons.notes_outlined, 'Purpose', _purposeCtrl.text.trim()),
            _infoRow(Icons.access_time, 'Check-in Time', '$timeStr on $dateStr'),
          ],
        ),
        SizedBox(height: 16.h),

        // ── Company overview (test data) ───────────────────
        _infoCard(
          title: 'About Our Projects',
          icon: Icons.business,
          children: const [
            _ProjectItem(
              name: 'Sunrise Residency – Phase 2',
              status: 'In Progress',
              statusColor: Color(0xFF059669),
              detail: 'Block B & C structural work ongoing',
            ),
            _ProjectItem(
              name: 'Metro Commercial Complex',
              status: 'Planning',
              statusColor: Color(0xFFD97706),
              detail: 'Foundation survey completed',
            ),
            _ProjectItem(
              name: 'Green Valley Villas',
              status: 'Completed',
              statusColor: Color(0xFF1A1A2E),
              detail: '48 units handed over to clients',
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // ── Contact info (test data) ───────────────────────
        _infoCard(
          title: 'Contact & Office Hours',
          icon: Icons.info_outline,
          children: [
            _infoRow(Icons.location_on_outlined, 'Office',
                '12/3 Construction Nagar, Chennai – 600 001'),
            _infoRow(Icons.phone_outlined, 'Helpline', '+91 98765 43210'),
            _infoRow(Icons.access_time, 'Office Hours',
                'Mon – Sat: 9:00 AM – 6:00 PM'),
            _infoRow(Icons.email_outlined, 'Email', 'info@ayotta-tech.com'),
          ],
        ),
        SizedBox(height: 16.h),

        // ── Check-in again button ──────────────────────────
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _isSubmitted = false;
                _nameCtrl.clear();
                _phoneCtrl.clear();
                _purposeCtrl.clear();
              });
              _welcomeCtrl.reset();
            },
            icon: Icon(Icons.refresh, size: 18.sp),
            label: const Text('New Check-In'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _navy,
              side: const BorderSide(color: _navy),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        ),
        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _infoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.07),
            blurRadius: 14.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
            decoration: BoxDecoration(
              color: _navy.withValues(alpha: 0.04),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(18.r)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(7.r),
                  decoration: BoxDecoration(
                    color: _navy.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, color: _navy, size: 18.sp),
                ),
                SizedBox(width: 10.w),
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: _navy)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: const Color(0xFF6B7280)),
          SizedBox(width: 8.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                      text: '$label: ',
                      style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w500)),
                  TextSpan(
                      text: value,
                      style: TextStyle(
                          fontSize: 13.sp,
                          color: _navy,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType inputType,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      inputFormatters: formatters,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(fontSize: 14.sp, color: _navy),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _navy.withValues(alpha: 0.5), size: 20.sp),
        labelStyle:
            TextStyle(color: _navy.withValues(alpha: 0.6), fontSize: 13.sp),
        hintStyle:
            TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
        filled: true,
        fillColor: const Color(0xFFF8F9FC),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: _navy, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}

// ── Reusable project item ─────────────────────────────────────

class _ProjectItem extends StatelessWidget {
  final String name;
  final String status;
  final Color statusColor;
  final String detail;

  const _ProjectItem({
    required this.name,
    required this.status,
    required this.statusColor,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: statusColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 8.w,
            height: 8.h,
            decoration: BoxDecoration(
                color: statusColor, shape: BoxShape.circle),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                              color: const Color(0xFF1A1A2E))),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(status,
                          style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: statusColor)),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(detail,
                    style: TextStyle(
                        fontSize: 11.sp, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
