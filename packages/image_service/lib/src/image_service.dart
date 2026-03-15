import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared/shared.dart';

/// Manages image files stored in `<appDocuments>/nota_images/`.
///
/// All images are copied into the app's documents directory under a
/// content-addressed filename so that paths remain stable across moves.
class ImageService {
  static const _folder = 'nota_images';

  /// Returns the directory where note images are stored, creating it if needed.
  Future<Directory> _imagesDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, _folder));
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  /// Copies the file at [sourcePath] into the images directory.
  ///
  /// Returns the permanent path of the saved image.
  Future<String> saveImage(String sourcePath) async {
    final dir = await _imagesDir();
    final ext = p.extension(sourcePath);
    final filename = '${DateTime.now().microsecondsSinceEpoch}$ext';
    final dest = File(p.join(dir.path, filename));
    await File(sourcePath).copy(dest.path);
    return dest.path;
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
