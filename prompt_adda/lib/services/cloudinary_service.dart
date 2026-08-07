import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  CloudinaryService._();

  static const String _cloudName = 'l2p4cuc7';
  static const String _uploadPreset = 'prompt_adda_admin_uploads';

  static Uri get _uploadUri =>
      Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

  static Future<String> uploadImage(XFile image) async {
    final request = http.MultipartRequest('POST', _uploadUri)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          image.path,
          filename: image.name,
        ),
      );

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode < 200 ||
        streamedResponse.statusCode >= 300) {
      throw Exception(
        'Cloudinary upload failed '
        '(${streamedResponse.statusCode}): $responseBody',
      );
    }

    final json = jsonDecode(responseBody);

    if (json is! Map<String, dynamic>) {
      throw Exception('Invalid Cloudinary response');
    }

    final secureUrl = json['secure_url']?.toString().trim() ?? '';

    if (secureUrl.isEmpty) {
      throw Exception('Cloudinary secure URL not found');
    }

    return secureUrl;
  }

  static Future<List<String>> uploadImages(
    List<XFile> images, {
    void Function(int completed, int total)? onProgress,
  }) async {
    final uploadedUrls = <String>[];

    for (var index = 0; index < images.length; index++) {
      final url = await uploadImage(images[index]);
      uploadedUrls.add(url);

      onProgress?.call(index + 1, images.length);
    }

    return uploadedUrls;
  }
}
