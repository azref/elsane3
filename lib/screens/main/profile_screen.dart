import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../models/user_model.dart'; // تم إضافة هذا الاستيراد لـ UserType

class ProfileScreen extends ConsumerWidget { // تم التغيير إلى ConsumerWidget
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) { // تم إضافة WidgetRef ref
    // مراقبة authProvider للتفاعل مع التغييرات في حالة المصادقة
    final authService = ref.watch(authProvider); // استخدام ref.watch
    final currentUser = authService.user; // افتراض أن authProvider يكشف عن UserModel مباشرة

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: currentUser == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'الرجاء تسجيل الدخول لعرض ملفك الشخصي.',
                    style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'تسجيل الدخول',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(
                        currentUser.userType == UserType.craftsman ? Icons.construction : Icons.person,
                        size: 60,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildProfileInfoRow(AppStrings.name, currentUser.name),
                  _buildProfileInfoRow(AppStrings.email, currentUser.email),
                  _buildProfileInfoRow(AppStrings.phone, currentUser.phone),
                  _buildProfileInfoRow(AppStrings.userType, currentUser.userType == UserType.craftsman ? AppStrings.craftsman : AppStrings.client),
                  if (currentUser.userType == UserType.craftsman) ...[
                    _buildProfileInfoRow(AppStrings.profession, currentUser.profession ?? 'غير محدد'),
                    _buildProfileInfoRow(AppStrings.experienceYears, '${currentUser.experienceYears ?? 0} سنوات'),
                    _buildProfileInfoRow(AppStrings.workCities, currentUser.workCities.join(', ')),
                  ],
                  _buildProfileInfoRow(AppStrings.country, currentUser.country),
                  _buildProfileInfoRow(AppStrings.createdAt, '${currentUser.createdAt.toLocal().year}-${currentUser.createdAt.toLocal().month}-${currentUser.createdAt.toLocal().day}'),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await authService.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text(AppStrings.logout),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
