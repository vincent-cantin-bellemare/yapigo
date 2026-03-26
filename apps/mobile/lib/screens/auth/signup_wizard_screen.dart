import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:rundate/data/quebec_cities.dart';
import 'package:rundate/screens/profile/terms_screen.dart';
import 'package:rundate/screens/profile/privacy_screen.dart';
import 'package:rundate/screens/profile/community_rules_screen.dart';
import 'package:rundate/screens/profile/bio_quiz_screen.dart';
import 'package:rundate/theme/app_theme.dart';
import 'package:rundate/utils/app_locale.dart';
import 'package:rundate/widgets/demo_banner.dart';

class SignupWizardScreen extends StatefulWidget {
  const SignupWizardScreen({super.key});

  @override
  State<SignupWizardScreen> createState() => _SignupWizardScreenState();
}

class _SignupWizardScreenState extends State<SignupWizardScreen> {
  final _controller = PageController();
  int _currentStep = 0;
  bool get _showNeighborhoodStep => _selectedCity == 'Montréal';
  int get _totalSteps => 14 + (_showNeighborhoodStep ? 1 : 0);

  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  final _customGoalController = TextEditingController();
  String? _selectedGender;
  String? _selectedOrientation;
  int _selectedBirthYear = DateTime.now().year - 30;
  late final FixedExtentScrollController _birthYearScrollController;
  String? _selectedProvince;
  String? _selectedCity;
  String? _selectedNeighborhood;
  final _citySearchController = TextEditingController();
  List<QuebecCity> _cityResults = quebecCities;
  final Set<String> _selectedGoals = {};

  int get _calculatedAge => DateTime.now().year - _selectedBirthYear;

