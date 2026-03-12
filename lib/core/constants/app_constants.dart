class AppConstants {
  // App Info
  static const String appName = 'Screen Recorder Pro';
  static const String appVersion = '1.0.0';

  // Recording Quality Options
  static const List<String> qualityOptions = ['480p', '720p', '1080p'];
  static const List<int> qualityValues = [480, 720, 1080];

  // Frame Rate Options
  static const List<int> fpsOptions = [24, 30, 60];

  // Audio Source Options
  static const List<String> audioSourceOptions = [
    'No Audio',
    'Microphone',
    'System Audio',
    'Both'
  ];

  // File Settings
  static const String recordingsFolder = 'ScreenRecordings';
  static const String videoExtension = '.mp4';

  // Storage Keys
  static const String keyVideoQuality = 'video_quality';
  static const String keyFrameRate = 'frame_rate';
  static const String keyAudioSource = 'audio_source';
  static const String keyShowTimer = 'show_timer';
  static const String keyDarkMode = 'dark_mode';
}
