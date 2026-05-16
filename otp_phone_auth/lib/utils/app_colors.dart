import 'package:flutter/material.dart';

class AppColors {
  // Dark Blue Navy Theme for Accountant & Professional

  // Primary Colors - Dark Blue Navy
  static const Color deepNavy = Color(0xFF1A1A2E); // Dark Blue Navy
  static const Color deepNavyDark = Color(0xFF0F0F1E); // Darker Navy
  static const Color deepNavyLight = Color(0xFF2D2E47); // Light Navy
  
  // Missing colors for supervisor dashboard
  static const Color primaryPurple = Color(0xFF000000); // Pure Black
  static const Color lightBackground = Color(0xFFF5F5F5); // Light Gray
  
  // Accent Colors - Gray Scale
  static const Color safetyOrange = Color(0xFF424242); // Dark Gray
  static const Color safetyOrangeLight = Color(0xFF757575); // Medium Gray
  static const Color safetyOrangeDark = Color(0xFF000000); // Pure Black
  
  // Background Colors - Pure White
  static const Color cleanWhite = Color(0xFFFFFFFF);
  static const Color lightSlate = Color(0xFFF5F5F5); // Light Gray
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color white = Color(0xFFFFFFFF); // Pure White
  
  // Text Colors - Navy Theme
  static const Color textPrimary = Color(0xFF1A1A2E); // Dark Navy
  static const Color textSecondary = Color(0xFF4A5568); // Medium Navy
  static const Color textTertiary = Color(0xFF718096); // Light Navy
  static const Color textHint = Color(0xFFCBD5E0); // Very Light Navy
  
  // Status/Feedback Colors - Grayscale
  static const Color success = Color(0xFF424242); // Dark Gray (for success)
  static const Color error = Color(0xFF000000); // Black (for errors)
  static const Color warning = Color(0xFF757575); // Medium Gray (for warnings)
  static const Color info = Color(0xFF616161); // Medium Gray (for info)
  
  // Role-specific Colors - Navy Theme
  static const Color supervisorColor = Color(0xFF1A1A2E); // Dark Navy
  static const Color engineerColor = Color(0xFF2563EB); // Blue
  static const Color accountantColor = Color(0xFF1A1A2E); // Dark Navy (Primary)
  static const Color architectColor = Color(0xFF1A1A2E); // Dark Navy
  static const Color ownerColor = Color(0xFF1A1A2E); // Dark Navy
  
  // Status Colors - Grayscale
  static const Color statusCompleted = Color(0xFF424242); // Dark Gray
  static const Color statusPending = Color(0xFF757575); // Medium Gray
  static const Color statusOverdue = Color(0xFF000000); // Black
  static const Color statusNotYet = Color(0xFF9E9E9E); // Light Gray
  
  // Border and Divider Colors
  static const Color borderColor = Color(0xFFE0E0E0); // Light Gray
  static const Color dividerColor = Color(0xFFBDBDBD); // Medium Light Gray
  static const Color divider = Color(0xFFBDBDBD); // Medium Light Gray (alias)
  
  // Gradient Colors - Black to Gray
  static const LinearGradient navyGradient = LinearGradient(
    colors: [Color(0xFF000000), Color(0xFF424242)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFF424242), Color(0xFF000000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient professionalGradient = LinearGradient(
    colors: [Color(0xFF000000), Color(0xFF212121)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Shadow Colors
  static BoxShadow cardShadow = BoxShadow(
    color: const Color(0xFF000000).withValues(alpha: 0.08),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );
  
  static BoxShadow elevatedShadow = BoxShadow(
    color: const Color(0xFF000000).withValues(alpha: 0.12),
    blurRadius: 12,
    offset: const Offset(0, 4),
  );
  
  // Gray scale aliases
  static const Color lightGray = Color(0xFFE0E0E0);
  static const Color mediumGray = Color(0xFF9E9E9E);

  // Legacy compatibility (mapped to new colors)
  static const Color blueprintBlue = deepNavy;
  static const Color blueprintLight = deepNavyLight;
  static const Color blueprintDark = deepNavyDark;
  static const Color slateGray = textSecondary;
  static const Color slateLight = textTertiary;
  static const Color slateDark = deepNavyDark;
  static const Color backgroundLight = lightSlate;
  static const Color cardWhite = cleanWhite;
  static const Color accentOrange = safetyOrange;
  static const Color accentGreen = statusCompleted;
  static const Color accentAmber = statusPending;
  
  // New auth screen colors
  static const Color background = lightSlate;
  static const Color primary = deepNavy;
  
  static const LinearGradient blueprintGradient = navyGradient;
  static const LinearGradient slateGradient = navyGradient;
  static const LinearGradient primaryGradient = navyGradient;
  
  static const Color primaryTeal = Color(0xFF424242);
  static const Color primaryViolet = Color(0xFF000000);
  static const Color neonTeal = Color(0xFF757575);
  static const Color neonViolet = Color(0xFF424242);
  static const Color neonOrange = Color(0xFF616161);
  static const Color tealLight = Color(0xFF9E9E9E);
  static const Color violetLight = Color(0xFF757575);
  static const Color backgroundDark = lightSlate;
  static const Color surfaceDark = cleanWhite;
  static const Color cardDark = cleanWhite;
  
  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF424242), Color(0xFF000000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient violetGradient = LinearGradient(
    colors: [Color(0xFF000000), Color(0xFF424242)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF424242), Color(0xFF212121)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient darkGradient = professionalGradient;
  static const LinearGradient glowingGradient = professionalGradient;

  // Accountant Screen Specific Colors
  static const Color accountantPrimary = Color(0xFF1A1A2E); // Dark Navy
  static const Color accountantAccent = Color(0xFF2563EB); // Bright Blue
  static const Color accountantSuccess = Color(0xFF059669); // Green (for confirmed)
  static const Color accountantWarning = Color(0xFFF59E0B); // Amber (for pending)
  static const Color accountantError = Color(0xFFDC2626); // Red (for errors)
  static const Color accountantBackground = Color(0xFFF8F9FA); // Light Gray

  static BoxShadow accountantCardShadow = BoxShadow(
    color: const Color(0xFF1A1A2E).withValues(alpha: 0.08),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );

  static BoxShadow neonTealGlow = BoxShadow(
    color: const Color(0xFF757575).withValues(alpha: 0.3),
    blurRadius: 12,
    offset: const Offset(0, 4),
  );
  static BoxShadow neonVioletGlow = BoxShadow(
    color: const Color(0xFF424242).withValues(alpha: 0.3),
    blurRadius: 12,
    offset: const Offset(0, 4),
  );
  static BoxShadow neonOrangeGlow = BoxShadow(
    color: const Color(0xFF616161).withValues(alpha: 0.3),
    blurRadius: 12,
    offset: const Offset(0, 4),
  );
  
  static const Color primaryOrange = safetyOrange;
  static const Color primaryBlue = deepNavy;
  static const Color darkBlue = deepNavyDark;
  static const Color lightBlue = deepNavyLight;
  static const Color cardBackground = cleanWhite;
  
  static const LinearGradient blueGradient = navyGradient;
  static const LinearGradient purpleGradient = violetGradient;
  static const LinearGradient redGradient = LinearGradient(
    colors: [Color(0xFF000000), Color(0xFF424242)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