  @override
  void initState() {
    super.initState();
    final maxYear = DateTime.now().year - 18;
    _birthYearScrollController = FixedExtentScrollController(
      initialItem: maxYear - _selectedBirthYear,
    );
    _phoneController.addListener(_onFieldChanged);
    _otpController.addListener(_onFieldChanged);
    _nameController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

  int get _goalsStepIndex => _showNeighborhoodStep ? 9 : 8;

  bool get _canContinue {
    switch (_currentStep) {
      case 0:
        return _phoneController.text.replaceAll(RegExp(r'\D'), '').length >= 10;
      case 1:
        return _otpController.text.length >= 4;
      case 2:
        return _nameController.text.trim().isNotEmpty;
      default:
        if (_currentStep == _goalsStepIndex) {
          return _selectedGoals.isNotEmpty;
        }
        return true;
    }
  }

  void _next() {
    if (_currentStep < _totalSteps - 1) {
      HapticFeedback.selectionClick();
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _back() {
    if (_currentStep > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onFieldChanged);
    _otpController.removeListener(_onFieldChanged);
    _nameController.removeListener(_onFieldChanged);
    _controller.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    _customGoalController.dispose();
    _birthYearScrollController.dispose();
    _citySearchController.dispose();
    _confettiController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentStep = i),
                children: [
                  _buildPhoneStep(),
                  _buildOtpStep(),
                  _buildNameStep(),
                  _buildGenderStep(),
                  _buildOrientationStep(),
                  _buildAgeStep(),
                  _buildProvinceStep(),
                  _buildCityStep(),
                  if (_showNeighborhoodStep) _buildNeighborhoodStep(),
                  _buildGoalsStep(),
                  _buildPhotoStep(),
                  _buildBioStep(),
                  _buildSelfieStep(),
                  _buildTermsStep(),
                  _buildWelcomeStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          if (_currentStep == 0)
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, size: 22),
              color: AppTheme.textColor(context),
            )
          else if (_currentStep < _totalSteps - 1)
            IconButton(
              onPressed: _back,
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              color: AppTheme.textColor(context),
            )
          else
            const SizedBox(width: 48),
          const Spacer(),
          if (_currentStep == 0) _buildLangToggle(),
          if (_currentStep < _totalSteps - 1 && _currentStep >= _goalsStepIndex + 1 && _currentStep <= _goalsStepIndex + 3)
            TextButton(
              onPressed: _next,
              child: Text('Passer', style: GoogleFonts.dmSans(color: AppTheme.secondaryText(context))),
            ),
        ],
      ),
    );
  }

  Widget _buildLangToggle() {
    final isFr = isFrench;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.slateGrey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() => setLocale(const Locale('fr'))),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isFr ? AppTheme.ocean.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'FR',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: isFr ? FontWeight.w700 : FontWeight.w400,
                  color: isFr ? AppTheme.ocean : AppTheme.slateGrey,
                ),
              ),
            ),
          ),
          Text('|', style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.slateGrey.withValues(alpha: 0.4))),
          GestureDetector(
            onTap: () => setState(() => setLocale(const Locale('en'))),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: !isFr ? AppTheme.ocean.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'EN',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: !isFr ? FontWeight.w700 : FontWeight.w400,
                  color: !isFr ? AppTheme.ocean : AppTheme.slateGrey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    if (_currentStep == _totalSteps - 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: (_currentStep + 1) / _totalSteps),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: AppTheme.slateGrey.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.ocean),
                  minHeight: 4,
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          SmoothPageIndicator(
            controller: _controller,
            count: _totalSteps,
            effect: ExpandingDotsEffect(
              dotColor: AppTheme.slateGrey.withValues(alpha: 0.25),
              activeDotColor: AppTheme.ocean,
              dotHeight: 6,
              dotWidth: 6,
              expansionFactor: 3,
              spacing: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLayout({
    required String title,
    required Widget child,
    Widget? bottomButton,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 32),
          Expanded(child: child),
          ?bottomButton,
        ],
      ),
    );
  }

  Widget _buildPhoneStep() {
    return _buildStepLayout(
      title: 'Ton numéro',
      child: Column(
        children: [
          Text(
            'On utilise ton numéro pour vérifier ton identité. '
            'C\'est notre façon de s\'assurer que chaque membre est une vraie personne.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppTheme.secondaryText(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              prefixText: '+1  ',
              prefixStyle: GoogleFonts.dmSans(fontSize: 22, color: AppTheme.secondaryText(context)),
              hintText: '514 555 1234',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.lock_outline, size: 16, color: AppTheme.teal),
              const SizedBox(width: 6),
              Text(
                'Ton numéro ne sera jamais partagé.',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppTheme.teal,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      bottomButton: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _canContinue ? _next : null,
          child: const Text('Continuer'),
        ),
      ),
    );
  }

  Widget _buildOtpStep() {
    return _buildStepLayout(
      title: 'Entre le code reçu',
      child: Column(
        children: [
          TextField(
            controller: _otpController,
            autofocus: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: 16),
            maxLength: 4,
            decoration: const InputDecoration(counterText: ''),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Code renvoyé!', style: GoogleFonts.dmSans()),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('Renvoyer le code', style: GoogleFonts.dmSans(color: AppTheme.ocean)),
          ),
        ],
      ),
      bottomButton: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _canContinue ? _next : null,
          child: const Text('Valider'),
        ),
      ),
    );
  }

  Widget _buildNameStep() {
    return _buildStepLayout(
      title: 'Comment on t\'appelle?',
      child: TextField(
        controller: _nameController,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        style: GoogleFonts.dmSans(fontSize: 22),
        decoration: const InputDecoration(hintText: 'Ton prénom'),
      ),
      bottomButton: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _canContinue ? _next : null,
          child: const Text('Continuer'),
        ),
      ),
    );
  }

  Widget _buildGenderStep() {
    return _buildStepLayout(
      title: 'Tu es...',
      child: Column(
        children: [
          for (final g in ['Homme', 'Femme', 'Non-binaire'])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SelectionCard(
                label: g,
                isSelected: _selectedGender == g,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedGender = g);
                  Future.delayed(const Duration(milliseconds: 300), _next);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrientationStep() {
    const options = [
      'Hétérosexuel(le)',
      'Homosexuel(le)',
      'Bisexuel(le)',
      'Pansexuel(le)',
      'Autre',
      'Préfère ne pas dire',
    ];
    return _buildStepLayout(
      title: 'Tu te définis comment?',
      child: Column(
        children: [
          for (final o in options)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SelectionCard(
                label: o,
                isSelected: _selectedOrientation == o,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedOrientation = o);
                  Future.delayed(const Duration(milliseconds: 300), _next);
                },
              ),
            ),
        ],
      ),
    );
  }

  static const _yearFunFacts = <int, String>{
    1946: 'le micro-ondes a été inventé par accident 🍿',
    1947: 'on a découvert les Manuscrits de la mer Morte 📜',
    1948: 'le velcro a été inventé grâce à un chien 🐕',
    1949: 'le premier Polaroid est sorti — les selfies avant les selfies 📸',
    1950: 'la carte de crédit est née — et les dettes aussi 💳',
    1951: 'la première émission TV en couleur a été diffusée 📺',
    1952: 'le premier code-barres a été scanné 🏷️',
    1953: 'l\'ADN a révélé ses secrets — tu es 99.9% comme tout le monde 🧬',
    1954: 'le premier four à micro-ondes domestique est arrivé 🍕',
    1955: 'Disneyland a ouvert ses portes — la magie, pour vrai 🏰',
    1956: 'le conteneur maritime a été inventé — merci pour ton stuff d\'Amazon 📦',
    1957: 'le Spoutnik a été lancé — le premier bip de l\'espace 🛰️',
    1958: 'le LEGO moderne est né — et les pieds n\'ont plus jamais été safe 🧱',
    1959: 'la ceinture de sécurité 3 points a été inventée par Volvo 🚗',
    1960: 'le laser a été inventé — pew pew 🔫',
    1961: 'Gagarine est allé dans l\'espace — premier touriste orbital 🚀',
    1962: 'le premier satellite de télécommunication a été lancé 📡',
    1963: 'la cassette audio est née — les mixtapes à venir 📼',
    1964: 'le premier train à grande vitesse japonais a roulé 🚄',
    1965: 'le premier email... ah non, pas encore. Mais la mini-jupe oui! 👗',
    1966: 'Star Trek a commencé — les geeks te remercient 🖖',
    1967: 'la première greffe du cœur a été réalisée ❤️',
    1968: 'la souris d\'ordinateur a été inventée — clic clic 🖱️',
    1969: 'on a marché sur la Lune — et toi tu cours vers ton date 🌙',
    1970: 'le premier Marathon de New York a eu lieu — ça te dit quelque chose? 🏃',
    1971: 'le premier courriel a été envoyé — et ta boîte est pleine depuis 📧',
    1972: 'Pong est sorti — le premier gamer est né 🎮',
    1973: 'le premier appel cellulaire a été fait — 1 kg le téléphone 📱',
    1974: 'le Rubik\'s Cube a été inventé — personne l\'a encore résolu 🟩',
    1975: 'le premier ordi personnel (Altair 8800) est sorti 🖥️',
    1976: 'Apple a été fondé dans un garage — tu devrais ranger le tien 🍎',
    1977: 'Star Wars est sorti — que la Force soit avec ton cardio ⭐',
    1978: 'le premier bébé éprouvette est né 👶',
    1979: 'le Walkman de Sony est sorti — sport + musique = toi 🎧',
    1980: 'le Post-it a été inventé — ton frigo te dit merci 📝',
    1981: 'le premier IBM PC est sorti — ton ordi pèserait 25 lbs 💾',
    1982: 'le CD a été inventé — t\'as sûrement rayé les tiens 💿',
    1983: 'Internet (TCP/IP) est officiellement né — et les rencontres en ligne aussi 🌐',
    1984: 'le Macintosh est sorti — et Big Brother nous regarde 👁️',
    1985: 'Windows 1.0 est sorti — ton premier clic de frustration 🪟',
    1986: 'la Coupe du monde de Maradona — la main de Dieu ⚽',
    1987: 'Les Simpsons sont apparus — D\'oh! 🍩',
    1988: 'le premier virus informatique s\'est propagé 🐛',
    1989: 'le Game Boy est sorti — Tetris > Netflix 🎮',
    1990: 'le World Wide Web a été créé — et la procrastination aussi 🕸️',
    1991: 'Linux est né — les nerds font la fête 🐧',
    1992: 'le premier SMS a été envoyé — "Merry Christmas" 💬',
    1993: 'le web est devenu public — bienvenue dans le chaos 🌍',
    1994: 'Amazon a été fondé — ton facteur est épuisé depuis 📦',
    1995: 'Java et JavaScript sont nés — non, c\'est pas la même chose ☕',
    1996: 'Dolly la brebis a été clonée — bêêê 🐑',
    1997: 'le premier film de Harry Potter... ah non, le livre! 📚',
    1998: 'Google a été fondé — avant ça, on demandait à sa mère 🔍',
    1999: 'le bug de l\'an 2000 faisait paniquer tout le monde — pour rien 🐛',
    2000: 'la clé USB est apparue — adieu les disquettes! 💾',
    2001: 'Wikipédia est né — ton prof déteste ça 📖',
    2002: 'l\'iPod a changé la musique — 1000 chansons dans ta poche 🎵',
    2003: 'Skype est lancé — les appels longue distance gratuits 📞',
    2004: 'Facebook est né dans un dortoir — et ta vie privée est morte 👤',
    2005: 'YouTube est lancé — "Me at the zoo" 🎬',
    2006: 'Twitter est né — en 140 caractères max 🐦',
    2007: 'le premier iPhone est sorti — Steve Jobs avait raison 📱',
    2008: 'Spotify a été lancé — tes playlists d\'activité t\'attendent 🎶',
  };

  String? get _yearFunFact => _yearFunFacts[_selectedBirthYear];

  Widget _buildAgeStep() {
    final now = DateTime.now();
    final maxYear = now.year - 18;
    final minYear = now.year - 80;
    final yearCount = maxYear - minYear + 1;
    final funFact = _yearFunFact;

    return _buildStepLayout(
      title: 'Ton année de naissance?',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              '$_calculatedAge ans',
              key: ValueKey(_calculatedAge),
              style: GoogleFonts.nunito(
                fontSize: 52,
                fontWeight: FontWeight.w800,
                color: AppTheme.ocean,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Né(e) en $_selectedBirthYear',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: AppTheme.secondaryText(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (funFact != null) ...[
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(_selectedBirthYear),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.teal.withValues(alpha: 0.25)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Savais-tu qu\'en $_selectedBirthYear, $funFact',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppTheme.textColor(context),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ça ne te rajeunit pas, hein? 😏',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.secondaryText(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: Stack(
              children: [
                Center(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.ocean.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.ocean.withValues(alpha: 0.3)),
                    ),
                  ),
                ),
                ListWheelScrollView.useDelegate(
                  controller: _birthYearScrollController,
                  itemExtent: 50,
                  perspective: 0.003,
                  diameterRatio: 1.5,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedBirthYear = maxYear - index);
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: yearCount,
                    builder: (context, index) {
                      final year = maxYear - index;
                      final isSelected = year == _selectedBirthYear;
                      return Center(
                        child: Text(
                          '$year',
                          style: GoogleFonts.nunito(
                            fontSize: isSelected ? 28 : 20,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w400,
                            color: isSelected ? AppTheme.ocean : AppTheme.slateGrey.withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomButton: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _next,
          child: const Text('Continuer'),
        ),
      ),
    );
  }

  static const _cityAssets = {
    'Montréal': 'assets/cities/montreal.png',
    'Québec': 'assets/cities/quebec.png',
    'Laval': 'assets/cities/laval.png',
    'Longueuil': 'assets/cities/longueuil.png',
    'Gatineau': 'assets/cities/gatineau.png',
    'Sherbrooke': 'assets/cities/sherbrooke.png',
  };

  static const _quickCities = [
    'Montréal', 'Québec', 'Laval', 'Longueuil', 'Gatineau', 'Sherbrooke',
  ];

  void _onCitySelected(String cityName) {
    HapticFeedback.selectionClick();
    final old = _selectedCity;
    setState(() {
      _selectedCity = cityName;
      if (old == 'Montréal' && cityName != 'Montréal') {
        _selectedNeighborhood = null;
      }
      _citySearchController.clear();
      _cityResults = quebecCities;
    });
    Future.delayed(const Duration(milliseconds: 300), _next);
  }

  Widget _buildProvinceStep() {
    const provinces = [
      ('QC', 'Québec', true),
      ('ON', 'Ontario', false),
      ('BC', 'Colombie-Britannique', false),
      ('AB', 'Alberta', false),
      ('MB', 'Manitoba', false),
      ('SK', 'Saskatchewan', false),
      ('NB', 'Nouveau-Brunswick', false),
      ('NS', 'Nouvelle-Écosse', false),
      ('PE', 'Île-du-Prince-Édouard', false),
      ('NL', 'Terre-Neuve-et-Labrador', false),
    ];

    return _buildStepLayout(
      title: 'Dans quelle province habites-tu?',
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: provinces.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final (code, name, available) = provinces[i];
          final selected = _selectedProvince == code;
          return Tooltip(
            message: available ? '' : 'Bientôt disponible — on y travaille !',
            child: GestureDetector(
              onTap: available
                  ? () {
                      setState(() => _selectedProvince = code);
                      Future.delayed(
                          const Duration(milliseconds: 250), _next);
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.ocean.withValues(alpha: 0.1)
                      : available
                          ? AppTheme.cardColor(context)
                          : AppTheme.slateGrey.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? AppTheme.ocean
                        : AppTheme.slateGrey.withValues(alpha: 0.2),
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: available
                            ? (selected
                                ? AppTheme.ocean.withValues(alpha: 0.15)
                                : AppTheme.slateGrey.withValues(alpha: 0.1))
                            : AppTheme.slateGrey.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          code,
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: available
                                ? (selected
                                    ? AppTheme.ocean
                                    : AppTheme.textColor(context))
                                : AppTheme.slateGrey.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        name,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: available
                              ? AppTheme.textColor(context)
                              : AppTheme.secondaryText(context)
                                  .withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    if (!available)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              AppTheme.slateGrey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '🔧 Bientôt',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppTheme.slateGrey,
                          ),
                        ),
                      )
                    else if (selected)
                      Icon(Icons.check_circle,
                          size: 22, color: AppTheme.ocean),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCityStep() {
    return _buildStepLayout(
      title: 'Tu habites où?',
      child: Column(
        children: [
          // Search field
          TextField(
            controller: _citySearchController,
            onChanged: (q) => setState(() => _cityResults = searchCities(q)),
            style: GoogleFonts.dmSans(
                fontSize: 15, color: AppTheme.textColor(context)),
            decoration: InputDecoration(
              hintText: 'Recherche ta ville...',
              hintStyle: GoogleFonts.dmSans(
                  color: AppTheme.secondaryText(context), fontSize: 15),
              prefixIcon: Icon(Icons.search_rounded,
                  color: AppTheme.secondaryText(context)),
              suffixIcon: _citySearchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 20),
                      onPressed: () => setState(() {
                        _citySearchController.clear();
                        _cityResults = quebecCities;
                      }),
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.cardColor(context),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Quick-access chips (visible when not searching)
          if (_citySearchController.text.isEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickCities.map((city) {
                final selected = _selectedCity == city;
                return GestureDetector(
                  onTap: () => _onCitySelected(city),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.ocean.withValues(alpha: 0.12)
                          : AppTheme.cardColor(context),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppTheme.ocean
                            : AppTheme.slateGrey.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            _cityAssets[city] ?? '',
                            width: 24,
                            height: 24,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Icon(
                                Icons.location_city_rounded,
                                size: 18,
                                color: AppTheme.secondaryText(context)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          city,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? AppTheme.ocean
                                : AppTheme.textColor(context),
                          ),
                        ),
                        if (selected) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.check_circle,
                              color: AppTheme.ocean, size: 16),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Distance banner for selected non-hub city
          if (_selectedCity != null) _buildDistanceBanner(),

          // Filtered results list
          Expanded(
            child: ListView.builder(
              itemCount: _cityResults.length,
              itemBuilder: (context, i) {
                final city = _cityResults[i];
                final selected = _selectedCity == city.name;
                return ListTile(
                  dense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  leading: Icon(
                    Icons.location_on_outlined,
                    size: 20,
                    color:
                        selected ? AppTheme.ocean : AppTheme.slateGrey,
                  ),
                  title: Text(
                    city.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? AppTheme.ocean
                          : AppTheme.textColor(context),
                    ),
                  ),
                  subtitle: Text(
                    city.region,
                    style: GoogleFonts.dmSans(
                        fontSize: 13, color: AppTheme.secondaryText(context)),
                  ),
                  trailing: selected
                      ? const Icon(Icons.check_circle,
                          color: AppTheme.ocean, size: 20)
                      : null,
                  onTap: () => _onCitySelected(city.name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceBanner() {
    final match = quebecCities
        .where((c) => c.name == _selectedCity)
        .toList();
    if (match.isEmpty) return const SizedBox.shrink();

    final city = match.first;
    final result = nearestHub(city);

    if (result == null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.teal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.teal.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                size: 18, color: AppTheme.teal),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Des événements sont organisés dans ta ville!',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.teal,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final km = result.distanceKm.round();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.near_me_rounded,
              size: 18, color: AppTheme.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Les événements les plus près sont à ${result.hub.name} (~$km km). On t\'y attend!',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeighborhoodStep() {
    return _buildStepLayout(
      title: 'Quel est ton quartier?',
      child: ListView(
        children: [
          Text(
            'Optionnel — ça nous aide à te proposer des activités près de chez toi.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppTheme.secondaryText(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: montrealNeighborhoods.map((n) {
              final selected = _selectedNeighborhood == n;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedNeighborhood =
                      _selectedNeighborhood == n ? null : n);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.ocean.withValues(alpha: 0.12)
                        : AppTheme.cardColor(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? AppTheme.ocean
                          : AppTheme.slateGrey.withValues(alpha: 0.2),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    n,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? AppTheme.ocean
                          : AppTheme.textColor(context),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      bottomButton: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: ElevatedButton(
          onPressed: _next,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.ocean,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 0,
            textStyle:
                GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          child: Text(
              _selectedNeighborhood != null ? 'Continuer' : 'Passer'),
        ),
      ),
    );
  }

  String? _generatedBio;

  void _openBioQuiz() async {
    final bio = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => BioQuizScreen(userName: _nameController.text.trim()),
      ),
    );
    if (bio != null && bio.isNotEmpty && mounted) {
      setState(() => _generatedBio = bio);
    }
  }

  Widget _buildGoalsStep() {
    const goals = [
      (icon: Icons.favorite_outline, label: 'Rencontrer quelqu\'un de spécial'),
      (icon: Icons.directions_run_outlined, label: 'Trouver un partenaire de course'),
      (icon: Icons.groups_outlined, label: 'Faire de nouveaux amis coureurs'),
      (icon: Icons.explore_outlined, label: 'Découvrir de nouveaux quartiers en courant'),
      (icon: Icons.fitness_center_outlined, label: 'Me motiver à courir plus souvent'),
    ];

    return _buildStepLayout(
      title: 'Qu\'est-ce que tu cherches?',
      child: ListView(
        children: [
          Text(
            'Sélectionne tout ce qui s\'applique. Ça nous aide à trouver ton match parfait!',
            style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.secondaryText(context), height: 1.4),
          ),
          const SizedBox(height: 20),
          ...goals.map((g) {
            final selected = _selectedGoals.contains(g.label);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (selected) {
                      _selectedGoals.remove(g.label);
                    } else {
                      _selectedGoals.add(g.label);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.ocean.withValues(alpha: 0.08) : AppTheme.cardColor(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? AppTheme.ocean : AppTheme.slateGrey.withValues(alpha: 0.2),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(g.icon, size: 24, color: selected ? AppTheme.ocean : AppTheme.slateGrey),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          g.label,
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                            color: selected ? AppTheme.ocean : AppTheme.textColor(context),
                          ),
                        ),
                      ),
                      if (selected) const Icon(Icons.check_circle, color: AppTheme.ocean, size: 22),
                    ],
                  ),
                ),
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  if (_selectedGoals.contains('_custom')) {
                    _selectedGoals.remove('_custom');
                  } else {
                    _selectedGoals.add('_custom');
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: _selectedGoals.contains('_custom') ? AppTheme.ocean.withValues(alpha: 0.08) : AppTheme.cardColor(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _selectedGoals.contains('_custom') ? AppTheme.ocean : AppTheme.slateGrey.withValues(alpha: 0.2),
                    width: _selectedGoals.contains('_custom') ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 24, color: _selectedGoals.contains('_custom') ? AppTheme.ocean : AppTheme.slateGrey),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _selectedGoals.contains('_custom')
                          ? TextField(
                              controller: _customGoalController,
                              style: GoogleFonts.dmSans(fontSize: 16, color: AppTheme.textColor(context)),
                              decoration: InputDecoration(
                                hintText: 'Dis-nous!',
                                hintStyle: GoogleFonts.dmSans(color: AppTheme.secondaryText(context)),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            )
                          : Text(
                              'Autre...',
                              style: GoogleFonts.dmSans(fontSize: 16, color: AppTheme.secondaryText(context)),
                            ),
                    ),
                    if (_selectedGoals.contains('_custom'))
                      const Icon(Icons.check_circle, color: AppTheme.ocean, size: 22),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomButton: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _canContinue ? _next : null,
          child: const Text('Continuer'),
        ),
      ),
    );
  }

  Widget _buildPhotoStep() {
    return _buildStepLayout(
      title: 'Ta photo de profil',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: AppTheme.slateGrey.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.ocean, width: 3, strokeAlign: BorderSide.strokeAlignOutside),
                ),
                child: const Icon(Icons.add_a_photo_outlined, size: 48, color: AppTheme.ocean),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Ajoute ta meilleure photo!',
              style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textColor(context)),
            ),
            const SizedBox(height: 8),
            Text(
              'Les profils avec photo reçoivent 3x plus de connexions. Montre ton plus beau sourire!',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.secondaryText(context), height: 1.5),
            ),
          ],
        ),
      ),
      bottomButton: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(onPressed: _next, child: const Text('Continuer')),
          const SizedBox(height: 8),
          Center(child: TextButton(
            onPressed: _next,
            child: Text('Passer cette étape', style: GoogleFonts.dmSans(color: AppTheme.secondaryText(context))),
          )),
        ],
      ),
    );
  }

  Widget _buildBioStep() {
    return _buildStepLayout(
      title: 'Ta bio',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppTheme.teal, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Réponds à quelques questions fun et on génère ta bio automatiquement!',
                      style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textColor(context), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openBioQuiz,
                icon: Icon(
                  _generatedBio != null ? Icons.refresh : Icons.auto_awesome,
                  size: 18,
                ),
                label: Text(
                  _generatedBio != null ? 'Régénérer ma bio' : 'Générer ma bio en 2 min ✨',
                  style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.teal,
                  side: const BorderSide(color: AppTheme.teal, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            if (_generatedBio != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.teal.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.teal.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppTheme.teal, size: 18),
                        const SizedBox(width: 8),
                        Text('Bio générée!', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.teal)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _generatedBio!,
                      style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textColor(context), height: 1.4),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomButton: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(onPressed: _next, child: const Text('Continuer')),
          const SizedBox(height: 8),
          Center(child: TextButton(
            onPressed: _next,
            child: Text('Passer cette étape', style: GoogleFonts.dmSans(color: AppTheme.secondaryText(context))),
          )),
        ],
      ),
    );
  }

  Widget _buildSelfieStep() {
    return _buildStepLayout(
      title: 'Selfie de vérification',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 120,
                height: 150,
                decoration: BoxDecoration(
                  color: AppTheme.slateGrey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(color: AppTheme.teal, width: 3),
                ),
                child: const Icon(Icons.camera_front_outlined, size: 48, color: AppTheme.teal),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Confirme ton identité',
              style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textColor(context)),
            ),
            const SizedBox(height: 8),
            Text(
              'Ce selfie n\'est pas public. Il sert uniquement à vérifier que tu es une vraie personne.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.secondaryText(context), height: 1.5),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 16, color: AppTheme.teal),
                const SizedBox(width: 6),
                Text(
                  'Jamais partagé ni visible sur ton profil',
                  style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.teal),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomButton: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(onPressed: _next, child: const Text('Continuer')),
          const SizedBox(height: 8),
          Center(child: TextButton(
            onPressed: _next,
            child: Text('Passer cette étape', style: GoogleFonts.dmSans(color: AppTheme.secondaryText(context))),
          )),
        ],
      ),
    );
  }

  Widget _buildTermsStep() {
    bool accepted = false;
    return StatefulBuilder(
      builder: (context, setLocal) {
        return _buildStepLayout(
          title: 'Avant de commencer',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TermsLink(
                label: 'Conditions d\'utilisation',
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(builder: (_) => const TermsScreen()),
                ),
              ),
              _TermsLink(
                label: 'Politique de confidentialité',
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(builder: (_) => const PrivacyScreen()),
                ),
              ),
              _TermsLink(
                label: 'Règles de la communauté',
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(builder: (_) => const CommunityRulesScreen()),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => setLocal(() => accepted = !accepted),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: accepted ? AppTheme.ocean.withValues(alpha: 0.06) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: accepted ? AppTheme.ocean : AppTheme.slateGrey.withValues(alpha: 0.3),
                      width: accepted ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Transform.scale(
                        scale: 1.3,
                        child: Checkbox(
                          value: accepted,
                          onChanged: (v) => setLocal(() => accepted = v ?? false),
                          activeColor: AppTheme.ocean,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'J\'accepte les conditions d\'utilisation et la politique de confidentialité',
                          style: GoogleFonts.dmSans(fontSize: 15, color: AppTheme.textColor(context), height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomButton: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: accepted ? _next : null,
              child: const Text('Créer mon compte'),
            ),
          ),
        );
      },
    );
  }

  ConfettiController? _confettiController;

  void _triggerConfetti() {
    _confettiController?.dispose();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController!.play();
  }

  Widget _buildWelcomeStep() {
    final name = _nameController.text.isNotEmpty ? _nameController.text : 'toi';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentStep == _totalSteps - 1 && _confettiController == null) {
        _triggerConfetti();
      }
    });

    return Stack(
      children: [
        // Background glow
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.3),
                radius: 0.8,
                colors: [
                  AppTheme.ocean.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Avatar with celebration ring
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.ocean.withValues(alpha: 0.2),
                      AppTheme.teal.withValues(alpha: 0.15),
                    ],
                  ),
                  border: Border.all(
                    color: AppTheme.ocean.withValues(alpha: 0.5),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.ocean.withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/welcome.png',
                    width: 124,
                    height: 124,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: GoogleFonts.nunito(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.ocean,
                        ),
                      ),
                    ),
                  ),
                ),
              )
                  .animate()
                  .scale(
                      begin: const Offset(0, 0),
                      end: const Offset(1, 1),
                      duration: 600.ms,
                      curve: Curves.elasticOut)
                  .then()
                  .shimmer(
                      duration: 1000.ms,
                      color: AppTheme.ocean.withValues(alpha: 0.25)),
              const SizedBox(height: 36),

              // Title
              Text(
                'Bienvenue $name!',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textColor(context),
                ),
              )
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(
                      begin: 0.3,
                      end: 0,
                      duration: 400.ms,
                      curve: Curves.easeOutCubic),
              const SizedBox(height: 14),

              // Subtitle with better contrast
              Text(
                'Ton profil est créé.\nIl est temps de trouver ton premier Run Date!',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textColor(context).withValues(alpha: 0.75),
                  height: 1.5,
                ),
              )
                  .animate(delay: 500.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, end: 0, duration: 400.ms),
              const SizedBox(height: 24),

              // Stats teaser
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _welcomeStat(Icons.directions_run_rounded, '3 run dates', 'cette semaine'),
                  Container(
                    width: 1,
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: AppTheme.slateGrey.withValues(alpha: 0.2),
                  ),
                  _welcomeStat(Icons.people_rounded, '120+', 'coureurs'),
                  Container(
                    width: 1,
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: AppTheme.slateGrey.withValues(alpha: 0.2),
                  ),
                  _welcomeStat(Icons.location_on_rounded, '6', 'quartiers'),
                ],
              )
                  .animate(delay: 700.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.15, end: 0, duration: 400.ms),

              const Spacer(flex: 3),

              // CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    demoMode.value = true;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.ocean,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    textStyle: GoogleFonts.nunito(
                        fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Trouver mon premier Run Date'),
                ),
              )
                  .animate(delay: 900.ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.3, end: 0, duration: 300.ms),
              const SizedBox(height: 8),
            ],
          ),
        ),

        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController ?? ConfettiController(),
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            numberOfParticles: 25,
            maxBlastForce: 20,
            minBlastForce: 8,
            emissionFrequency: 0.06,
            gravity: 0.15,
            colors: const [
              AppTheme.ocean,
              AppTheme.teal,
              AppTheme.warning,
              AppTheme.teal,
              Color(0xFF00BCD4),
              Color(0xFF5EEAD4),
            ],
          ),
        ),
      ],
    );
  }

  Widget _welcomeStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.ocean),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.textColor(context),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            color: AppTheme.secondaryText(context),
          ),
        ),
      ],
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.ocean.withValues(alpha: 0.08) : AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.ocean : AppTheme.slateGrey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppTheme.ocean : AppTheme.textColor(context),
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.ocean),
          ],
        ),
      ),
    );
  }
}

class _TermsLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TermsLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(Icons.description_outlined, size: 20, color: AppTheme.navyIcon(context)),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                color: AppTheme.navyIcon(context),
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
