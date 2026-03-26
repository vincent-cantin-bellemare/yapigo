import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:rundate/theme/app_theme.dart';
import 'package:rundate/screens/auth/signup_wizard_screen.dart';
import 'package:rundate/screens/onboarding/guest_events_screen.dart';
import 'package:rundate/widgets/app_logo.dart';
import 'package:rundate/widgets/demo_banner.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPage(
      icon: Icons.directions_run,
      assetPath: 'assets/onboarding/onboarding_quartier.png',
      title: 'Choisis ton quartier',
      subtitle:
          'Plateau, Mile-End, Griffintown...\nTes activités sportives sociales, c\'est dans ton coin qu\'on les planifie!',
    ),
    _OnboardingPage(
      icon: Icons.groups,
      assetPath: 'assets/onboarding/onboarding_group.png',
      title: 'Bouge avec un groupe de gens actifs',
      subtitle:
          'Tu te retrouves avec des gens qui bougent comme toi — pour voir si ça clique en vrai.',
    ),
    _OnboardingPage(
      icon: Icons.local_cafe,
      assetPath: 'assets/onboarding/onboarding_apero.png',
      title: 'Rendez-vous au point de départ',
      subtitle:
          'Vous choisissez l\'itinéraire ensemble, avec des repères d\'intensité clairs (Chill, Modéré, Intense...).\nAprès l\'activité : Ravito Smoothie pour jaser tranquillement.',
    ),
  ];

  void _goToSignup() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SignupWizardScreen()),
    );
  }

  void _goToConnectedMode() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GuestEventsScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Row(
                children: [
                  const SizedBox(width: 56),
                  const Expanded(
                    child: Center(
                      child: AppLogo(size: 120, fullLogo: true),
                    ),
                  ),
                  SizedBox(
                    width: 56,
                    child: TextButton(
                      onPressed: _goToSignup,
                      child: Text(
                        'Passer',
                        style: GoogleFonts.dmSans(
                          color: AppTheme.slateGrey,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _pages[i],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SmoothPageIndicator(
                controller: _controller,
                count: _pages.length,
                effect: WormEffect(
                  dotColor: AppTheme.slateGrey.withValues(alpha: 0.25),
                  activeDotColor: AppTheme.ocean,
                  dotHeight: 8,
                  dotWidth: 8,
                  spacing: 12,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: SizedBox(
                width: double.infinity,
                child: _currentPage == _pages.length - 1
                    ? ElevatedButton(
                        onPressed: _goToConnectedMode,
                        child: const Text('Découvrir les événements'),
                      )
                    : ElevatedButton(
                        onPressed: () => _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                        child: const Text('Suivant'),
                      ),
              ),
            ),
            if (_currentPage == _pages.length - 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _goToSignup,
                    child: const Text('Créer mon compte'),
                  ),
                ),
              ),
            const _DemoToggleRow(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String? assetPath;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.icon,
    this.assetPath,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: assetPath != null
                ? Image.asset(
                    assetPath!,
                    width: 220,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.ocean.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 56, color: AppTheme.ocean),
                    ),
                  )
                : Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.ocean.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 56, color: AppTheme.ocean),
                  ),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.slateGrey,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}

/// Subtle demo mode toggle shown at the bottom of onboarding.
class _DemoToggleRow extends StatelessWidget {
  const _DemoToggleRow();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: demoMode,
      builder: (context, isConnected, _) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.slateGrey.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.warning,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'DEMO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isConnected ? 'Connecté' : 'Non connecté',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppTheme.slateGrey,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                height: 28,
                child: Switch.adaptive(
                  value: isConnected,
                  onChanged: (_) => demoMode.toggle(),
                  activeTrackColor: AppTheme.ocean,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
