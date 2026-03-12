import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../providers/recording_provider.dart';
import '../providers/settings_provider.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/facecam_overlay.dart';
import '../widgets/drawing_overlay.dart';
import 'package:screenshot/screenshot.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasPermissions = false;
  bool _showFacecam = false;
  bool _showDrawing = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final statuses = await [
      Permission.microphone,
      Permission.camera,
      Permission.storage,
      Permission.manageExternalStorage,
      // Note: systemAlertWindow and mediaProjection need special handling in some plugins
    ].request();

    bool allGranted = true;
    for (var status in statuses.values) {
      if (status.isDenied || status.isPermanentlyDenied) {
        allGranted = false;
        break;
      }
    }

    if (mounted) {
      setState(() {
        _hasPermissions = allGranted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordingProvider = context.watch<RecordingProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    
    final isRecording = recordingProvider.isRecording;
    final isPaused = recordingProvider.isPaused;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen Recorder'),
        actions: [
          IconButton(
            icon: Icon(Icons.camera_front, color: _showFacecam ? AppTheme.primaryColor : Colors.grey),
            onPressed: () => setState(() => _showFacecam = !_showFacecam),
            tooltip: 'Facecam',
          ),
          IconButton(
            icon: Icon(Icons.brush, color: _showDrawing ? AppTheme.primaryColor : Colors.grey),
            onPressed: () => setState(() => _showDrawing = !_showDrawing),
            tooltip: 'Draw',
          ),
        ],
      ),
      body: Screenshot(
        controller: recordingProvider.screenshotController,
        child: Stack(
          children: [
            Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isRecording) ...[
              Text(
                recordingProvider.formattedDuration,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    heroTag: 'pause_resume',
                    onPressed: () {
                      if (isPaused) {
                        recordingProvider.resumeRecording();
                      } else {
                        recordingProvider.pauseRecording();
                      }
                    },
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                    child: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                  ),
                  const SizedBox(width: 24),
                  FloatingActionButton(
                    heroTag: 'stop',
                    onPressed: () => recordingProvider.stopRecording(),
                    backgroundColor: AppTheme.secondaryColor,
                    child: const Icon(Icons.stop),
                  ),
                ],
              ),
            ] else ...[
              GestureDetector(
                onTap: () async {
                  if (!_hasPermissions) {
                    await _checkPermissions();
                    if (!_hasPermissions) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Permissions required to record')),
                      );
                      return;
                    }
                  }
                  
                  recordingProvider.startRecording(
                    settingsProvider.audioEnable,
                    settingsProvider.videoFps,
                    settingsProvider.videoBitrate,
                  );
                },
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.secondaryColor.withAlpha(100),
                        blurRadius: 30,
                        spreadRadius: 10,
                      )
                    ],
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF5252), AppTheme.secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.videocam,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Tap to Start Recording',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoColumn(Icons.hd, '${settingsProvider.videoResolution}p'),
                      _buildInfoColumn(Icons.speed, '${settingsProvider.videoFps} FPS'),
                      _buildInfoColumn(
                        settingsProvider.audioEnable ? Icons.mic : Icons.mic_off,
                        settingsProvider.audioSource,
                      ),
                    ],
                  ),
                ),
              ),
            ], // end else ...[
          ], // end Column children
        ), // end Column
      ), // end Center
        if (_showFacecam)
          FacecamOverlay(onClose: () => setState(() => _showFacecam = false)),
        if (_showDrawing)
          DrawingOverlay(onClose: () => setState(() => _showDrawing = false)),
        ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
