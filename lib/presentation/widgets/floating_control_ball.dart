import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class FloatingControlBall extends StatefulWidget {
  const FloatingControlBall({super.key});

  @override
  State<FloatingControlBall> createState() => _FloatingControlBallState();
}

class _FloatingControlBallState extends State<FloatingControlBall> {
  bool _isPaused = false;
  final SendPort? _sendPort = IsolateNameServer.lookupPortByName('overlay_port');

  @override
  void initState() {
    super.initState();
    FlutterOverlayWindow.overlayListener.listen((event) {});
  }

  void _sendMessage(String message) {
    if (_sendPort != null) {
      _sendPort.send(message);
    } else {
      // In case port is not found, broadcast to overlay listener
      FlutterOverlayWindow.shareData(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.black87.withAlpha(200),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                _sendMessage('stop');
                FlutterOverlayWindow.closeOverlay();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent,
                ),
                child: const Icon(Icons.stop, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                setState(() => _isPaused = !_isPaused);
                _sendMessage(_isPaused ? 'pause' : 'resume');
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[700],
                ),
                child: Icon(_isPaused ? Icons.play_arrow : Icons.pause, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                _sendMessage('screenshot');
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green[600],
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                _sendMessage('open_app');
                FlutterOverlayWindow.closeOverlay();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue[600],
                ),
                child: const Icon(Icons.open_in_new, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
