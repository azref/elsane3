import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:alsana_alharfiyin/constants/app_colors.dart';
import 'package:alsana_alharfiyin/constants/app_strings.dart';
import 'package:alsana_alharfiyin/models/request_model.dart';
import 'package:alsana_alharfiyin/models/user_model.dart'; // Added UserType import
import 'package:alsana_alharfiyin/providers/auth_provider.dart';
import 'package:alsana_alharfiyin/providers/request_provider.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingId;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String audioUrl, String requestId) async {
    try {
      if (_currentlyPlayingId == requestId) {
        await _audioPlayer.stop();
        setState(() {
          _currentlyPlayingId = null;
        });
      } else {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(audioUrl));
        setState(() {
          _currentlyPlayingId = requestId;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.audioPlaybackError}: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return AppStrings.now;
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} ${AppStrings.minutesAgo}';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ${AppStrings.hoursAgo}';
    } else {
      return '${difference.inDays} ${AppStrings.daysAgo}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<authProvider>(context);
    final user = authState.user;

    if (user == null || user.userType != UserType.craftsman) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.requests),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.textOnPrimaryColor,
        ),
        body: Center(
          child: Text(
            user == null ? AppStrings.pleaseLogin : AppStrings.craftsmanOnlySection,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondaryColor,
            ),
          ),
        ),
      );
    }

    // استخدام الاستماع المحدود والمفلتر للطلبات
    final requestsAsync = ref.watch(craftsmanRequestsProvider(
      CraftsmanRequestParams(
        professionConceptKey: user.professionConceptKey ?? '', // Corrected to professionConceptKey
        workCities: user.workCities ?? [],
      ),
    ));

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.requests),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textOnPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter functionality
            },
          ),
        ],
      ),
      body: requestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.work_off,
                    size: 64,
                    color: AppColors.textSecondaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.noRequestsFound,
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.ensureAvailabilityStatus,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.hintTextColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(craftsmanRequestsProvider);
            },
            color: AppColors.primaryColor, // Added color for RefreshIndicator
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return _buildRequestCard(request);
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.errorLoadingRequests,
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.errorColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              CustomButton(
                label: AppStrings.retry,
                onPressed: () {
                  ref.invalidate(craftsmanRequestsProvider);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(RequestModel request) {
    final isExpired = DateTime.now().isAfter(request.expiresAt);
    final timeRemaining = request.expiresAt.difference(DateTime.now());
    final isPlaying = _currentlyPlayingId == request.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpired ? AppColors.errorColor : AppColors.borderColor,
          width: isExpired ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  request.professionDialectName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatTimeAgo(request.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Client Info
          Row(
            children: [
              const Icon(
                Icons.person,
                size: 16,
                color: AppColors.textSecondaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                request.userName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Location
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 16,
                color: AppColors.textSecondaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                '${request.city}, ${request.country}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Audio Player
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _playAudio(request.audioUrl, request.id),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: AppColors.textOnPrimaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    AppStrings.voiceMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimaryColor,
                    ),
                  ),
                ),
                const Icon(
                  Icons.headphones,
                  size: 20,
                  color: AppColors.textSecondaryColor,
                ),
              ],
            ),
          ),

          // Text Description (if available)
          if (request.textDescription != null && request.textDescription!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                request.textDescription!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimaryColor,
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Status and Actions
          Row(
            children: [
              // Expiry Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isExpired ? AppColors.errorColor : AppColors.warningColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isExpired
                      ? AppStrings.expired
                      : '${AppStrings.expiresIn} ${timeRemaining.inHours}س',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textOnPrimaryColor,
                  ),
                ),
              ),
              const Spacer(),
              // Contact Button
              if (!isExpired)
                CustomButton(
                  label: AppStrings.contact,
                  onPressed: () {
                    // TODO: Start chat with client
                  },
                  icon: Icons.chat,
                  isOutlined: false, // Ensure it's not outlined if it's a primary action
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
            ],
          ),
        ],
      ),
    );
  }
}


