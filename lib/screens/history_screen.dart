import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/search_history.dart';
import '../providers/auth_provider.dart';
import '../providers/dictionary_provider.dart';
import '../providers/history_provider.dart';
import '../utils/constants.dart';
import 'result_screen.dart';

class HistoryScreen extends StatelessWidget {
  /// When [embedded] is true the screen is shown inside HomeScreen's bottom-nav
  /// tab, so it omits its own app bar header.
  final bool embedded;
  const HistoryScreen({super.key, this.embedded = false});

  Future<void> _reSearch(BuildContext context, String word) async {
    final user = context.read<AuthProvider>().user;
    await context.read<DictionaryProvider>().search(word, user);
    if (!context.mounted) return;
    final dict = context.read<DictionaryProvider>();
    if (dict.status == SearchStatus.success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(query: word, definitions: dict.results),
        ),
      );
    }
  }

  Future<void> _confirmClear(BuildContext context) async {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all history?'),
        content: const Text(
            'This permanently deletes your entire search history.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<HistoryProvider>().clearAll(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();
    final uid     = context.watch<AuthProvider>().user?.uid;

    // Group entries by date
    final grouped = <String, List<SearchHistory>>{};
    for (final item in history.history) {
      final key = _dayLabel(item.searchedAt);
      grouped.putIfAbsent(key, () => []).add(item);
    }
    final keys = grouped.keys.toList();

    if (embedded) {
      return _Body(
        grouped: grouped,
        keys: keys,
        loading: history.loading,
        errorMessage: history.errorMessage,
        uid: uid,
        onReSearch: (w) => _reSearch(context, w),
        onDelete: (id) =>
            uid != null ? context.read<HistoryProvider>().deleteEntry(uid, id) : null,
        onClear: () => _confirmClear(context),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.headerBg,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white70, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('History', style: T.title(color: Colors.white)),
            actions: [
              if (history.history.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined,
                      color: Colors.white70),
                  onPressed: () => _confirmClear(context),
                ),
            ],
          ),
          SliverFillRemaining(
            child: _Body(
              grouped: grouped,
              keys: keys,
              loading: history.loading,
              errorMessage: history.errorMessage,
              uid: uid,
              onReSearch: (w) => _reSearch(context, w),
              onDelete: (id) =>
                  uid != null
                      ? context.read<HistoryProvider>().deleteEntry(uid, id)
                      : null,
              onClear: () => _confirmClear(context),
            ),
          ),
        ],
      ),
    );
  }

  String _dayLabel(DateTime dt) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d     = DateTime(dt.year, dt.month, dt.day);
    if (d == today) return 'Today';
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('MMMM d, yyyy').format(dt);
  }
}

// ── Body (shared between embedded and standalone) ─────────────────────────────

class _Body extends StatelessWidget {
  final Map<String, List<SearchHistory>> grouped;
  final List<String> keys;
  final bool loading;
  final String? errorMessage;
  final String? uid;
  final void Function(String word) onReSearch;
  final void Function(String id) onDelete;
  final VoidCallback onClear;

  const _Body({
    required this.grouped,
    required this.keys,
    required this.loading,
    required this.errorMessage,
    required this.uid,
    required this.onReSearch,
    required this.onDelete,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (errorMessage != null) {
      return Center(
          child: Text(errorMessage!,
              style: T.body(color: AppColors.error)));
    }
    if (grouped.isEmpty) {
      return _EmptyHistory();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      itemCount: keys.length,
      itemBuilder: (context, gi) {
        final dayLabel = keys[gi];
        final items    = grouped[dayLabel]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 4),
              child: Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(dayLabel,
                      style: T.label(color: AppColors.textSecondary)
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  const Expanded(
                      child: Divider(color: AppColors.border, height: 1)),
                ],
              ),
            ),
            ...items.map((h) => _HistoryCard(
                  item: h,
                  onTap: () => onReSearch(h.word),
                  onDismiss: () => onDelete(h.id),
                )),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

// ── History card ──────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final SearchHistory item;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _HistoryCard({
    required this.item,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final c = posColor(item.partOfSpeech);
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.error, size: 22),
      ),
      onDismissed: (_) => onDismiss(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Color dot
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: c.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(Icons.article_outlined, size: 20, color: c),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(item.word,
                            style: T.label().copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            )),
                        if (item.partOfSpeech.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: c.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(item.partOfSpeech,
                                style: T.caption(color: c).copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11)),
                          ),
                        ],
                      ],
                    ),
                    if (item.firstDefinition.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        item.firstDefinition,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: T.caption(color: AppColors.textSecondary)
                            .copyWith(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(DateFormat('h:mm a').format(item.searchedAt),
                      style: T.caption().copyWith(fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.history_rounded,
                size: 38, color: Colors.white),
          ),
          const SizedBox(height: 18),
          Text('No history yet', style: T.title()),
          const SizedBox(height: 6),
          Text(
            'Words you search will appear here.',
            style: T.subtitle(),
          ),
        ],
      ),
    );
  }
}
