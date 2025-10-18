import 'package:flutter/material.dart';
import 'package:alsana_alharfiyin/models/user_model.dart';
import 'package:alsana_alharfiyin/providers/auth_provider.dart';
import 'package:alsana_alharfiyin/providers/profession_provider.dart';
import 'package:alsana_alharfiyin/widgets/custom_button.dart';
import 'package:alsana_alharfiyin/widgets/audio_recorder_widget.dart';
import 'package:alsana_alharfiyin/constants/app_colors.dart';
import 'package:alsana_alharfiyin/constants/app_strings.dart';

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
    final authState = AuthProvider.of(context);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('الصنعة الحرفيين'),
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
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً${user?.name != null ? ', ${user!.name}' : ''}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textOnPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.userType == UserType.craftsman
                          ? 'مرحباً بك في لوحة تحكم الحرفيين'
                          : 'مرحباً بك في لوحة تحكم العملاء',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textOnPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions for Clients
              if (user?.userType == UserType.client) ...[
                Text(
                  'إنشاء طلب جديد',
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
                        'اختر نوع الحرفي المطلوب',
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
                          hintText: 'اختر نوع الحرفي',
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
                        items: [],
                        onChanged: (value) {
                          setState(() {
                            _selectedProfessionConceptKey = value;
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
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم تسجيل الصوت بنجاح'),
                          backgroundColor: AppColors.successColor,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'إرسال الطلب',
                  onPressed: () {
                    if (_selectedProfessionConceptKey == null || _selectedProfessionConceptKey!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('يرجى اختيار نوع الحرفي'),
                          backgroundColor: AppColors.errorColor,
                        ),
                      );
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم إرسال الطلب'),
                        backgroundColor: AppColors.primaryColor,
                      ),
                    );
                  },
                ),
              ],

              // Quick Actions for Craftsmen
              if (user?.userType == UserType.craftsman) ...[
                Text(
                  'حالة العمل',
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
                              user?.isAvailable == true ? 'متاح للعمل' : 'غير متاح للعمل',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryColor,
                              ),
                            ),
                            Text(
                              user?.isAvailable == true
                                  ? 'سوف تتلقى تنبيهات بالوظائف'
                                  : 'لن تتلقى تنبيهات بالوظائف',
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
                            'طلبات العمل الحديثة',
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
                            child: const Text('عرض الكل'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'لا توجد نشاطات حديثة بعد',
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
