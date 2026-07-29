import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/dummy_collections.dart';
import '../../../data/dummy_prompts.dart';
import '../../../models/prompt_collection.dart';
import '../../../models/prompt_model.dart';
import '../../collections/collection_prompts_screen.dart';

class FeaturedCollections extends StatelessWidget {
  const FeaturedCollections({super.key});

  List<PromptModel> _promptsForCollection(PromptCollection collection) {
    return dummyPrompts.where((prompt) {
      return collection.promptIds.contains(prompt.id);
    }).toList();
  }

  void _openCollection(BuildContext context, PromptCollection collection) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CollectionPromptsScreen(
          collection: collection,
          prompts: _promptsForCollection(collection),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(right: 4),
        itemCount: dummyCollections.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 14);
        },
        itemBuilder: (context, index) {
          final collection = dummyCollections[index];
          final promptCount = _promptsForCollection(collection).length;

          return _CollectionCard(
            collection: collection,
            promptCount: promptCount,
            onTap: () {
              _openCollection(context, collection);
            },
          );
        },
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.collection,
    required this.promptCount,
    required this.onTap,
  });

  final PromptCollection collection;
  final int promptCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 245,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: collection.gradient,
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: collection.gradient.first.withValues(alpha: 0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Stack(
                children: [
                  Positioned(
                    top: -45,
                    right: -30,
                    child: Container(
                      width: 135,
                      height: 135,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -12,
                    bottom: -14,
                    child: Icon(
                      collection.icon,
                      size: 105,
                      color: Colors.white.withValues(alpha: 0.13),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 47,
                              height: 47,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.23),
                                ),
                              ),
                              child: Icon(
                                collection.icon,
                                color: Colors.white,
                                size: 23,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_outward_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          collection.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.25,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          collection.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            height: 1.4,
                            color: Colors.white.withValues(alpha: 0.80),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            '$promptCount ${promptCount == 1 ? 'prompt' : 'prompts'}',
                            style: GoogleFonts.poppins(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
