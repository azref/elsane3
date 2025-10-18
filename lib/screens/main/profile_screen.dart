import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alsana_alharfiyin/constants/app_colors.dart';
import 'package:alsana_alharfiyin/constants/app_strings.dart';
import 'package:alsana_alharfiyin/models/profession_model.dart';
import 'package:alsana_alharfiyin/models/user_model.dart'; // Added UserType import
import 'package:alsana_alharfiyin/providers/auth_provider.dart';
import 'package:alsana_alharfiyin/providers/profession_provider.dart'; // Added profession_provider import
import 'package:alsana_alharfiyin/widgets/custom_button.dart';
import 'package:alsana_alharfiyin/screens/auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthProvider>(context);
    final user = authState.user; // Access user from authState
    final professionsData = Provider.of<ProfessionProvider>(context); // Access professionsData

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(AppStrings.profile),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textOnPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Navigate to settings screen
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture and Name
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.primaryLightColor,
                    child: Text(
                      user.displayName != null && user.displayName!.isNotEmpty ? user.displayName![0].toUpperCase() : 
                      user.email.isNotEmpty ? user.email[0].toUpperCase() : 
                      'U', // Default to 'U' if no name or email
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textOnPrimaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.displayName ?? AppStrings.unknownUser,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                  // Phone number is not in UserModel, so commenting out or adding a placeholder
                  // const SizedBox(height: 8),
                  // Text(
                  //   user.phone ?? '', // Assuming phone might be null
                  //   style: const TextStyle(
                  //     fontSize: 16,
                  //     color: AppColors.textSecondaryColor,
                  //   ),
                  // ),
                  const SizedBox(height: 24),

                  // User Type and Details
                  _buildInfoCard(
                    title: AppStrings.accountType,
                    value: user.userType == UserType.craftsman
                        ? AppStrings.craftsman
                        : AppStrings.client,
                    icon: user.userType == UserType.craftsman
                        ? Icons.handyman
                        : Icons.person,
                  ),
                  if (user.userType == UserType.craftsman) ...[
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      title: AppStrings.profession,
                      value: user.professionConceptKey != null
                          ? professionsData.getProfessionByConceptKey(user.professionConceptKey!)?.getNameByDialect(user.dialect ?? 'AR') ?? AppStrings.notSpecified
                          : AppStrings.notSpecified,
                      icon: Icons.work,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      title: AppStrings.workCities,
                      value: user.workCities != null && user.workCities!.isNotEmpty
                          ? user.workCities!.join(', ')
                          : AppStrings.notSpecified,
                      icon: Icons.location_city,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      title: AppStrings.status,
                      value: user.isAvailable ? AppStrings.availableForWork : AppStrings.notAvailableForWork,
                      icon: user.isAvailable ? Icons.check_circle : Icons.cancel,
                      valueColor: user.isAvailable ? AppColors.successColor : AppColors.errorColor,
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Logout Button
                  CustomButton(
                    label: AppStrings.logout,
                    onPressed: () async {
                      await // // // ref.read(authProvider.notifier).signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (Route<dynamic> route) => false,
                        );
                      }
                    },
                    isOutlined: true,
                    icon: Icons.logout,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? AppColors.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


