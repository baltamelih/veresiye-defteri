import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const OnboardingScreen({
    super.key,
    required this.onCompleted,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController pageController = PageController();
  int currentIndex = 0;

  final pages = const [
    _OnboardingPageData(
      icon: Icons.book_rounded,
      title: 'Veresiye Takibini Kolaylaştır',
      description:
      'Müşterilerinin borç ve ödeme kayıtlarını sade, hızlı ve güvenli şekilde takip et.',
    ),
    _OnboardingPageData(
      icon: Icons.groups_rounded,
      title: 'Müşterilerini Düzenli Yönet',
      description:
      'Her müşterinin bakiyesini, işlem geçmişini ve notlarını tek ekrandan görüntüle.',
    ),
    _OnboardingPageData(
      icon: Icons.ios_share_rounded,
      title: 'Bakiye Paylaş ve Dışa Aktar',
      description:
      'Güncel bakiyeyi paylaş, kayıtlarını CSV olarak dışa aktar ve kontrolü elinde tut.',
    ),
  ];

  bool get isLastPage => currentIndex == pages.length - 1;

  void nextPage() {
    if (isLastPage) {
      widget.onCompleted();
      return;
    }

    pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = pages[currentIndex];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: widget.onCompleted,
                  child: const Text('Atla'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: pages.length,
                  onPageChanged: (index) {
                    setState(() => currentIndex = index);
                  },
                  itemBuilder: (context, index) {
                    final item = pages[index];

                    return _OnboardingPage(
                      icon: item.icon,
                      title: item.title,
                      description: item.description,
                    );
                  },
                ),
              ),
              _DotsIndicator(
                count: pages.length,
                activeIndex: currentIndex,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: isLastPage ? 'Başlayalım' : 'Devam Et',
                icon: isLastPage
                    ? Icons.check_rounded
                    : Icons.arrow_forward_rounded,
                onPressed: nextPage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppTheme.primary,
                AppTheme.primaryDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(42),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.22),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 58,
          ),
        ),
        const SizedBox(height: 36),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(
          description,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textLight,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;

  const _DotsIndicator({
    required this.count,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary : AppTheme.border,
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
  });
}