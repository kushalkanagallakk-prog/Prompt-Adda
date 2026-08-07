import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/cloudinary_service.dart';

class AdminImageUploadTestScreen extends StatefulWidget {
  const AdminImageUploadTestScreen({super.key});

  @override
  State<AdminImageUploadTestScreen> createState() =>
      _AdminImageUploadTestScreenState();
}

class _AdminImageUploadTestScreenState
    extends State<AdminImageUploadTestScreen> {
  final ImagePicker _picker = ImagePicker();

  List<XFile> _selectedImages = <XFile>[];
  List<String> _uploadedUrls = <String>[];

  bool _isUploading = false;
  int _uploadedCount = 0;

  Future<void> _pickImages() async {
    if (_isUploading) return;

    try {
      final images = await _picker.pickMultiImage(imageQuality: 85);

      if (!mounted || images.isEmpty) return;

      setState(() {
        _selectedImages = images;
        _uploadedUrls = <String>[];
        _uploadedCount = 0;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to select images: $error')),
      );
    }
  }

  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty || _isUploading) return;

    setState(() {
      _isUploading = true;
      _uploadedUrls = <String>[];
      _uploadedCount = 0;
    });

    try {
      final urls = await CloudinaryService.uploadImages(
        _selectedImages,
        onProgress: (completed, total) {
          if (!mounted) return;

          setState(() {
            _uploadedCount = completed;
          });
        },
      );

      if (!mounted) return;

      setState(() {
        _uploadedUrls = urls;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('${urls.length} images uploaded successfully'),
          ),
        );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Upload failed: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _removeSelectedImage(int index) {
    if (_isUploading) return;

    setState(() {
      _selectedImages.removeAt(index);
      _uploadedUrls = <String>[];
      _uploadedCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalImages = _selectedImages.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Cloudinary Upload Test')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isUploading ? null : _pickImages,
              icon: const Icon(Icons.photo_library_rounded),
              label: const Text('Select Multiple Images'),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Selected images: $totalImages',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (_selectedImages.isEmpty)
            Container(
              height: 150,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Text('No images selected'),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _selectedImages.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Material(
                        color: Colors.black54,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => _removeSelectedImage(index),
                          child: const Padding(
                            padding: EdgeInsets.all(5),
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _selectedImages.isEmpty || _isUploading
                  ? null
                  : _uploadImages,
              icon: _isUploading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_upload_rounded),
              label: Text(
                _isUploading
                    ? 'Uploading $_uploadedCount / $totalImages'
                    : 'Upload to Cloudinary',
              ),
            ),
          ),
          if (_isUploading && totalImages > 0) ...[
            const SizedBox(height: 14),
            LinearProgressIndicator(value: _uploadedCount / totalImages),
          ],
          if (_uploadedUrls.isNotEmpty) ...[
            const SizedBox(height: 28),
            Text(
              'Uploaded URLs',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ..._uploadedUrls.asMap().entries.map((entry) {
              final index = entry.key;
              final url = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Image ${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    SelectableText(url),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
