import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/dictionary_provider.dart';
import '../providers/history_provider.dart';
import '../utils/constants.dart';
import 'result_screen.dart';
import 'history_screen.dart';
import 'auth/login_screen.dart';
import 'welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  final _focusNode  = FocusNode();
  int _tab = 0; // 0 = search, 1 = history

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) context.read<HistoryProvider>().startListening(uid);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final word = _searchCtrl.text.trim();
    if (word.isEmpty) return;
    _focusNode.unfocus();

    final user = context.read<AuthProvider>().user;
    await context.read<DictionaryProvider>().search(word, user);

    if (!mounted) return;
    final dict = context.read<DictionaryProvider>();
    if (dict.status == SearchStatus.success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(query: word, definitions: dict.results),
        ),
      );
    } else if (dict.status == SearchStatus.error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(dict.errorMessage ?? 'Something went wrong.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ));
    }
  }

  Future<void> _signOut() async {
    context.read<HistoryProvider>().stopListening();
    context.read<DictionaryProvider>().reset();
    await context.read<AuthProvider>().signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth    = context.watch<AuthProvider>();
    final user    = auth.user;
    final dict    = context.watch<DictionaryProvider>();
    final history = context.watch<HistoryProvider>();
    final isLoading = dict.status == SearchStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      // ── Bottom Nav ──────────────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.search_rounded,
                  label: 'Search',
                  active: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                ),
                _NavItem(
                  icon: Icons.history_rounded,
                  label: 'History',
                  active: _tab == 1,
                  locked: user == null,
                  onTap: () {
                    if (user == null) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()));
                    } else {
                      setState(() => _tab = 1);
                    }
                  },
                ),
                _NavItem(
                  icon: user != null
                      ? Icons.person_rounded
                      : Icons.person_outline_rounded,
                  label: user != null ? 'Account' : 'Sign In',
                  active: false,
                  onTap: user != null
                      ? _showAccountSheet
                      : () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const LoginScreen())),
                ),
              ],
            ),
          ),
        ),
      ),

      body: _tab == 0
          ? _SearchTab(
              searchCtrl: _searchCtrl,
              focusNode: _focusNode,
              isLoading: isLoading,
              onSearch: _search,
              user: user,
              recentHistory: history.history.take(5).toList(),
            )
          : const HistoryScreen(embedded: true),
    );
  }

  void _showAccountSheet() {
    final user = context.read<AuthProvider>().user;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Avatar
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  (user?.displayName ?? 'G')[0].toUpperCase(),
                  style: T.headline(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user?.displayName ?? 'User',
              style: T.title(),
            ),
            Text(user?.email ?? '', style: T.caption()),
            const SizedBox(height: 24),
            const Divider(color: AppColors.border),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.logout_rounded,
                    color: AppColors.error, size: 20),
              ),
              title: Text('Sign Out',
                  style: T.label(color: AppColors.error)
                      .copyWith(fontSize: 15)),
              onTap: () {
                Navigator.pop(context);
                _signOut();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Search Tab ────────────────────────────────────────────────────────────────

class _SearchTab extends StatelessWidget {
  final TextEditingController searchCtrl;
  final FocusNode focusNode;
  final bool isLoading;
  final VoidCallback onSearch;
  final dynamic user;
  final List<dynamic> recentHistory;

  const _SearchTab({
    required this.searchCtrl,
    required this.focusNode,
    required this.isLoading,
    required this.onSearch,
    required this.user,
    required this.recentHistory,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── Gradient header ────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    Text(
                      user != null
                          ? 'Hello, ${user!.displayName?.split(' ').first ?? 'there'} 👋'
                          : 'Explore Words',
                      style: T.label(color: Colors.white.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'What are you\nlooking for?',
                      style: T.display(color: Colors.white),
                    ),
                    const SizedBox(height: 22),

                    // Search bar
                    Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          const Icon(Icons.search_rounded,
                              color: AppColors.textSecondary, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: searchCtrl,
                              focusNode: focusNode,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) => onSearch(),
                              style: T.body().copyWith(fontSize: 15),
                              decoration: InputDecoration(
                                hintText: 'Search a word…',
                                hintStyle: T.body(
                                  color: AppColors.textLight,
                                ).copyWith(fontSize: 15),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                                filled: false,
                              ),
                            ),
                          ),
                          if (isLoading)
                            const Padding(
                              padding: EdgeInsets.only(right: 14),
                              child: SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: onSearch,
                              child: Container(
                                margin: const EdgeInsets.all(7),
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white, size: 18,
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

        // ── Body content ───────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Recent searches
              if (user != null && recentHistory.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Searches', style: T.title()),
                    GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const HistoryScreen())),
                      child: Text('See all',
                          style: T.label(color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...recentHistory.map((h) => _RecentCard(
                      word: h.word,
                      pos: h.partOfSpeech,
                      onTap: () {
                        searchCtrl.text = h.word;
                        onSearch();
                      },
                    )),
              ],

              // Guest banner
              if (user == null) _GuestBanner(
                onSignIn: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen())),
              ),

              // Empty state for logged-in users with no history yet
              if (user != null && recentHistory.isEmpty)
                _EmptyState(),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Recent search card ────────────────────────────────────────────────────────

class _RecentCard extends StatelessWidget {
  final String word, pos;
  final VoidCallback onTap;
  const _RecentCard({required this.word, required this.pos, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = posColor(pos);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: c.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.history_rounded, size: 18, color: c),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(word, style: T.label().copyWith(
                    fontSize: 15, fontWeight: FontWeight.w700)),
                  if (pos.isNotEmpty)
                    Text(pos, style: T.caption(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}

// ── Guest banner ──────────────────────────────────────────────────────────────

class _GuestBanner extends StatelessWidget {
  final VoidCallback onSignIn;
  const _GuestBanner({required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLight,
            AppColors.accentLight,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.bookmark_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Save your searches',
                    style: T.label().copyWith(
                      fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text('Create a free account to keep history.',
                    style: T.caption(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onSignIn,
                  child: Text('Sign up free →',
                      style: T.label(color: AppColors.primary).copyWith(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_rounded,
                  size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text('Start searching!', style: T.title()),
            const SizedBox(height: 6),
            Text(
              'Type any English word above\nto see its definition.',
              textAlign: TextAlign.center,
              style: T.subtitle(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom nav item ───────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool locked;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    this.locked = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: active ? AppColors.primary : AppColors.textSecondary,
                  ),
                  if (locked)
                    Positioned(
                      right: -4, top: -4,
                      child: Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.surface, width: 1.5),
                        ),
                        child: const Icon(Icons.lock_rounded,
                            size: 6, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: T.caption(
                color: active ? AppColors.primary : AppColors.textSecondary,
              ).copyWith(fontWeight: active ? FontWeight.w700 : FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}
