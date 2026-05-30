import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ProductImageStorage {
  const ProductImageStorage._();

  static Future<String?> pickAndStore(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 82,
    );

    if (pickedFile == null) {
      return null;
    }

    final directory = await getApplicationDocumentsDirectory();
    final imagesDirectory = Directory('${directory.path}/product_images');
    if (!imagesDirectory.existsSync()) {
      imagesDirectory.createSync(recursive: true);
    }

    final extension = _extensionFor(pickedFile.path);
    final fileName =
        'product_${DateTime.now().microsecondsSinceEpoch}$extension';
    final destination = File('${imagesDirectory.path}/$fileName');
    await File(pickedFile.path).copy(destination.path);
    return destination.path;
  }

  static String _extensionFor(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == path.length - 1) {
      return '.jpg';
    }
    return path.substring(dotIndex);
  }
}
