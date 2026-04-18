import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class BaseProfileScreen extends StatefulWidget {
  final String roleTitle;
  final IconData roleIcon;
  final Color roleColor;
  final List<Widget>? additionalSections;

  const BaseProfileScreen({
    super.key,
    required this.roleTitle,
    required this.roleIcon,
    required this.roleColor,
    this.additionalSections,
  });

  @override
  State<BaseProfi
