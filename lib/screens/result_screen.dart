import 'package:flutter/material.dart';
import '../models/word_definition.dart';
import '../utils/constants.dart';
import '../widgets/definition_card.dart';

class ResultScreen extends StatelessWidget {
  final String query;
  final List<WordDefinition> definitions;

  const ResultScreen({
    super.key,
    required this.query,
    required this.definitions,
  });

  @override
  Widget build(BuildContext context) {
    final first = definitions.first;
    final word  = first.word.isNotEmpty ? first.word : query;
    final pron  = first.pronunciation;

    // Unique parts of speech
    final posList = definitions
        .map((d) => d.partOfSpeech)
        .where((p) => p.isNotEmpty)
        .toSet()
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero ─────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.headerBg,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.headerGradient,
                ),
                child: Stack(
                  children: [
                    // Decorative blob
                    Positioned(
                      top: -40, right: -40,
                      child: Container(
                        width: 180, height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.04),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Word
                            Text(
                              word,
                              style: T.display(color: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            // Pronunciation + POS pills
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (pron.isNotEmpty)
                                  Text(
                                    '/ $pron /',
                                    style: T.subtitle(
                                      color: Colors.white.withValues(alpha: 0.65),
                                    ).copyWith(fontStyle: FontStyle.italic),
                                  ),
                                const SizedBox(width: 8),
                                ...posList.map((p) => Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: posColor(p).withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color:
                                              posColor(p).withOpacity(0.4),
                                        ),
                                      ),
                                      child: Text(
                                        p,
                                        style: T.caption(color: Colors.white)
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                      ),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Definition cards ──────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => DefinitionCard(
                  definition: definitions[i],
                  index: i,
                ),
                childCount: definitions.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
