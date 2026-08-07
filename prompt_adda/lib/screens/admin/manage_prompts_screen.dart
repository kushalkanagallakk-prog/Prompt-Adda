import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import 'prompt_editor_screen.dart';

class ManagePromptsScreen extends StatefulWidget {
  const ManagePromptsScreen({super.key});

  @override
  State<ManagePromptsScreen> createState() => _ManagePromptsScreenState();
}

class _ManagePromptsScreenState extends State<ManagePromptsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddPrompt() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PromptEditorScreen()),
    );
  }

  Future<void> _deletePrompt({
    required String documentId,
    required String title,
  }) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              SizedBox(width: 10),
              Expanded(child: Text('Delete Prompt')),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "$title"?\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.delete_rounded),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    try {
      await FirebaseFirestore.instance
          .collection('prompts')
          .doc(documentId)
          .delete();

      if (!mounted) return;

      _showMessage('Prompt deleted successfully');
    } catch (error) {
      if (!mounted) return;

      _showMessage('Unable to delete prompt: $error');
    }
  }

  Future<void> _openEditPrompt({
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PromptEditorScreen(documentId: documentId, promptData: data),
      ),
    );
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

  bool _matchesSearch(Map<String, dynamic> data) {
    if (_searchQuery.isEmpty) return true;

    final searchableText = [
      data['title'],
      data['category'],
      data['aiModel'],
      data['description'],
      ...(data['tags'] is List ? data['tags'] as List : const <dynamic>[]),
    ].map((value) => value?.toString().toLowerCase() ?? '').join(' ');

    return searchableText.contains(_searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.appBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('prompts')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return _buildMessageState(
                        icon: Icons.error_outline_rounded,
                        title: 'Unable to load prompts',
                        subtitle: snapshot.error.toString(),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final documents =
                        snapshot.data?.docs
                            .where(
                              (document) => _matchesSearch(document.data()),
                            )
                            .toList() ??
                        <QueryDocumentSnapshot<Map<String, dynamic>>>[];

                    if (documents.isEmpty) {
                      return _buildMessageState(
                        icon: Icons.auto_awesome_mosaic_rounded,
                        title: _searchQuery.isEmpty
                            ? 'No prompts yet'
                            : 'No matching prompts',
                        subtitle: _searchQuery.isEmpty
                            ? 'Create your first prompt from the plus button.'
                            : 'Try another search keyword.',
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                      itemCount: documents.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final document = documents[index];
                        final data = document.data();

                        return _PromptAdminCard(
                          documentId: document.id,
                          data: data,
                          onEdit: () {
                            _openEditPrompt(
                              documentId: document.id,
                              data: data,
                            );
                          },
                          onDelete: () {
                            _deletePrompt(
                              documentId: document.id,
                              title: data['title']?.toString() ?? 'Prompt',
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Manage Prompts',
              style: GoogleFonts.poppins(
                fontSize: 23,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Add Prompt',
            onPressed: _openAddPrompt,
            icon: const Icon(
              Icons.add_circle_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.trim().toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search title, category, model or tags...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();

                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
        ),
      ),
    );
  }

  Widget _buildMessageState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 58, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromptAdminCard extends StatelessWidget {
  const _PromptAdminCard({
    required this.documentId,
    required this.data,
    required this.onEdit,
    required this.onDelete,
  });

  final String documentId;
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String? get _coverImage {
    final coverImage = data['coverImage']?.toString().trim() ?? '';

    if (coverImage.isNotEmpty) {
      return coverImage;
    }

    final imageUrls = data['imageUrls'];

    if (imageUrls is List && imageUrls.isNotEmpty) {
      final firstImage = imageUrls.first?.toString().trim() ?? '';

      if (firstImage.isNotEmpty) {
        return firstImage;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final title = data['title']?.toString() ?? 'Untitled Prompt';
    final aiModel = data['aiModel']?.toString() ?? 'Unknown Model';
    final category = data['category']?.toString() ?? 'Uncategorized';

    final isFeatured = data['isFeatured'] == true;
    final isTrending = data['isTrending'] == true;
    final isPremium = data['isPremium'] == true;
    final isVisible = data['isVisible'] != false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.95)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _coverImage == null
                  ? Container(
                      color: AppColors.primarySoft,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_rounded,
                        size: 46,
                        color: AppColors.primary,
                      ),
                    )
                  : Image.network(
                      _coverImage!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return Container(
                          color: AppColors.primarySoft,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.primarySoft,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image_rounded,
                            size: 42,
                            color: AppColors.primary,
                          ),
                        );
                      },
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$aiModel • $category',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (isFeatured)
                      const _StatusChip(
                        label: 'Featured',
                        icon: Icons.star_rounded,
                      ),
                    if (isTrending)
                      const _StatusChip(
                        label: 'Trending',
                        icon: Icons.local_fire_department_rounded,
                      ),
                    if (isPremium)
                      const _StatusChip(
                        label: 'Premium',
                        icon: Icons.workspace_premium_rounded,
                      ),
                    _StatusChip(
                      label: isVisible ? 'Visible' : 'Hidden',
                      icon: isVisible
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_rounded),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_rounded),
                        label: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
