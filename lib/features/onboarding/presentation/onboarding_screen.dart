import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes.dart';
import '../data/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final _pages = const [
    {
      'title': 'Manage Your Shop Easily',
      'body':
          'Track sales, products, stock, customers, and payments from one simple POS system.',
      'icon': Icons.storefront,
    },
    {
      'title': 'Sell Faster',
      'body':
          'Add products to cart, accept payments, calculate change, and generate receipts instantly.',
      'icon': Icons.flash_on,
    },
    {
      'title': 'Know Your Business Daily',
      'body':
          'View daily sales, stock value, low-stock alerts, and performance reports in real time.',
      'icon': Icons.bar_chart,
    },
    {
      'title': 'Create Your Shop',
      'body':
          'Sign up, create your shop, and start managing your business with confidence.',
      'icon': Icons.create,
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await ref.read(onboardingProvider.notifier).markSeen();
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  void _skip() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: _skip, child: const Text('Skip')),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: _index == i ? 1.0 : 0.94,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              color: color.withAlpha((0.12 * 255).round()),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: _buildArtwork(i, page['icon'] as IconData),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          page['title'] as String,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page['body'] as String,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Row(
                children: [
                  Row(
                    children: List.generate(
                      _pages.length,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _index == i ? 18 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _index == i
                              ? color
                              : color.withAlpha((0.24 * 255).round()),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if (_index < _pages.length - 1) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                    child: Text(
                      _index < _pages.length - 1 ? 'Next' : 'Get Started',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildArtwork(int index, IconData fallback) {
  final assetPath = 'assets/onboarding/slide${index + 1}.png';
  return Image.asset(
    assetPath,
    fit: BoxFit.contain,
    errorBuilder: (context, error, stack) {
      return Icon(fallback, size: 64, color: Colors.white);
    },
  );
}
