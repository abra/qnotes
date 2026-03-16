import 'package:image_service/image_service.dart';

class FakeImageService implements ImageService {
  final List<String> deletedPaths = [];
  bool shouldThrow = false;

  @override
  Future<String> saveImage(String sourcePath) async => sourcePath;

  @override
  Future<void> deleteImage(String imagePath) async {
    if (shouldThrow) throw ImageServiceException('deleteImage failed');
    deletedPaths.add(imagePath);
  }

  @override
  Future<void> deleteImagesFromContent(String content) async {
    if (shouldThrow)
      throw ImageServiceException('deleteImagesFromContent failed');
  }
}
