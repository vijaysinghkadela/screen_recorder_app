import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayService {
  static const String _portName = 'overlay_port';
  static final ReceivePort _receivePort = ReceivePort();

  static void initialize(void Function(dynamic) onMessageReceived) {
    if (IsolateNameServer.lookupPortByName(_portName) == null) {
      IsolateNameServer.registerPortWithName(_receivePort.sendPort, _portName);
    }
    
    _receivePort.listen(onMessageReceived);

    FlutterOverlayWindow.overlayListener.listen((event) {
      onMessageReceived(event);
    });
  }

  static Future<void> showOverlay() async {
    final bool isGranted = await FlutterOverlayWindow.isPermissionGranted();
    if (!isGranted) {
      await FlutterOverlayWindow.requestPermission();
    }

    if (await FlutterOverlayWindow.isActive()) {
      return;
    }

    await FlutterOverlayWindow.showOverlay(
      enableDrag: true,
      overlayTitle: "Screen Recorder",
      overlayContent: "Recording active",
      flag: OverlayFlag.defaultFlag,
      alignment: OverlayAlignment.centerLeft,
      visibility: NotificationVisibility.visibilityPublic,
      positionGravity: PositionGravity.auto,
      height: 70,
      width: 200,
    );
  }

  static Future<void> hideOverlay() async {
    if (await FlutterOverlayWindow.isActive()) {
      await FlutterOverlayWindow.closeOverlay();
    }
  }

  static Future<void> triggerEvent(String eventName) async {
    await FlutterOverlayWindow.shareData(eventName);
  }
}
