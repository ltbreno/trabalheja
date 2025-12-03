import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/auth/view/welcome_page.dart';

class OnboardingImprovedPage extends StatefulWidget {
  const OnboardingImprovedPage({super.key});

  @override
  State<OnboardingImprovedPage> createState() => _OnboardingImprovedPageState();
}

class _OnboardingImprovedPageState extends State<OnboardingImprovedPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      imagePath: 'assets/images/onboarding_background.png',
      title: 'Conecte-se com\nfreelancers locais!',
      subtitle:
          'TrabalheJá facilita o encontro entre freelancers e quem precisa de um serviço!',
    ),
    OnboardingData(
      imagePath: 'assets/images/onboarding_background_2.png',
      title: 'Encontre trabalhos\nperto de você',
      subtitle: 'Veja serviços disponíveis no mapa e envie suas propostas.',
    ),
    OnboardingData(
      imagePath: 'assets/images/onboarding_background_3.png',
      title: 'Receba propostas\ne escolha a melhor',
      subtitle: 'Compare orçamentos e escolha o freelancer ideal para seu serviço.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    // Marcar que o usuário já viu o onboarding
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);
    } catch (e) {
      print('Erro ao salvar preferência de onboarding: $e');
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const WelcomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColorsNeutral.neutral0,
      body: SafeArea(
        child: Column(
          children: [
            // Botão Pular no topo direito
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.spacing16),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    'Pular',
                    style: AppTypography.contentMedium.copyWith(
                      color: AppColorsNeutral.neutral700,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColorsNeutral.neutral700,
                    ),
                  ),
                ),
              ),
            ),

            // PageView com conteúdo
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index], screenHeight);
                },
              ),
            ),

            // Indicadores de página
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacing24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing4),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColorsPrimary.primary700
                          : AppColorsNeutral.neutral300,
                      borderRadius: AppRadius.radiusRound,
                    ),
                  );
                }),
              ),
            ),

            // Botão Continuar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.spacing24,
                0,
                AppSpacing.spacing24,
                AppSpacing.spacing32,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: AppButton.primary(
                  key: ValueKey<int>(_currentPage),
                  text: _currentPage == _pages.length - 1 ? 'Começar' : 'Continuar',
                  iconRightPath: _currentPage == _pages.length - 1
                      ? null
                      : 'assets/icons/arrow_forward.svg',
                  onPressed: _nextPage,
                  minWidth: double.infinity,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data, double screenHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Imagem com animação
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: ClipRRect(
              borderRadius: AppRadius.radius24,
              child: Image.asset(
                data.imagePath,
                height: screenHeight * 0.4,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: screenHeight * 0.4,
                    decoration: BoxDecoration(
                      color: AppColorsPrimary.primary100,
                      borderRadius: AppRadius.radius24,
                    ),
                    child: Icon(
                      Icons.image,
                      size: 100,
                      color: AppColorsPrimary.primary300,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 40.0),

          // Título com animação
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Text(
              data.title,
              textAlign: TextAlign.center,
              style: AppTypography.heading1.copyWith(
                color: AppColorsPrimary.primary800,
              ),
            ),
          ),

          const SizedBox(height: 16.0),

          // Subtítulo com animação
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 700),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Text(
              data.subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.contentRegular.copyWith(
                color: AppColorsNeutral.neutral600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String imagePath;
  final String title;
  final String subtitle;

  OnboardingData({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });
}

