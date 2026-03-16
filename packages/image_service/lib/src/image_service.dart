import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared/shared.dart';

import 'image_service_exception.dart';

/// Manages image files stored in `<appDocuments>/nota_images/`.
///
/// All images are copied into the app's documents directory under a
/// content-addressed filename so that paths remain stable across moves.
class ImageService {
  static const _folder = 'nota_images';

  /// Returns the directory where note images are stored, creating it if needed.
  ///
  /// Throws [ImageServiceException] if the directory cannot be created.
  Future<Directory> _imagesDir() async {
    try {
      final base = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(base.path, _folder));
      if (!dir.existsSync()) await dir.create(recursive: true);
      return dir;
    } catch (e, st) {
      throw ImageServiceException('Failed to access images directory', e, st);
    }
  }

  /// Copies the file at [sourcePath] into the images directory.
  ///
  /// Returns the permanent path of the saved image.
  /// Throws [ImageServiceException] if the copy fails.
  Future<String> saveImage(String sourcePath) async {
    try {
      final dir = await _imagesDir();
      final ext = p.extension(sourcePath);
      final filename = '${DateTime.now().microsecondsSinceEpoch}$ext';
      final dest = File(p.join(dir.path, filename));
      await File(sourcePath).copy(dest.path);
      return dest.path;
    } on ImageServiceException {
      rethrow;
    } catch (e, st) {
      throw ImageServiceException('Failed to save image', e, st);
    }
  }

  /// Deletes the file at [imagePath]. Silently ignores missing files.
  Future<void> deleteImage(String imagePath) async {
    final file = File(imagePath);
    if (file.existsSync()) await file.delete();
  }

  /// Deletes all images referenced inside the Quill Delta [content] string.
  Future<void> deleteImagesFromContent(String content) async {
    final paths = DeltaUtils.allImagePaths(content);
    for (final path in paths) {
      await deleteImage(path);
    }
  }
}
