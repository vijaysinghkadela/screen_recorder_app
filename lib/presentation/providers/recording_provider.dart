import 'dart:async';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../core/services/recording_service.dart';
import '../../core/services/overlay_service.dart';

class RecordingProvider with ChangeNotifier {
  final RecordingService _recordingService = RecordingService();
  
  bool _isRecording = false;
  bool _isPaused = false;
  int _recordingDuration = 0;
  Timer? _timer;
  
  final ScreenshotController screenshotController = ScreenshotController();

  RecordingProvider() {
    OverlayService.initialize((message) {
      if (message == 'stop') {
        stopRecording();
      } else if (message == 'pause') {
        pauseRecording();
      } else if (message == 'resume') {
        resumeRecording();
      } else if (message == 'screenshot') {
        takeScreenshot();
      }
    });
  }

  bool get isRecording => _isRecording;
  bool get isPaused => _isPaused;
  int get recordingDuration => _recordingDuration;

  String get formattedDuration {
    final int hours = _recordingDuration ~/ 3600;
    final int minutes = (_recordingDuration % 3600) ~/ 60;
    final int seconds = _recordingDuration % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<bool> startRecording(bool audioEnable, int videoFrame, int videoBitrate) async {
    final result = await _recordingService.startRecording(
      audioEnable: audioEnable,
      videoFrame: videoFrame,
      videoBitrate: videoBitrate,
    );

    if (result != null && result['success'] == true) {
      _isRecording = true;
      _isPaused = false;
      _recordingDuration = 0;
      _startTimer();
      await OverlayService.showOverlay();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> stopRecording() async {
    final result = await _recordingService.stopRecording();
    if (result != null && result['success'] == true) {
      _isRecording = false;
      _isPaused = false;
      _stopTimer();
      await OverlayService.triggerEvent('recording_stopped');
      await OverlayService.hideOverlay();
      notifyListeners();
    }
  }

  Future<void> pauseRecording() async {
    if (!_isRecording || _isPaused) return;
    
    final result = await _recordingService.pauseRecording();
    if (result != null && result['success'] == true) {
      _isPaused = true;
      _timer?.cancel();
      notifyListeners();
    }
  }

  Future<void> resumeRecording() async {
    if (!_isRecording || !_isPaused) return;
    
    final result = await _recordingService.resumeRecording();
    if (result != null && result['success'] == true) {
      _isPaused = false;
      _startTimer();
      notifyListeners();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordingDuration++;
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _recordingDuration = 0;
  }

  Future<void> takeScreenshot() async {
    try {
      final image = await screenshotController.capture();
      if (image == null) return;
      
      Directory? dir;
      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory();
      } else {
        dir = await getApplicationDocumentsDirectory();
      }
      
      if (dir != null) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final file = File('${dir.path}/Screenshot_$timestamp.png');
        await file.writeAsBytes(image);
        // Optionally share immediately or rely on gallery
      }
    } catch (e) {
      debugPrint('Error taking screenshot: $e');
    }
  }
}
