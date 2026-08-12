import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../services/cloudinary_service.dart';

class PromptEditorScreen extends StatefulWidget {
  const PromptEditorScreen({super.key, this.documentId, this.promptData});

  final String? documentId;
  final Map<String, dynamic>? promptData;

  bool get isEdit => documentId != null && promptData != null;

  @override
  State<PromptEditorScreen> createState() => _PromptEditorScreenState();
}

class _PromptEditorScreenState extends State<PromptEditorScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  static const List<String> _defaultAiModels = <String>[
    'ChatGPT',
    'Gemini',
    'Claude',
    'Midjourney',
    'Flux',
    'Veo',
    'Kling',
    'Other',
  ];

  static const List<String> _defaultCategories = <String>[
    'Social Media',
    'YouTube',
    'Design',
    'Coding',
    'Writing',
    'Career',
    'Marketing',
    'Business',
    'Education',
    'Image AI',
    'Video AI',
  ];

  final List<XFile> _newImages = <XFile>[];
  final List<String> _existingImageUrls = <String>[];

  final List<TextEditingController> _existingImageTagControllers =
      <TextEditingController>[];

  final List<TextEditingController> _newImageTagControllers =
      <TextEditingController>[];

  late List<String> _aiModels;
  late List<String> _categories;

  String _selectedAiModel = _defaultAiModels.first;
  String _selectedCategory = _defaultCategories.first;

  bool _isFeatured = false;
  bool _isTrending = false;
  bool _isPremium = false;
  bool _isVisible = true;
  bool _wasFeatured = false;

  bool _isSaving = false;
  int _uploadedCount = 0;

  String _initialTitle = '';
  String _initialDescription = '';
  String _initialPrompt = '';
  String _initialTags = '';
  String _initialAiModel = '';
  String _initialCategory = '';

  bool _initialIsFeatured = false;
  bool _initialIsTrending = false;
  bool _initialIsPremium = false;
  bool _initialIsVisible = true;

  List<String> _initialImageUrls = <String>[];
  bool _hasSavedSuccessfully = false;
  bool _allowPop = false;

  int get _totalImageCount => _existingImageUrls.length + _newImages.length;

  @override
  void initState() {
    super.initState();

    _aiModels = List<String>.from(_defaultAiModels);
    _categories = List<String>.from(_defaultCategories);

    _loadExistingPrompt();
    _captureInitialState();

    _loadExistingPrompt();
  }

  void _loadExistingPrompt() {
    final data = widget.promptData;

    if (data == null) return;

    _titleController.text = data['title']?.toString() ?? '';
    _descriptionController.text = data['description']?.toString() ?? '';
    _promptController.text = data['prompt']?.toString() ?? '';
    _isFeatured = data['isFeatured'] == true;
    _wasFeatured = _isFeatured;

    final rawTags = data['tags'];

    if (rawTags is List) {
      _tagsController.text = rawTags
          .map((tag) => tag.toString().trim())
          .where((tag) => tag.isNotEmpty)
          .join(', ');
    }

    final aiModel = data['aiModel']?.toString().trim() ?? '';

    if (aiModel.isNotEmpty) {
      if (!_aiModels.contains(aiModel)) {
        _aiModels.add(aiModel);
      }

      _selectedAiModel = aiModel;
    }

    final category = data['category']?.toString().trim() ?? '';

    if (category.isNotEmpty) {
      if (!_categories.contains(category)) {
        _categories.add(category);
      }

      _selectedCategory = category;
    }

    final rawImageUrls = data['imageUrls'];

    if (rawImageUrls is List) {
      _existingImageUrls.addAll(
        rawImageUrls
            .map((url) => url.toString().trim())
            .where((url) => url.isNotEmpty),
      );
    }

    if (_existingImageUrls.isEmpty) {
      final legacyImageUrl = data['imageUrl']?.toString().trim() ?? '';

      if (legacyImageUrl.isNotEmpty) {
        _existingImageUrls.add(legacyImageUrl);
      }
    }

    final coverImage = data['coverImage']?.toString().trim() ?? '';

    if (coverImage.isNotEmpty && _existingImageUrls.contains(coverImage)) {
      _existingImageUrls.remove(coverImage);
      _existingImageUrls.insert(0, coverImage);
    }

    final rawImageTags = data['imageTags'];

    for (var index = 0; index < _existingImageUrls.length; index++) {
      String tagsText = '';

      if (rawImageTags is List && index < rawImageTags.length) {
        final rawTagsForImage = rawImageTags[index];

        if (rawTagsForImage is List) {
          tagsText = rawTagsForImage
              .map((tag) => tag.toString().trim())
              .where((tag) => tag.isNotEmpty)
              .join(', ');
        }
      }

      _existingImageTagControllers.add(TextEditingController(text: tagsText));
    }

    _isFeatured = data['isFeatured'] == true;
    _isTrending = data['isTrending'] == true;
    _isPremium = data['isPremium'] == true;
    _isVisible = data['isVisible'] != false;
  }

  void _captureInitialState() {
    _initialTitle = _titleController.text.trim();
    _initialDescription = _descriptionController.text.trim();
    _initialPrompt = _promptController.text.trim();
    _initialTags = _tagsController.text.trim();

    _initialAiModel = _selectedAiModel;
    _initialCategory = _selectedCategory;

    _initialIsFeatured = _isFeatured;
    _initialIsTrending = _isTrending;
    _initialIsPremium = _isPremium;
    _initialIsVisible = _isVisible;

    _initialImageUrls = List<String>.from(_existingImageUrls);
  }

  bool get _hasUnsavedChanges {
    if (_hasSavedSuccessfully) {
      return false;
    }

    final currentImageUrls = _existingImageUrls;

    final imagesChanged =
        currentImageUrls.length != _initialImageUrls.length ||
        !_sameStringLists(currentImageUrls, _initialImageUrls) ||
        _newImages.isNotEmpty;

    return _titleController.text.trim() != _initialTitle ||
        _descriptionController.text.trim() != _initialDescription ||
        _promptController.text.trim() != _initialPrompt ||
        _tagsController.text.trim() != _initialTags ||
        _selectedAiModel != _initialAiModel ||
        _selectedCategory != _initialCategory ||
        _isFeatured != _initialIsFeatured ||
        _isTrending != _initialIsTrending ||
        _isPremium != _initialIsPremium ||
        _isVisible != _initialIsVisible ||
        imagesChanged;
  }

  bool _sameStringLists(List<String> first, List<String> second) {
    if (first.length != second.length) {
      return false;
    }

    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) {
        return false;
      }
    }

    return true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _promptController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_isSaving) return;

    try {
      final images = await _imagePicker.pickMultiImage(imageQuality: 85);

      if (!mounted || images.isEmpty) return;

      setState(() {
        _newImages.addAll(images);

        for (var index = 0; index < images.length; index++) {
          _newImageTagControllers.add(TextEditingController());
        }
      });
    } catch (error) {
      if (!mounted) return;

      _showMessage('Unable to select images: $error');
    }
  }

  void _removeExistingImage(int index) {
    if (_isSaving) return;

    setState(() {
      _existingImageUrls.removeAt(index);

      for (final controller in _existingImageTagControllers) {
        controller.dispose();
      }

      for (final controller in _newImageTagControllers) {
        controller.dispose();
      }

      final controller = _existingImageTagControllers.removeAt(index);
      controller.dispose();
    });

    setState(() {
      _newImages.removeAt(index);

      final controller = _newImageTagControllers.removeAt(index);
      controller.dispose();
    });
  }

  void _removeNewImage(int index) {
    if (_isSaving) return;

    setState(() {
      _newImages.removeAt(index);
    });
  }

  void _makeExistingImageCover(int index) {
    if (_isSaving || index == 0) return;

    setState(() {
      final image = _existingImageUrls.removeAt(index);
      final tagController = _existingImageTagControllers.removeAt(index);

      _existingImageUrls.insert(0, image);
      _existingImageTagControllers.insert(0, tagController);
    });
  }

  void _makeNewImageCover(int index) {
    if (_isSaving) return;

    setState(() {
      final image = _newImages.removeAt(index);
      final tagController = _newImageTagControllers.removeAt(index);

      _existingImageUrls.clear();

      _newImages.insert(0, image);
      _newImageTagControllers.insert(0, tagController);
    });
  }

  List<String> _parseTags() {
    return _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();
  }

  Future<bool> _promptTitleAlreadyExists(String title) async {
    final normalizedTitle = title.trim().toLowerCase();

    final snapshot = await FirebaseFirestore.instance
        .collection('prompts')
        .get();

    for (final document in snapshot.docs) {
      if (widget.isEdit && document.id == widget.documentId) {
        continue;
      }

      final existingTitle =
          document.data()['title']?.toString().trim().toLowerCase() ?? '';

      if (existingTitle == normalizedTitle) {
        return true;
      }
    }

    return false;
  }

  Future<void> _trimHeroCarouselToTen() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('prompts')
      .where('isFeatured', isEqualTo: true)
      .get();

  if (snapshot.docs.length <= 10) return;

  final docs = [...snapshot.docs];

  DateTime heroDate(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    final featuredAt = data['featuredAt'];
    if (featuredAt is Timestamp) {
      return featuredAt.toDate();
    }

    final createdAt = data['createdAt'];
    if (createdAt is Timestamp) {
      return createdAt.toDate();
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  docs.sort(
    (a, b) => heroDate(b).compareTo(heroDate(a)),
  );

  final batch = FirebaseFirestore.instance.batch();

  for (final doc in docs.skip(10)) {
    batch.update(doc.reference, {
      'isFeatured': false,
      'featuredAt': null,
    });
  }

  await batch.commit();
}

  Future<void> _savePrompt() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid || _isSaving) return;

    if (_totalImageCount == 0) {
      _showMessage('Select at least one image');
      return;
    }

    final isNewHeroSelection =
    _isFeatured && (!widget.isEdit || !_wasFeatured);

    final title = _titleController.text.trim();

    setState(() {
      _isSaving = true;
      _uploadedCount = 0;
    });

    try {
      final duplicateTitleExists = await _promptTitleAlreadyExists(title);

      if (!mounted) return;

      if (duplicateTitleExists) {
        _showMessage('A prompt with this title already exists.');
        return;
      }

      List<String> uploadedImageUrls = <String>[];

      if (_newImages.isNotEmpty) {
        uploadedImageUrls = await CloudinaryService.uploadImages(
          _newImages,
          onProgress: (completed, total) {
            if (!mounted) return;

            setState(() {
              _uploadedCount = completed;
            });
          },
        );
      }

      final finalImageUrls = <String>[
        ..._existingImageUrls,
        ...uploadedImageUrls,
      ];

      if (finalImageUrls.isEmpty) {
        throw Exception('No valid images available');
      }

      final finalImageTags = <Map<String, dynamic>>[
        ..._existingImageTagControllers.map(
          (controller) => <String, dynamic>{
            'tags': controller.text
                .split(',')
                .map((tag) => tag.trim())
                .where((tag) => tag.isNotEmpty)
                .toSet()
                .toList(),
          },
        ),
        ..._newImageTagControllers.map(
          (controller) => <String, dynamic>{
            'tags': controller.text
                .split(',')
                .map((tag) => tag.trim())
                .where((tag) => tag.isNotEmpty)
                .toSet()
                .toList(),
          },
        ),
      ];

      final promptData = <String, dynamic>{
        'title': title,
        'aiModel': _selectedAiModel,
        'category': _selectedCategory,
        'description': _descriptionController.text.trim(),
        'prompt': _promptController.text.trim(),
        'tags': _parseTags(),
        'imageUrls': finalImageUrls,
        'imageTags': finalImageTags,
        'coverImage': finalImageUrls.first,
        'isFeatured': _isFeatured,
        if (isNewHeroSelection)
        'featuredAt': FieldValue.serverTimestamp(),
        if (!_isFeatured)
        'featuredAt': null,
        'isTrending': _isTrending,
        'isPremium': _isPremium,
        'isVisible': _isVisible,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.isEdit) {
        await FirebaseFirestore.instance
            .collection('prompts')
            .doc(widget.documentId)
            .update(promptData);
      } else {
        await FirebaseFirestore.instance.collection('prompts').add({
          ...promptData,
          'downloads': 0,
          'views': 0,
          'likes': 0,
          'copyCount': 0,
          'shareCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (isNewHeroSelection) {
  await _trimHeroCarouselToTen();
}

if (!mounted) return;

Navigator.pop(context, true);

      if (!mounted) return;

      setState(() {
        _hasSavedSuccessfully = true;
        _allowPop = true;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      });
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        widget.isEdit
            ? 'Unable to update prompt: $error'
            : 'Unable to publish prompt: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<bool> _confirmDiscardChanges() async {
    if (!_hasUnsavedChanges) {
      return true;
    }

    final shouldDiscard = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Discard changes?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'You have unsaved changes. Are you sure you want to leave?',
            style: GoogleFonts.poppins(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: Text(
                'Discard',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    return shouldDiscard ?? false;
  }

  Future<void> _requestClose([Object? result]) async {
    if (_isSaving || _allowPop) {
      return;
    }

    final canLeave = await _confirmDiscardChanges();

    if (!mounted || !canLeave) {
      return;
    }

    setState(() {
      _allowPop = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pop(result);
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }

        _requestClose(result);
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.appBackgroundGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 140),
                      children: [
                        _buildTextField(
                          controller: _titleController,
                          label: 'Prompt Title',
                          icon: Icons.title_rounded,
                          validator: _requiredValidator('Enter prompt title'),
                        ),
                        const SizedBox(height: 16),
                        _buildDropdown(
                          label: 'AI Model',
                          icon: Icons.smart_toy_rounded,
                          value: _selectedAiModel,
                          items: _aiModels,
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              _selectedAiModel = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildDropdown(
                          label: 'Category',
                          icon: Icons.grid_view_rounded,
                          value: _selectedCategory,
                          items: _categories,
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          icon: Icons.short_text_rounded,
                          maxLines: 3,
                          validator: _requiredValidator('Enter description'),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _promptController,
                          label: 'Full Prompt',
                          icon: Icons.auto_awesome_rounded,
                          minLines: 7,
                          maxLines: 14,
                          validator: _requiredValidator('Enter full prompt'),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _tagsController,
                          label: 'Tags separated by commas',
                          icon: Icons.sell_rounded,
                        ),
                        const SizedBox(height: 24),
                        _buildImagesSection(),
                        const SizedBox(height: 24),
                        _buildOptionsSection(),
                        if (_isSaving && _newImages.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          LinearProgressIndicator(
                            value: _uploadedCount / _newImages.length,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Uploading $_uploadedCount / '
                            '${_newImages.length} new images',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildSaveBar(),
      ),
    );
  }

  String? Function(String?) _requiredValidator(String message) {
    return (value) {
      if ((value ?? '').trim().isEmpty) {
        return message;
      }

      return null;
    };
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 20, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: _isSaving ? null : _requestClose,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              widget.isEdit ? 'Edit Prompt' : 'Add Prompt',
              style: GoogleFonts.poppins(
                fontSize: 23,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int? minLines,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      enabled: !_isSaving,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(value: item, child: Text(item)),
          )
          .toList(),
      onChanged: _isSaving ? null : onChanged,
    );
  }

  Widget _buildImagesSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_library_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Prompt Images',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '$_totalImageCount',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'First image is used as the cover image.',
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isSaving ? null : _pickImages,
              icon: const Icon(Icons.add_photo_alternate_rounded),
              label: Text(widget.isEdit ? 'Add More Images' : 'Select Images'),
            ),
          ),
          if (_existingImageUrls.isNotEmpty) ...[
            const SizedBox(height: 18),
            _buildSectionLabel('Existing Images'),
            const SizedBox(height: 10),
            _buildExistingImagesGrid(),
          ],
          if (_newImages.isNotEmpty) ...[
            const SizedBox(height: 18),
            _buildSectionLabel('New Images'),
            const SizedBox(height: 10),
            _buildNewImagesGrid(),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildExistingImagesGrid() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _existingImageUrls.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 3 / 2,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      _existingImageUrls[index],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;

                        return Container(
                          color: AppColors.primarySoft,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.primarySoft,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image_rounded,
                            color: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                  if (index == 0) _buildCoverBadge(),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Material(
                      color: Colors.black54,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: index == 0
                            ? null
                            : () => _makeExistingImageCover(index),
                        customBorder: const CircleBorder(),
                        child: const Padding(
                          padding: EdgeInsets.all(5),
                          child: Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: _buildRemoveButton(
                      () => _removeExistingImage(index),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _existingImageTagControllers[index],
              enabled: !_isSaving,
              decoration: const InputDecoration(
                labelText: 'Image Search Tags',
                hintText: 'e.g. allu arjun, pushpa',
                prefixIcon: Icon(Icons.sell_rounded),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNewImagesGrid() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _newImages.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final isCover = _existingImageUrls.isEmpty && index == 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 3 / 2,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      File(_newImages[index].path),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.primarySoft,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image_rounded,
                            color: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                  if (isCover) _buildCoverBadge(),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Material(
                      color: Colors.black54,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: isCover ? null : () => _makeNewImageCover(index),
                        customBorder: const CircleBorder(),
                        child: const Padding(
                          padding: EdgeInsets.all(5),
                          child: Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: _buildRemoveButton(() => _removeNewImage(index)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _newImageTagControllers[index],
              enabled: !_isSaving,
              decoration: const InputDecoration(
                labelText: 'Image Search Tags',
                hintText: 'e.g. prabhas, salaar',
                prefixIcon: Icon(Icons.sell_rounded),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCoverBadge() {
    return Positioned(
      left: 5,
      bottom: 5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Cover',
          style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildRemoveButton(VoidCallback onTap) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(5),
          child: Icon(Icons.close_rounded, size: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          _buildSwitch(
            value: _isFeatured,
            title: 'Featured',
            subtitle: 'Show in Hero Carousel',
            icon: Icons.star_rounded,
            onChanged: (value) {
              setState(() {
                _isFeatured = value;
              });
            },
          ),
          const Divider(height: 1),
          _buildSwitch(
            value: _isTrending,
            title: 'Trending',
            subtitle: 'Show in Trending sections',
            icon: Icons.local_fire_department_rounded,
            onChanged: (value) {
              setState(() {
                _isTrending = value;
              });
            },
          ),
          const Divider(height: 1),
          _buildSwitch(
            value: _isPremium,
            title: 'Premium',
            subtitle: 'Lock for premium users',
            icon: Icons.workspace_premium_rounded,
            onChanged: (value) {
              setState(() {
                _isPremium = value;
              });
            },
          ),
          const Divider(height: 1),
          _buildSwitch(
            value: _isVisible,
            title: 'Visible',
            subtitle: 'Show this prompt to users',
            icon: Icons.visibility_rounded,
            onChanged: (value) {
              setState(() {
                _isVisible = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch({
    required bool value,
    required String title,
    required String subtitle,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: _isSaving ? null : onChanged,
      title: Text(title),
      subtitle: Text(subtitle),
      secondary: Icon(icon),
    );
  }

  Widget _buildSaveBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SizedBox(
          height: 54,
          child: FilledButton.icon(
            onPressed: _isSaving ? null : _savePrompt,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    widget.isEdit ? Icons.save_rounded : Icons.publish_rounded,
                  ),
            label: Text(
              _isSaving
                  ? widget.isEdit
                        ? 'Updating...'
                        : 'Publishing...'
                  : widget.isEdit
                  ? 'Update Prompt'
                  : 'Publish Prompt',
            ),
          ),
        ),
      ),
    );
  }
}
