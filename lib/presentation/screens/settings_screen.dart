import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Record Audio'),
            subtitle: const Text('Enable microphone recording'),
            value: settingsProvider.audioEnable,
            onChanged: (value) => settingsProvider.toggleAudio(value),
          ),
          ListTile(
            title: const Text('Audio Source'),
            subtitle: Text(settingsProvider.audioSource),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Show dialog to pick source
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Audio Source'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildOption(context, settingsProvider, 'Mic'),
                      _buildOption(context, settingsProvider, 'Internal'),
                      _buildOption(context, settingsProvider, 'Both'),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Video Resolution'),
            subtitle: Text('${settingsProvider.videoResolution}p'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Resolution'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildRes(context, settingsProvider, 480),
                      _buildRes(context, settingsProvider, 720),
                      _buildRes(context, settingsProvider, 1080),
                    ],
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Frame Rate'),
            subtitle: Text('${settingsProvider.videoFps} FPS'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Frame Rate'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFps(context, settingsProvider, 24),
                      _buildFps(context, settingsProvider, 30),
                      _buildFps(context, settingsProvider, 60),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, SettingsProvider provider, String source) {
    return RadioListTile<String>(
      title: Text(source),
      value: source,
      groupValue: provider.audioSource,
      onChanged: (value) {
        if (value != null) provider.setAudioSource(value);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildRes(BuildContext context, SettingsProvider provider, int res) {
    return RadioListTile<int>(
      title: Text('${res}p'),
      value: res,
      groupValue: provider.videoResolution,
      onChanged: (value) {
        if (value != null) provider.setVideoResolution(value);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildFps(BuildContext context, SettingsProvider provider, int fps) {
    return RadioListTile<int>(
      title: Text('$fps FPS'),
      value: fps,
      groupValue: provider.videoFps,
      onChanged: (value) {
        if (value != null) provider.setVideoFps(value);
        Navigator.pop(context);
      },
    );
  }
}
