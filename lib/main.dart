yimport 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:alsana_alharfiyin/services/firebase_core_service.dart';
import 'package:alsana_alharfiyin/services/ads_service.dart';
import 'package:alsana_alharfiyin/services/analytics_service.dart';
import 'package:alsana_alharfiyin/constants/app_colors.dart';
import 'package:alsana_alharfiyin/screens/auth/login_screen.dart';
import 'package:alsana_alharfiyin/screens/main/main_screen.dart';
import 'package:alsana_alharfiyin/providers/auth_provider.dart' as app_auth;
import 'package:alsana_alharfiyin/providers/profession_provider.dart';
import 'package:alsana_alharfiyin/providers/request_provider.dart';
import 'package:alsana_alharfiyin/providers/chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseCoreService.initialize();
  
  // Initialize Ads
  await AdsService.initialize();
  
  // Initialize Analytics
  await AnalyticsService.initialize();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surfaceColor,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Track app launch
  await AnalyticsService.trackAppLaunch();
  
  // Set up error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    AnalyticsService.recordFlutterError(details);
  };
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfessionProvider()),
        ChangeNotifierProvider(create: (_) => RequestProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const AlsanaAlharfiyinApp(),
    ),
  );
}

class AlsanaAlharfiyinApp extends StatelessWidget {
  const AlsanaAlharfiyinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'الصانع الحرفي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: AppColors.primaryMaterialColor,
        primaryColor: AppColors.primaryColor,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        fontFamily: 'Cairo',
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: AppColors.textPrimaryColor),
          displayMedium: TextStyle(color: AppColors.textPrimaryColor),
          displaySmall: TextStyle(color: AppColors.textPrimaryColor),
          headlineLarge: TextStyle(color: AppColors.textPrimaryColor),
          headlineMedium: TextStyle(color: AppColors.textPrimaryColor),
          headlineSmall: TextStyle(color: AppColors.textPrimaryColor),
          titleLarge: TextStyle(color: AppColors.textPrimaryColor),
          titleMedium: TextStyle(color: AppColors.textPrimaryColor),
          titleSmall: TextStyle(color: AppColors.textPrimaryColor),
          bodyLarge: TextStyle(color: AppColors.textPrimaryColor),
          bodyMedium: TextStyle(color: AppColors.textPrimaryColor),
          bodySmall: TextStyle(color: AppColors.textSecondaryColor),
          labelLarge: TextStyle(color: AppColors.textPrimaryColor),
          labelMedium: TextStyle(color: AppColors.textSecondaryColor),
          labelSmall: TextStyle(color: AppColors.textSecondaryColor),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.textOnPrimaryColor,
          elevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.textOnPrimaryColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryColor,
            side: const BorderSide(color: AppColors.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.textFieldFillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.errorColor),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.errorColor, width: 2),
          ),
        ),
        cardTheme: CardTheme(
          color: AppColors.cardBackgroundColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<app_auth.AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            ),
          );
        }
        
        if (authProvider.user != null) {
          return const MainScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

