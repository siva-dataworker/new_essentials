import 'package:flutter/material.dart';

class AppColors {
  // Black and White Professional Theme
  
  // Primary Colors - Black
  static const Color deepNavy = Color(0xFF000000); // Pure Black
  static const Color deepNavyDark = Color(0xFF000000); // Pure Black
  static const Color deepNavyLight = Color(0xFF424242); // Dark Gray
  
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
  
  // Text Colors - Black and Gray
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF424242);
  static const Color textTertiary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  
  // Status/Feedback Colors - Grayscale
  static const Color success = Color(0xFF424242); // Dark Gray (for success)
  static const Color error = Color(0xFF000000); // Black (for errors)
  static const Color warning = Color(0xFF757575); // Medium Gray (for warnings)
  static const Color info = Color(0xFF616161); // Medium Gray (for info)
  
  // Role-specific Colors - Grayscale
  static const Color supervisorColor = Color(0xFF000000); // Black
  static const Color engineerColor = Color(0xFF424242); // Dark Gray
  static const Color accountantColor = Color(0xFF616161); // Medium Gray
  static const Color architectColor = Color(0xFF000000); // Black
  static const Color ownerColor = Color(0xFF212121); // Very Dark Gray
  
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
