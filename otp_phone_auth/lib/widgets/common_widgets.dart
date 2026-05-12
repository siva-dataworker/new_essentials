import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/theme_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Common UI components with consistent theming
class CommonWidgets {

  /// Standard App Bar with consistent theming
  static AppBar buildAppBar(
    BuildContext context, {
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = true,
    PreferredSizeWidget? bottom,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return context.read<ThemeProvider>().buildAppBar(
      title: title,
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      bottom: bottom,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );
  }

  /// Standard Card with consistent theming
  static Widget buildCard(
    BuildContext context, {
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    double? elevation,
    BorderRadius? borderRadius,
  }) {
    return context.read<ThemeProvider>().buildCard(
      child: child,
      padding: padding,
      margin: margin,
      color: color,
      elevation: elevation,
      borderRadius: borderRadius,
    );
  }

  /// Standard Primary Button
  static Widget buildPrimaryButton(
    BuildContext context, {
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    Color? backgroundColor,
    Color? foregroundColor,
    EdgeInsetsGeometry? padding,
  }) {
    return context.read<ThemeProvider>().buildPrimaryButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: padding,
    );
  }

  /// Standard Secondary Button
  static Widget buildSecondaryButton(
    BuildContext context, {
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    Color? borderColor,
    Color? foregroundColor,
    EdgeInsetsGeometry? padding,
  }) {
    return context.read<ThemeProvider>().buildSecondaryButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      borderColor: borderColor,
      foregroundColor: foregroundColor,
      padding: padding,
    );
  }

  /// Standard Input Field
  static Widget buildInputField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return context.read<ThemeProvider>().buildInputField(
      label: label,
      controller: controller,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      enabled: enabled,
    );
  }

  /// Standard Loading Indicator
  static Widget buildLoadingIndicator(
    BuildContext context, {
    String? message,
    Color? color,
  }) {
    return context.read<ThemeProvider>().buildLoadingIndicator(
      message: message,
      color: color,
    );
  }

  /// Standard Empty State
  static Widget buildEmptyState(
    BuildContext context, {
    required String message,
    required IconData icon,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return context.read<ThemeProvider>().buildEmptyState(
      message: message,
      icon: icon,
      actionText: actionText,
      onAction: onAction,
    );
  }

  /// Standard Error State
  static Widget buildErrorState(
    BuildContext context, {
    required String message,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return context.read<ThemeProvider>().buildErrorState(
      message: message,
      actionText: actionText,
      onAction: onAction,
    );
  }

  /// Standard Bottom Navigation Bar
  static Widget buildBottomNavigationBar(
    BuildContext context, {
    required int currentIndex,
    required Function(int) onTap,
    required List<BottomNavigationBarItem> items,
    Color? backgroundColor,
    Color? selectedItemColor,
    Color? unselectedItemColor,
  }) {
    return context.read<ThemeProvider>().buildBottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
    );
  }

  /// Standard Floating Action Button
  static Widget buildFloatingActionButton(
    BuildContext context, {
    required VoidCallback onPressed,
    required IconData icon,
    Color? backgroundColor,
    Color? foregroundColor,
    String? tooltip,
  }) {
    return context.read<ThemeProvider>().buildFloatingActionButton(
      onPressed: onPressed,
      icon: icon,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      tooltip: tooltip,
    );
  }

  /// Show Success Snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    context.read<ThemeProvider>().showSuccessSnackBar(context, message);
  }

  /// Show Error Snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    context.read<ThemeProvider>().showErrorSnackBar(context, message);
  }

  /// Show Warning Snackbar
  static void showWarningSnackBar(BuildContext context, String message) {
    context.read<ThemeProvider>().showWarningSnackBar(context, message);
  }

  /// Show Custom Snackbar
  static void showSnackBar(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration? duration,
  }) {
    context.read<ThemeProvider>().showSnackBar(
      context,
      message: message,
      backgroundColor: backgroundColor,
      textColor: textColor,
      icon: icon,
      duration: duration,
    );
  }
}

/// Specialized widgets for specific use cases

/// Summary Card Widget
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepNavy.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, color: color, size: 20.sp),
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Entry Card Widget for consistent entry display
class EntryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? value;
  final String? unit;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final List<Widget>? actions;

  const EntryCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.value,
    this.unit,
    required this.icon,
    required this.iconColor,
    this.onTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepNavy.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepNavy,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (value != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        value!,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                      ),
                      if (unit != null)
                        Text(
                          unit!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            if (actions != null && actions!.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Row(
                children: actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Status Badge Widget
class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final Color? backgroundColor;

  const StatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Detail Row Widget for consistent information display
class DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Color? iconColor;

  const DetailRow({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: iconColor ?? AppColors.textSecondary),
          SizedBox(width: 8.w),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section Header Widget
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? action;

  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20.sp, color: AppColors.deepNavy),
            SizedBox(width: 8.w),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.deepNavy,
            ),
          ),
          const Spacer(),
          if (action != null) action!,
        ],
      ),
    );
  }
}
