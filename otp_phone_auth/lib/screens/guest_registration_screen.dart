import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../services/push_notification_service.dart';

const kGuestVisitorsKey = 'guest_visitors_local';

class GuestRegistrationScreen extends StatefulWidget {
  const GuestRegistrationScreen({super.key});

  @override
  State<GuestRegistrationScreen> createState() =>
      _GuestRegistrationScreenState();
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

  late AnimationController _heroCtrl;
  late AnimationController _cardCtrl;
  late Animation<double> _heroFade;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;

  static const _navy = Color(0xFF0D1B2A);
  static const _navyMid = Color(0xFF1B3A5C);
  static const _gold = Color(0xFFF59E0B);
  static const _green = Color(0xFF10B981);

  static const _sites = [
    (
      name: 'Sunrise Residency – Phase 1',
      location: 'Porur, Chennai',
      status: 'Completed',
      detail: '64 premium apartments handed over',
      area: '1,200 – 1,800 sq ft',
      year: '2023',
      progress: 1.0,
      gradient: [Color(0xFF0D1B2A), Color(0xFF1B3A5C)],
      icon: Icons.apartment_rounded,
    ),
    (
      name: 'Sunrise Residency – Phase 2',
      location: 'Porur, Chennai',
      status: 'In Progress',
      detail: 'Block B & C structural work ongoing',
      area: '1,400 – 2,100 sq ft',
      year: '2025',
      progress: 0.62,
      gradient: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
      icon: Icons.construction_rounded,
    ),
    (
      name: 'Metro Commercial Complex',
      location: 'Anna Nagar, Chennai',
      status: 'Planning',
      detail: 'G+12 commercial tower, foundation survey done',
      area: '800 – 3,500 sq ft',
      year: '2026',
      progress: 0.12,
      gradient: [Color(0xFF78350F), Color(0xFFD97706)],
      icon: Icons.business_rounded,
    ),
    (
      name: 'Green Valley Villas',
      location: 'OMR, Chennai',
      status: 'Completed',
      detail: '48 independent villas with landscaped garden',
      area: '2,400 – 3,200 sq ft',
      year: '2022',
      progress: 1.0,
      gradient: [Color(0xFF064E3B), Color(0xFF059669)],
      icon: Icons.villa_rounded,
    ),
    (
      name: 'Lakeview Apartments',
      location: 'Velachery, Chennai',
      status: 'In Progress',
      detail: 'G+18 tower, 30th floor slab casting complete',
      area: '1,050 – 1,650 sq ft',
      year: '2025',
      progress: 0.78,
      gradient: [Color(0xFF0C4A6E), Color(0xFF0EA5E9)],
      icon: Icons.domain_rounded,
    ),
    (
      name: 'Heritage Tower – Block A',
      location: 'T. Nagar, Chennai',
      status: 'Completed',
      detail: '120 luxury residences, IGBC Gold certified',
      area: '1,800 – 4,000 sq ft',
      year: '2021',
      progress: 1.0,
      gradient: [Color(0xFF3B0764), Color(0xFF7C3AED)],
      icon: Icons.location_city_rounded,
    ),
    (
      name: 'Smart City Enclave',
      location: 'Sholinganallur, Chennai',
      status: 'Planning',
      detail: 'Smart-home integrated township, 200 units',
      area: '1,100 – 2,600 sq ft',
      year: '2026',
      progress: 0.08,
      gradient: [Color(0xFF7F1D1D), Color(0xFFDC2626)],
      icon: Icons.hub_rounded,
    ),
    (
      name: 'Palm Grove Residences',
      location: 'Nungambakkam, Chennai',
      status: 'In Progress',
      detail: 'Luxury podium-level pool & sky lounge',
      area: '2,000 – 5,000 sq ft',
      year: '2025',
      progress: 0.45,
      gradient: [Color(0xFF134E4A), Color(0xFF0D9488)],
      icon: Icons.holiday_village_rounded,
    ),
    (
      name: 'Elite Business Park',
      location: 'Guindy, Chennai',
      status: 'Completed',
      detail: 'Grade-A offices, 350+ companies operational',
      area: '500 – 10,000 sq ft',
      year: '2020',
      progress: 1.0,
      gradient: [Color(0xFF1F2937), Color(0xFF374151)],
      icon: Icons.corporate_fare_rounded,
    ),
    (
      name: 'Royal Heights – Phase 1',
      location: 'Adyar, Chennai',
      status: 'In Progress',
      detail: 'Exclusive penthouses & sea-view residences',
      area: '3,200 – 8,000 sq ft',
      year: '2026',
      progress: 0.35,
      gradient: [Color(0xFF78350F), Color(0xFFF59E0B)],
      icon: Icons.home_work_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _cardFade = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut));
    _heroCtrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _purposeCtrl.dispose();
    _heroCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  String _generateRef() {
    final rand = Random();
    return 'GV${1000 + rand.nextInt(9000)}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final ref = _generateRef();
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    try {
      // Save locally
      final entry = {
        'name': name,
        'phone': phone,
        'purpose': _purposeCtrl.text.trim(),
        'visit_time': DateTime.now().toIso8601String(),
        'ref': ref,
        'is_new': true,
      };
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getString(kGuestVisitorsKey);
      final List<dynamic> list =
          existing != null ? json.decode(existing) as List : [];
      list.insert(0, entry);
      await prefs.setString(kGuestVisitorsKey, json.encode(list));

      // Fire-and-forget: notify admin (errors logged internally)
      NotificationService().sendGuestCheckinNotification(
        guestName: name,
        guestPhone: phone,
        ref: ref,
      ).catchError((e) => debugPrint('[Guest] notify error: $e'));

      PushNotificationService().showLocalNotification(
        title: '🔔 New Guest Check-In',
        body: '$name ($phone) just checked in — Ref: $ref',
      ).catchError((e) => debugPrint('[Guest] local notify error: $e'));

    } catch (e) {
      debugPrint('Guest submit error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isSubmitted = true;
          _refNumber = ref;
        });
        _cardCtrl.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(),
          SliverToBoxAdapter(
            child: _isSubmitted ? _buildPostCheckin() : _buildFormSection(),
          ),
        ],
      ),
    );
  }

  // ── Sliver header ──────────────────────────────────────────────
  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 220.h,
      pinned: true,
      stretch: true,
      backgroundColor: _navy,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 16.sp),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_navy, _navyMid, Color(0xFF1E4976)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: FadeTransition(
            opacity: _heroFade,
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 16.h),
                  // Logo
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 16.r,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/essential_homes_logo.png',
                      height: 52.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    _isSubmitted
                        ? 'Welcome, ${_nameCtrl.text.trim()}!'
                        : 'Guest Check-In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _isSubmitted
                        ? 'Ref: $_refNumber  ·  Essential Homes'
                        : 'Essential Homes Construction',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Form section (pre-submission) ─────────────────────────────
  Widget _buildFormSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 32.h),
      child: Column(
        children: [
          // Step indicator
          _buildStepBanner(),
          SizedBox(height: 18.h),

          // Form card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: _navy.withValues(alpha: 0.08),
                  blurRadius: 24.r,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: EdgeInsets.all(22.r),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionLabel('Visitor Information', Icons.badge_outlined),
                  SizedBox(height: 18.h),
                  _buildField(
                    controller: _nameCtrl,
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    icon: Icons.person_outline_rounded,
                    inputType: TextInputType.name,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter your name'
                        : null,
                  ),
                  SizedBox(height: 14.h),
                  _buildField(
                    controller: _phoneCtrl,
                    label: 'Phone Number',
                    hint: '10-digit mobile number',
                    icon: Icons.phone_outlined,
                    inputType: TextInputType.phone,
                    maxLength: 10,
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (v.trim().length < 10) {
                        return 'Enter a valid 10-digit number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 14.h),
                  _buildField(
                    controller: _purposeCtrl,
                    label: 'Purpose of Visit (optional)',
                    hint: 'e.g. Site inspection, Meeting',
                    icon: Icons.notes_outlined,
                    inputType: TextInputType.text,
                    maxLines: 2,
                  ),
                  SizedBox(height: 24.h),
                  _buildCheckInButton(),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Company teaser
          _buildCompanyTeaser(),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildStepBanner() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_gold.withValues(alpha: 0.12), _gold.withValues(alpha: 0.04)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(7.r),
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.info_outline_rounded, color: _gold, size: 16.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Fill in your details below to complete your check-in.',
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF92400E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInButton() {
    return Container(
      height: 54.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_navy, _navyMid],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.4),
            blurRadius: 14.r,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r)),
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
                  Icon(Icons.how_to_reg_rounded, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text('Check In',
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3)),
                ],
              ),
      ),
    );
  }

  Widget _buildCompanyTeaser() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.06),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: _navy.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.business_rounded, color: _navy, size: 22.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Essential Homes Construction',
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: _navy)),
                SizedBox(height: 3.h),
                Text('10 active projects across Chennai',
                    style:
                        TextStyle(fontSize: 11.sp, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Row(
            children: [
              Icon(Icons.star_rounded, color: _gold, size: 14.sp),
              SizedBox(width: 3.w),
              Text('4.9',
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: _navy)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Post check-in view ─────────────────────────────────────────
  Widget _buildPostCheckin() {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    return FadeTransition(
      opacity: _cardFade,
      child: SlideTransition(
        position: _cardSlide,
        child: Padding(
          padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 40.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Success card ──────────────────────────────
              _buildSuccessBanner(timeStr, dateStr),
              SizedBox(height: 20.h),

              // ── Visit details ─────────────────────────────
              _buildVisitDetails(timeStr, dateStr),
              SizedBox(height: 24.h),

              // ── Site gallery ──────────────────────────────
              _sectionLabel('Our Project Sites', Icons.photo_library_rounded),
              SizedBox(height: 4.h),
              Text(
                'Essential Homes – 10 Premium Developments',
                style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
              ),
              SizedBox(height: 14.h),
              ...List.generate(_sites.length, (i) => _buildSiteCard(i)),

              SizedBox(height: 20.h),

              // ── Contact ───────────────────────────────────
              _buildContactCard(),
              SizedBox(height: 20.h),

              // ── New check-in ──────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isSubmitted = false;
                      _nameCtrl.clear();
                      _phoneCtrl.clear();
                      _purposeCtrl.clear();
                    });
                    _cardCtrl.reset();
                    _heroCtrl.forward(from: 0);
                  },
                  icon: Icon(Icons.refresh_rounded, size: 18.sp),
                  label: Text('New Check-In',
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _navy,
                    side: BorderSide(color: _navy.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessBanner(String timeStr, String dateStr) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF065F46), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withValues(alpha: 0.3),
            blurRadius: 18.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.all(22.r),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: Colors.white, size: 32.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            'Welcome, ${_nameCtrl.text.trim()}!',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6.h),
          Text(
            'You are checked in. Our team has been notified.',
            style: TextStyle(color: Colors.white70, fontSize: 12.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 9.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.confirmation_num_outlined,
                    color: Colors.white, size: 14.sp),
                SizedBox(width: 6.w),
                Text(
                  '$_refNumber  ·  $timeStr  ·  $dateStr',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitDetails(String timeStr, String dateStr) {
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
          _cardHeader('Your Visit Details', Icons.badge_outlined),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            child: Column(
              children: [
                _detailRow(Icons.person_outline_rounded, 'Name',
                    _nameCtrl.text.trim()),
                _detailRow(Icons.phone_outlined, 'Phone',
                    _phoneCtrl.text.trim()),
                if (_purposeCtrl.text.trim().isNotEmpty)
                  _detailRow(Icons.notes_outlined, 'Purpose',
                      _purposeCtrl.text.trim()),
                _detailRow(Icons.access_time_rounded, 'Check-in',
                    '$timeStr on $dateStr'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiteCard(int i) {
    final site = _sites[i];
    final statusColor = site.status == 'Completed'
        ? _green
        : site.status == 'In Progress'
            ? const Color(0xFF2563EB)
            : _gold;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.07),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Gradient image panel
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18.r),
              bottomLeft: Radius.circular(18.r),
            ),
            child: Container(
              width: 100.w,
              height: 120.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: site.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Grid texture
                  Opacity(
                    opacity: 0.07,
                    child: GridPaper(
                      color: Colors.white,
                      interval: 20,
                      subdivisions: 1,
                      child: const SizedBox.expand(),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(site.icon, color: Colors.white, size: 28.sp),
                        SizedBox(height: 6.h),
                        Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Info panel
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 12.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status + year row
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          site.status,
                          style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                              color: statusColor),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        site.year,
                        style: TextStyle(
                            fontSize: 10.sp, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  // Name
                  Text(
                    site.name,
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: _navy,
                        height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),

                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 11.sp, color: Colors.grey.shade400),
                      SizedBox(width: 3.w),
                      Text(site.location,
                          style: TextStyle(
                              fontSize: 10.sp, color: Colors.grey.shade400)),
                    ],
                  ),
                  SizedBox(height: 5.h),

                  // Detail
                  Text(
                    site.detail,
                    style: TextStyle(
                        fontSize: 10.5.sp,
                        color: Colors.grey.shade600,
                        height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),

                  // Progress bar for In Progress / Planning
                  if (site.status != 'Completed') ...[
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: LinearProgressIndicator(
                              value: site.progress,
                              minHeight: 4.h,
                              backgroundColor:
                                  statusColor.withValues(alpha: 0.12),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(statusColor),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '${(site.progress * 100).toInt()}%',
                          style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                              color: statusColor),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            size: 12.sp, color: _green),
                        SizedBox(width: 4.w),
                        Text('Delivered',
                            style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: _green)),
                        const Spacer(),
                        Text(site.area,
                            style: TextStyle(
                                fontSize: 9.sp, color: Colors.grey.shade400)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_navy, _navyMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.3),
            blurRadius: 14.r,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(18.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.support_agent_rounded,
                    color: Colors.white, size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Text('Contact & Office Hours',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 14.h),
          _contactRow(Icons.location_on_outlined,
              '12/3 Construction Nagar, Chennai – 600 001'),
          _contactRow(Icons.phone_outlined, '+91 98765 43210'),
          _contactRow(Icons.access_time_outlined, 'Mon – Sat: 9:00 AM – 6:00 PM'),
          _contactRow(Icons.email_outlined, 'info@ayotta-tech.com'),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 9.h),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: Colors.white60),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 11.5.sp,
                    color: Colors.white.withValues(alpha: 0.85))),
          ),
        ],
      ),
    );
  }

  // ── Shared helpers ─────────────────────────────────────────────
  Widget _sectionLabel(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(7.r),
          decoration: BoxDecoration(
            color: _navy.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: _navy, size: 18.sp),
        ),
        SizedBox(width: 10.w),
        Text(title,
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: _navy)),
      ],
    );
  }

  Widget _cardHeader(String title, IconData icon) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 13.h, 16.w, 11.h),
      decoration: BoxDecoration(
        color: _navy.withValues(alpha: 0.04),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: _navy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: _navy, size: 16.sp),
          ),
          SizedBox(width: 10.w),
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                  color: _navy)),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15.sp, color: const Color(0xFF9CA3AF)),
          SizedBox(width: 8.w),
          Expanded(
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: '$label:  ',
                    style: TextStyle(
                        fontSize: 11.5.sp,
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500)),
                TextSpan(
                    text: value,
                    style: TextStyle(
                        fontSize: 12.5.sp,
                        color: _navy,
                        fontWeight: FontWeight.w600)),
              ]),
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
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      inputFormatters: formatters,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      style: TextStyle(fontSize: 14.sp, color: _navy, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon:
            Icon(icon, color: _navy.withValues(alpha: 0.45), size: 20.sp),
        labelStyle:
            TextStyle(color: _navy.withValues(alpha: 0.55), fontSize: 13.sp),
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
        errorStyle: TextStyle(color: Colors.red, fontSize: 11.5.sp),
        filled: true,
        fillColor: const Color(0xFFF8F9FC),
        counterText: maxLength != null ? '' : null,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: _navy, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Colors.red, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Colors.red, width: 1.8),
        ),
      ),
    );
  }
}
