import 'dart:io';
import 'package:ed_screen_recorder/ed_screen_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class RecordingService {
  final EdScreenRecorder _screenRecorder = EdScreenRecorder();
  
  // Future implementation of initialization if needed
  Future<void> init() async {}

  Future<Map<String, dynamic>?> startRecording({
    required bool audioEnable,
    int? videoFrame,
    int? videoBitrate,
  }) async {
    try {
      Directory? dir;
      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory();
      } else {
        dir = await getApplicationDocumentsDirectory();
      }
      
      if (dir == null) return null;

      final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String fileName = "ScreenRecord_$timestamp";

      final response = await _screenRecorder.startRecordScreen(
        fileName: fileName,
        dirPathToSave: dir.path,
        audioEnable: audioEnable,
        videoFrame: videoFrame,
        videoBitrate: videoBitrate,
        width: 0, // Using 0 typically auto-matches screen resolution in many native libs
        height: 0,
      );

      return {
        'success': response['success'],
        'file': response['file'],
        'eventName': response['eventname'],
        'message': response['message']
      };
    } catch (e) {
      print("Error starting recording: $e");
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>?> stopRecording() async {
    try {
      final response = await _screenRecorder.stopRecord();
      return {
        'success': response['success'],
        'file': response['file'],
        'eventName': response['eventname'],
        'message': response['message']
      };
    } catch (e) {
      print("Error stopping recording: $e");
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>?> pauseRecording() async {
    try {
       final response = await _screenRecorder.pauseRecord();
       return {
        'success': response['success'],
        'eventName': response['eventname']
      };
    } catch (e) {
      print("Error pausing recording: $e");
      return null;
    }
  }
  
  Future<Map<String, dynamic>?> resumeRecording() async {
    try {
       final response = await _screenRecorder.resumeRecord();
       return {
        'success': response['success'],
        'eventName': response['eventname']
      };
    } catch (e) {
      print("Error resuming recording: $e");
      return null;
    }
  }
}
