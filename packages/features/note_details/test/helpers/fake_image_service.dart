import 'package:image_service/image_service.dart';

class FakeImageService implements ImageService {
  final List<String> deletedPaths = [];

  @override
  Future<String> saveImage(String sourcePath) async => sourcePath;

  @override
  Future<void> deleteImage(String imagePath) async {
    deletedPaths.add(imagePath);
  }

  @override
  Future<void> deleteImagesFromContent(String content) async {}
}
