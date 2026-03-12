import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../core/services/video_editing_service.dart';

class VideoEditorScreen extends StatefulWidget {
  final File videoFile;

  const VideoEditorScreen({super.key, required this.videoFile});

  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  final VideoEditingService _editingService = VideoEditingService();
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _processAction(String action) async {
    setState(() => _isProcessing = true);
    try {
      Directory dir;
      if (Platform.isAndroid) {
        dir = (await getExternalStorageDirectory())!;
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      File? result;
      String message = '';

      if (action == 'Trim') {
        final outPath = '${dir.path}/Trim_$timestamp.mp4';
        // Trim first 5 seconds for demo. In real app, we'd add a range slider
        result = await _editingService.trimVideo(widget.videoFile, outPath, 0, 5);
        message = 'Video Trimmed successfully!';
      } else if (action == 'Rotate') {
        final outPath = '${dir.path}/Rotate_$timestamp.mp4';
        result = await _editingService.rotateVideo(widget.videoFile, outPath);
        message = 'Video Rotated successfully!';
      } else if (action == 'GIF') {
        final outPath = '${dir.path}/Gif_$timestamp.gif';
        result = await _editingService.convertToGif(widget.videoFile, outPath);
        message = 'Converted to GIF successfully!';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(result != null ? message : 'Processing Failed')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Edit Video'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _initialized
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                      if (_isProcessing)
                        Container(
                          color: Colors.black54,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(Icons.cut, 'Trim', () => _processAction('Trim')),
                _buildActionButton(Icons.rotate_right, 'Rotate', () => _processAction('Rotate')),
                _buildActionButton(Icons.gif_box, 'To GIF', () => _processAction('GIF')),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: _isProcessing ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
