import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';

class AvailableCraftsmenScreen extends StatelessWidget {
  const AvailableCraftsmenScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.availableCraftsmen),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: const Center(
        child: Text(
          'شاشة الحرفيين المتاحين - قيد التطوير',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

