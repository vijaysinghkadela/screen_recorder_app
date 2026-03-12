import 'dart:io';
import 'package:ffmpeg_kit_flutter_video/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_video/return_code.dart';

class VideoEditingService {
  Future<File?> trimVideo(File input, String outputFilePath, int startSec, int endSec) async {
    final command = '-y -i "${input.path}" -ss $startSec -to $endSec -c copy "$outputFilePath"';
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return File(outputFilePath);
    }
    return null;
  }

  Future<File?> rotateVideo(File input, String outputFilePath) async {
    // transpose=1 means 90 degrees clockwise
    final command = '-y -i "${input.path}" -vf "transpose=1" "$outputFilePath"';
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return File(outputFilePath);
    }
    return null;
  }

  Future<File?> convertToGif(File input, String outputFilePath) async {
    final command = '-y -i "${input.path}" -vf "fps=15,scale=480:-1:flags=lanczos" -loop 0 "$outputFilePath"';
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return File(outputFilePath);
    }
    return null;
  }
}
