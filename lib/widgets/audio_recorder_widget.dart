import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart'; // Added for getTemporaryDirectory
import 'dart:io'; // Added for File

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class AudioRecorderWidget extends StatefulWidget {
  final Function(String audioPath) onRecordingComplete;
  final String? selectedProfession;

  const AudioRecorderWidget({
    super.key, // Using super.key
    required this.onRecordingComplete,
    this.selectedProfession,
  });

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget>
    with TickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isPermissionGranted = false;
  Duration _recordingDuration = Duration.zero;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.microphone.status;
    setState(() {
      _isPermissionGranted = status.isGranted;
    });
  }

  Future<void> _requestPermission() async {
    final status = await Permission.microphone.request();
    setState(() {
      _isPermissionGranted = status.isGranted;
    });
    if (!status.isGranted) {
      // Optionally show a dialog or snackbar if permission is still not granted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.microphonePermissionDeniedMessage),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _startRecording() async {
    if (!_isPermissionGranted) {
      await _requestPermission();
      if (!_isPermissionGranted) return;
    }

    if (widget.selectedProfession == null || widget.selectedProfession!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.selectProfessionForRequest),
            backgroundColor: AppColors.warningColor,
          ),
        );
      }
      return;
    }

    try {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });

      _animationController.repeat(reverse: true);
      _startTimer();
    } catch (e) {
      print('Error starting recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.error}: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });

      _animationController.stop();
      _animationController.reset();

      if (path != null) {
        widget.onRecordingComplete(path);
      }
    } catch (e) {
      print('Error stopping recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.error}: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRecording && mounted) {
        setState(() {
          _recordingDuration = _recordingDuration + const Duration(seconds: 1);
        });
        _startTimer();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPermissionGranted) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.mic_off,
              size: 48,
              color: AppColors.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.microphonePermissionMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _requestPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor, // Use primaryColor for consistency
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(AppStrings.grantPermission),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          if (_isRecording) ...[
            Text(
              _formatDuration(_recordingDuration),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 20 + (index * 5) * _scaleAnimation.value,
                      width: 4,
                      decoration: BoxDecoration(
                        color: AppColors.audioWaveColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
          ],
          GestureDetector(
            onTap: _isRecording ? _stopRecording : _startRecording,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isRecording ? _scaleAnimation.value : 1.0,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _isRecording ? AppColors.errorColor : AppColors.microphoneButtonColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowColor,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      size: 40,
                      color: AppColors.textOnPrimaryColor,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isRecording ? AppStrings.stopRecording : AppStrings.recordAudioMessage,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondaryColor,
            ),
          ),
          if (widget.selectedProfession != null && widget.selectedProfession!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${AppStrings.directedTo}: ${widget.selectedProfession}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}


