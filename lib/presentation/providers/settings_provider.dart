import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  bool _audioEnable = true;
  String _audioSource = 'Mic'; // Mic, Internal, Both
  int _videoResolution = 1080; // 480, 720, 1080
  int _videoFps = 60; // 24, 30, 60
  int _videoBitrate = 16000000; // 16Mbps

  bool get audioEnable => _audioEnable;
  String get audioSource => _audioSource;
  int get videoResolution => _videoResolution;
  int get videoFps => _videoFps;
  int get videoBitrate => _videoBitrate;

  void toggleAudio(bool value) {
    _audioEnable = value;
    notifyListeners();
  }

  void setAudioSource(String source) {
    _audioSource = source;
    notifyListeners();
  }
  
  void setVideoResolution(int res) {
    _videoResolution = res;
    notifyListeners();
  }

  void setVideoFps(int fps) {
    _videoFps = fps;
    notifyListeners();
  }

  void setVideoBitrate(int bitrate) {
    _videoBitrate = bitrate;
    notifyListeners();
  }
}
