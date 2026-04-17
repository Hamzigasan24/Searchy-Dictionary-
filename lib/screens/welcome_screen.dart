import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'auth/login_screen.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.headerBg,
      body: Stack(
        children: [
          // ── Decorative blobs ─────────────────────────────────────────
          Positioned(
            top: -80,
            right: -80,
            child:
                _Blob(size: 260, color: Colors.white.withValues(alpha: 0.04)),
          ),
          Positioned(
            top: 100,
            left: -60,
            child:
                _Blob(size: 180, color: Colors.white.withValues(alpha: 0.03)),
          ),
          Positioned(
            top: size.height * 0.18,
            right: 24,
            child: _Blob(
                size: 100, color: AppColors.accent.withValues(alpha: 0.12)),
          ),

          // ── Floating word chips ──────────────────────────────────────
          Positioned(
            top: size.height * 0.09,
            left: 24,
            child: _WordChip('serendipity'),
          ),
          Positioned(
            top: size.height * 0.18,
            right: 20,
            child: _WordChip('ephemeral'),
          ),
          Positioned(
            top: size.height * 0.28,
            left: 40,
            child: _WordChip('mellifluous'),
          ),

          // ── Main content ─────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slideUp,
                child: Column(
                  children: [
                    // ── Hero ────────────────────────────────────────────
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon mark
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: AppColors.accentGradient,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.accent.withValues(alpha: 0.35),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.auto_stories_rounded,
                              size: 42,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'SearcHub',
                            style: T.display(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Every word, defined.',
                            style: T.subtitle(
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Bottom card ──────────────────────────────────────
                    Expanded(
                      flex: 6,
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(36),
                          ),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Drag handle
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 4,
                                  margin: const EdgeInsets.only(bottom: 24),
                                  decoration: BoxDecoration(
                                    color: AppColors.border,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),

                              Text('Get started', style: T.headline()),
                              const SizedBox(height: 6),
                              Text(
                                'Create an account to save your searches,\nor explore as a guest.',
                                style: T.subtitle(),
                              ),
                              const SizedBox(height: 24),

                              // Feature pills
                              _FeatureRow(
                                icon: Icons.search_rounded,
                                label: 'Search any English word',
                                available: true,
                              ),
                              const SizedBox(height: 10),
                              _FeatureRow(
                                icon: Icons.bookmark_rounded,
                                label: 'Save & review search history',
                                available: false,
                              ),
                              const SizedBox(height: 10),
                              _FeatureRow(
                                icon: Icons.sync_rounded,
                                label: 'Sync history across devices',
                                available: false,
                              ),
                              const SizedBox(height: 28),

                              // Sign in button
                              _GradientButton(
                                label: 'Sign In / Create Account',
                                icon: Icons.person_rounded,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Guest button
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const HomeScreen(),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.explore_outlined,
                                    size: 19,
                                    color: AppColors.textSecondary,
                                  ),
                                  label: Text(
                                    'Continue as Guest',
                                    style: T
                                        .label(
                                          color: AppColors.textSecondary,
                                        )
                                        .copyWith(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: AppColors.border,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: Text(
                                  'Guest searches are not saved.',
                                  style: T.caption(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

class _WordChip extends StatelessWidget {
  final String word;
  const _WordChip(this.word);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        word,
        style: T.label(color: Colors.white.withValues(alpha: 0.55)),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool available;
  const _FeatureRow({
    required this.icon,
    required this.label,
    required this.available,
  });

  @override
  Widget build(BuildContext context) {
    final color = available ? AppColors.success : AppColors.textLight;
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: T
                .label(
                  color: available
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                )
                .copyWith(fontSize: 14),
          ),
        ),
        Icon(
          available ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
          size: 16,
          color: available ? AppColors.success : AppColors.textLight,
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 19, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: T.label(color: Colors.white).copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
