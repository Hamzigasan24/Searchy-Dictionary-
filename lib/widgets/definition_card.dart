import 'package:flutter/material.dart';
import '../models/word_definition.dart';
import '../utils/constants.dart';

class DefinitionCard extends StatelessWidget {
  final WordDefinition definition;
  final int index;

  const DefinitionCard({super.key, required this.definition, required this.index});

  @override
  Widget build(BuildContext context) {
    final c = posColor(definition.partOfSpeech);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Colored left accent bar
              Container(width: 4, color: c),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // POS badge + pronunciation
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: c.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              definition.partOfSpeech,
                              style: T.label(color: c).copyWith(
                                  fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                          if (definition.pronunciation.isNotEmpty) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '/ ${definition.pronunciation} /',
                                style: T.caption(
                                  color: AppColors.textSecondary,
                                ).copyWith(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Definitions
                      ...List.generate(definition.definitions.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Number bubble
                              Container(
                                width: 22, height: 22,
                                margin: const EdgeInsets.only(
                                    right: 10, top: 2),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: c.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${i + 1}',
                                  style: T.caption(color: c).copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  definition.definitions[i],
                                  style: T.body(),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      // Example sentence
                      if (definition.examples.isNotEmpty) ...[
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: c.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: c.withValues(alpha: 0.12)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.format_quote_rounded,
                                  size: 15, color: c.withValues(alpha: 0.6)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  definition.examples.first,
                                  style: T.caption(
                                    color: AppColors.textSecondary,
                                  ).copyWith(
                                    fontStyle: FontStyle.italic,
                                    height: 1.5,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Synonyms chips
                      if (definition.synonyms.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            Text('Also: ',
                                style: T.caption(color: AppColors.textSecondary)
                                    .copyWith(fontWeight: FontWeight.w600)),
                            ...definition.synonyms.take(5).map(
                              (s) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceAlt,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(s,
                                    style: T.caption(
                                            color: AppColors.textSecondary)
                                        .copyWith(fontSize: 12)),
                              ),
                            ),
                          ],
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
    );
  }
}
