import 'package:flutter/material.dart';
import 'package:online_banking_system/core/constants/app_constants.dart';
import 'package:online_banking_system/core/session/session_manager.dart';
import 'package:online_banking_system/core/theme/app_theme.dart';
import 'package:online_banking_system/shared/widgets/reusable_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: AppStrings.onboardingTitle1,
      description: AppStrings.onboardingDesc1,
      icon: Icons.shield_outlined,
      color: AppTheme.primaryBlue,
    ),
    OnboardingPage(
      title: AppStrings.onboardingTitle2,
      description: AppStrings.onboardingDesc2,
      icon: Icons.send_outlined,
      color: AppTheme.accentGreen,
    ),
    OnboardingPage(
      title: AppStrings.onboardingTitle3,
      description: AppStrings.onboardingDesc3,
      icon: Icons.analytics_outlined,
      color: AppTheme.accentPurple,
    ),
    OnboardingPage(
      title: AppStrings.onboardingTitle4,
      description: AppStrings.onboardingDesc4,
      icon: Icons.notifications_outlined,
      color: AppTheme.warningOrange,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goToLogin() async {
    await SessionManager.instance.setOnboardingSeen(true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final page = pages[_currentPage];

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -40,
            child: _BackdropOrb(
              color: page.color.withValues(alpha: 0.16),
              size: 220,
            ),
          ),
          Positioned(
            top: 140,
            left: -50,
            child: _BackdropOrb(
              color: AppTheme.primaryBlue.withValues(alpha: 0.08),
              size: 160,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing12,
                          vertical: AppTheme.spacing8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Text(
                          '${_currentPage + 1}/${pages.length}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.darkGrey,
                              ),
                        ),
                      ),
                      if (_currentPage != pages.length - 1)
                        TextButton(
                          onPressed: _goToLogin,
                          child: const Text(AppStrings.skip),
                        )
                      else
                        const SizedBox(width: 72),
                    ],
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: pages.length,
                      itemBuilder: (context, index) {
                        return OnboardingPageView(page: pages[index]);
                      },
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(AppTheme.radius24),
                      border: Border.all(color: AppTheme.divider),
                      boxShadow: AppTheme.softShadow,
                    ),
                    padding: const EdgeInsets.all(AppTheme.spacing24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            pages.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 8,
                              width: _currentPage == index ? 28 : 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? page.color
                                    : AppTheme.lightGrey,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing20),
                        if (_currentPage == pages.length - 1)
                          PrimaryButton(
                            label: AppStrings.continueStr,
                            onPressed: _goToLogin,
                            icon: Icons.arrow_forward_rounded,
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: SecondaryButton(
                                  label: AppStrings.skip,
                                  onPressed: _goToLogin,
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacing12),
                              Expanded(
                                child: PrimaryButton(
                                  label: AppStrings.next,
                                  icon: Icons.arrow_forward_rounded,
                                  onPressed: () {
                                    _pageController.nextPage(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPageView extends StatelessWidget {
  final OnboardingPage page;

  const OnboardingPageView({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 248,
              height: 248,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    page.color.withValues(alpha: 0.18),
                    page.color.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Container(
              width: 176,
              height: 176,
              decoration: BoxDecoration(
                color: AppTheme.white,
                shape: BoxShape.circle,
                boxShadow: AppTheme.softShadow,
              ),
              child: Center(
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: page.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: Icon(page.icon, size: 56, color: page.color),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 44),
        Text(
          page.title,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.displayMedium?.copyWith(fontSize: 30),
        ),
        const SizedBox(height: AppTheme.spacing16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing12),
          child: Text(
            page.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.mediumGrey,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

class _BackdropOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _BackdropOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
