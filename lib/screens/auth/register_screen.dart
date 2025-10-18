import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../models/user_model.dart';
import '../../models/profession_model.dart';
import '../main/main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _experienceController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  UserType _selectedUserType = UserType.client;
  String _selectedCountry = 'MA'; // Morocco as default
  String? _selectedProfession;
  List<String> _selectedWorkCities = [];

  final Map<String, String> _countries = {
    'MA': 'المغرب',
    'DZ': 'الجزائر',
    'TN': 'تونس',
    'EG': 'مصر',
    'SA': 'السعودية',
    'AE': 'الإمارات',
    'KW': 'الكويت',
    'QA': 'قطر',
    'BH': 'البحرين',
    'OM': 'عمان',
    'JO': 'الأردن',
    'LB': 'لبنان',
    'SY': 'سوريا',
    'IQ': 'العراق',
    'YE': 'اليمن',
    'LY': 'ليبيا',
    'SD': 'السودان',
  };

  final Map<String, List<String>> _citiesByCountry = {
    'MA': ['الرباط', 'الدار البيضاء', 'فاس', 'مراكش', 'أكادير', 'طنجة', 'مكناس', 'وجدة', 'تطوان', 'الجديدة'],
    'DZ': ['الجزائر', 'وهران', 'قسنطينة', 'عنابة', 'باتنة', 'سطيف', 'سيدي بلعباس', 'بسكرة', 'تلمسان', 'بجاية'],
    'TN': ['تونس', 'صفاقس', 'سوسة', 'القيروان', 'بنزرت', 'قابس', 'أريانة', 'قفصة', 'المنستير', 'تطاوين'],
  };

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  List<ProfessionModel> get _availableProfessions {
    final professionsData = ProfessionsData();
    return professionsData.getProfessionsByDialect(_selectedCountry);
  }

  List<String> get _availableCities {
    return _citiesByCountry[_selectedCountry] ?? [];
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedUserType == UserType.craftsman) {
      if (_selectedProfession == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.professionRequired),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      if (_selectedWorkCities.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.workCitiesRequired),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement registration logic using AuthService
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في التسجيل: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.register),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User Type Selection
                const Text(
                  AppStrings.userType,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<UserType>(
                        title: const Text(AppStrings.craftsman),
                        value: UserType.craftsman,
                        groupValue: _selectedUserType,
                        onChanged: (value) {
                          setState(() {
                            _selectedUserType = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<UserType>(
                        title: const Text(AppStrings.client),
                        value: UserType.client,
                        groupValue: _selectedUserType,
                        onChanged: (value) {
                          setState(() {
                            _selectedUserType = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Basic Information
                CustomTextField(
                  label: AppStrings.name,
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.nameRequired;
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                CustomTextField(
                  label: AppStrings.email,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.emailRequired;
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return AppStrings.invalidEmail;
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                CustomTextField(
                  label: AppStrings.phone,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.phoneRequired;
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Country Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.country,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCountry,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                      items: _countries.entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCountry = value!;
                          _selectedProfession = null;
                          _selectedWorkCities.clear();
                        });
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Craftsman-specific fields
                if (_selectedUserType == UserType.craftsman) ...[
                  // Profession Selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppStrings.profession,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedProfession,
                        decoration: InputDecoration(
                          hintText: AppStrings.selectProfession,
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                        ),
                        items: _availableProfessions.map((profession) {
                          return DropdownMenuItem(
                            value: profession.conceptKey,
                            child: Text(profession.getNameByDialect(_selectedCountry)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedProfession = value;
                          });
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Experience Years
                  CustomTextField(
                    label: AppStrings.experienceYears,
                    controller: _experienceController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.work_outline,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Work Cities Selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppStrings.workCities,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: _availableCities.map((city) {
                            return CheckboxListTile(
                              title: Text(city),
                              value: _selectedWorkCities.contains(city),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedWorkCities.add(city);
                                  } else {
                                    _selectedWorkCities.remove(city);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                ],
                
                // Password Fields
                CustomTextField(
                  label: AppStrings.password,
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  onSuffixIconPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.passwordRequired;
                    }
                    if (value.length < 6) {
                      return AppStrings.passwordTooShort;
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                CustomTextField(
                  label: AppStrings.confirmPassword,
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  onSuffixIconPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.passwordRequired;
                    }
                    if (value != _passwordController.text) {
                      return AppStrings.passwordsDoNotMatch;
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Register Button
                CustomButton(
                  text: AppStrings.register,
                  onPressed: _register,
                  isLoading: _isLoading,
                  icon: Icons.person_add,
                ),
                
                const SizedBox(height: 24),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      AppStrings.alreadyHaveAccount,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        AppStrings.login,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

