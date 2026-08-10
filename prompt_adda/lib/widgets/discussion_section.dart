import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/comment_model.dart';
import '../services/admin_auth_service.dart';
import '../services/auth_service.dart';
import '../services/comment_service.dart';

class DiscussionSection extends StatefulWidget {
  const DiscussionSection({super.key, required this.promptId});

  final String promptId;

  @override
  State<DiscussionSection> createState() => _DiscussionSectionState();
}

class _DiscussionSectionState extends State<DiscussionSection> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  bool _isPosting = false;

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    try {
      await AuthService.signInWithGoogle();

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Signed in. You can join the discussion now.'),
          ),
        );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Google sign-in cancelled or failed.'),
          ),
        );
    }
  }

  Future<void> _submitComment() async {
    if (_isPosting) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      await _signIn();
      return;
    }

    final text = _commentController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      _isPosting = true;
    });

    try {
      await CommentService.addComment(promptId: widget.promptId, text: text);

      _commentController.clear();
      _commentFocusNode.unfocus();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Comment posted'),
          ),
        );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Unable to post comment: $error'),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  Future<void> _deleteComment(CommentModel comment) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                'Delete comment?',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
              content: Text(
                'This comment will be permanently removed.',
                style: GoogleFonts.poppins(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldDelete) return;

    try {
      await CommentService.deleteComment(
        promptId: widget.promptId,
        commentId: comment.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Comment deleted'),
          ),
        );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Unable to delete comment: $error'),
          ),
        );
    }
  }

  String _timeAgo(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Just now';
    }

    final difference = DateTime.now().difference(dateTime);

    if (difference.isNegative) {
      return 'Just now';
    }

    if (difference.inSeconds < 60) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }

    if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    }

    if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    }

    return '${(difference.inDays / 365).floor()}y ago';
  }

  Widget _avatar({
    required String? photoUrl,
    required String name,
    double radius = 20,
  }) {
    final hasPhoto = photoUrl != null && photoUrl.trim().isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFECE4FF),
      backgroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
      child: hasPhoto
          ? null
          : Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF7042D8),
              ),
            ),
    );
  }

  Widget _buildComposer(User? user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xFFF8F5FF),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE8DFF7),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.forum_outlined,
              size: 30,
              color: isDark ? const Color(0xFFBFA7FF) : const Color(0xFF7042D8),
            ),
            const SizedBox(height: 10),
            Text(
              'Join the discussion',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Sign in with Google to post a comment.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.62),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _signIn,
              icon: const Icon(Icons.login_rounded),
              label: const Text('Sign in with Google'),
            ),
          ],
        ),
      );
    }

    final name = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : 'You';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE8E0F3),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar(photoUrl: user.photoURL, name: name),
          const SizedBox(width: 11),
          Expanded(
            child: TextField(
              controller: _commentController,
              focusNode: _commentFocusNode,
              minLines: 1,
              maxLines: 5,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Add to the discussion...',
                counterText: '',
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : const Color(0xFFF8F5FC),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: Color(0xFF8C5BEA),
                    width: 1.4,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 46,
            height: 46,
            child: FilledButton(
              onPressed: _isPosting ? null : _submitComment,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isPosting
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.arrow_upward_rounded, size: 21),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard({
    required CommentModel comment,
    required User? currentUser,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isAdminComment = AdminAuthService.isAdminUid(comment.userId);

    final isOwner = currentUser != null && currentUser.uid == comment.userId;

    final canDelete =
        currentUser != null && (isOwner || AdminAuthService.isCurrentUserAdmin);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar(
            photoUrl: comment.userPhoto,
            name: comment.userName,
            radius: 19,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        comment.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (isAdminComment) ...[
                      const SizedBox(width: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7042D8), Color(0xFFA65DE2)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'ADMIN',
                          style: GoogleFonts.poppins(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.35,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    Text(
                      _timeAgo(comment.createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.48),
                      ),
                    ),
                    const Spacer(),
                    if (canDelete)
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        iconSize: 19,
                        tooltip: 'Comment options',
                        onSelected: (value) {
                          if (value == 'delete') {
                            _deleteComment(comment);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline_rounded, size: 19),
                                SizedBox(width: 10),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  comment.text,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    height: 1.55,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurface.withValues(
                      alpha: isDark ? 0.88 : 0.82,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        final currentUser = authSnapshot.data;

        return StreamBuilder<List<CommentModel>>(
          stream: CommentService.watchComments(widget.promptId),
          builder: (context, snapshot) {
            final comments = snapshot.data ?? <CommentModel>[];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0E7FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.forum_rounded,
                        color: Color(0xFF7042D8),
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Discussion',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFF1EAFB),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        comments.length.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF7042D8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Share your thoughts and help the community.',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.58),
                  ),
                ),
                const SizedBox(height: 18),

                _buildComposer(currentUser),

                const SizedBox(height: 24),

                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (snapshot.hasError)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.04)
                          : const Color(0xFFF8F5FC),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      'Unable to load discussion.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                  )
                else if (comments.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 26,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.04)
                          : const Color(0xFFF9F7FC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 30,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.35),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No comments yet',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Be the first to start the discussion.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.52),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: comments
                        .map(
                          (comment) => _buildCommentCard(
                            comment: comment,
                            currentUser: currentUser,
                          ),
                        )
                        .toList(),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
