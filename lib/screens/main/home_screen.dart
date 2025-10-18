import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alsana_alharfiyin/models/user_model.dart';
import 'package:alsana_alharfiyin/models/profession_model.dart';
import 'package:alsana_alharfiyin/providers/auth_provider.dart';
import 'package:alsana_alharfiyin/providers/profession_provider.dart'; // Added profession_provider
import 'package:alsana_alharfiyin/widgets/custom_text_field.dart';
import 'package:alsana_alharfiyin/widgets/custom_button.dart';
import 'package:alsana_alharfiyin/widgets/audio_recorder_widget.dart';
import 'package:alsana_alharfiyin/constants/app_colors.dart';
import 'package:alsana_alharfiyin/constants/app_strings.dart';
import 'package:alsana_alharfiyin/screens/chat/chat_detail_screen.dart'; // Assuming this might be used for navigation

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedProfessionConceptKey;
  String? _selectedProfessionName;

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthProvider>(context);
    final user = authState.user; // Access user from authState
    final professionsData = Provider.of<ProfessionProvider>(context); // Access professionsData

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(AppStrings.appName),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textOnPrimaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryColor, AppColors.primaryLightColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppStrings.welcome}${user?.displayName != null ? ', ${user!.displayName}' : ''}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textOnPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.userType == UserType.craftsman
                          ? AppStrings.craftsmanDashboardWelcomeMessage
                          : AppStrings.clientDashboardWelcomeMessage,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textOnPrimaryColor,
                        // opacity: 0.9, // Opacity is not a direct property of TextStyle, use withOpacity on color
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions for Clients
              if (user?.userType == UserType.client) ...[
                Text(
                  AppStrings.makeNewRequest,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Profession Selection
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.selectProfessionForRequest,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedProfessionConceptKey,
                        decoration: InputDecoration(
                          hintText: AppStrings.selectCraftsmanType,
                          filled: true,
                          fillColor: AppColors.textFieldFillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.accentColor, width: 2),
                          ),
                        ),
                        items: professionsData.getAllProfessions().map((profession) {
                          final dialectName = profession.getNameByDialect(user?.dialect ?? 'AR');
                          return DropdownMenuItem<String>(
                            value: profession.conceptKey,
                            child: Text(dialectName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedProfessionConceptKey = value;
                            if (value != null) {
                              final profession = professionsData.getProfessionByConceptKey(value);
                              _selectedProfessionName = profession?.getNameByDialect(user?.dialect ?? 'AR') ?? value;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Audio Recorder
                AudioRecorderWidget(
                  selectedProfession: _selectedProfessionName,
                  onRecordingComplete: (audioPath) {
                    // TODO: Handle audio recording completion, e.g., upload to Firebase Storage
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppStrings.audioRecordedSuccessfully),
                          backgroundColor: AppColors.successColor,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: AppStrings.submitRequest,
                  onPressed: () {
                    // TODO: Implement request submission logic
                    if (_selectedProfessionConceptKey == null || _selectedProfessionConceptKey!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppStrings.selectProfessionForRequest),
                          backgroundColor: AppColors.errorColor,
                        ),
                      );
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Request submitted (placeholder)'),
                        backgroundColor: AppColors.primaryColor,
                      ),
                    );
                  },
                ),
              ],

              // Quick Actions for Craftsmen
              if (user?.userType == UserType.craftsman) ...[
                Text(
                  AppStrings.workStatus,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Availability Toggle
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        user?.isAvailable == true ? Icons.check_circle : Icons.cancel,
                        color: user?.isAvailable == true ? AppColors.successColor : AppColors.errorColor,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.isAvailable == true ? AppStrings.availableForWork : AppStrings.notAvailableForWork,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryColor,
                              ),
                            ),
                            Text(
                              user?.isAvailable == true
                                  ? AppStrings.willReceiveJobAlerts
                                  : AppStrings.willNotReceiveJobAlerts,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: user?.isAvailable ?? false,
                        onChanged: (value) {
                          // TODO: Update availability status in Firebase
                          // // // // ref.read(authProvider.notifier).updateUserAvailability(value);
                        },
                        activeColor: AppColors.successColor,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Recent Requests Preview
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.recentJobRequests,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryColor,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: Navigate to requests screen
                            },
                            child: Text(AppStrings.viewAll),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.noRecentActivityYet,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


