import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rundate/data/mock_users.dart';
import 'package:rundate/data/quebec_cities.dart';
import 'package:rundate/screens/profile/bio_quiz_screen.dart';
import 'package:rundate/theme/app_theme.dart';
import 'package:rundate/widgets/demo_banner.dart';
import 'package:rundate/widgets/user_photo_viewer.dart';

enum ProfileVisibility { public, internal, private_ }

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // ── Profile fields ──
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _cityController;
  String? _selectedNeighborhood;
  String? _gender;
  String? _orientation;
  Set<String> _intentions = {};
  String? _photoUrl;
  late List<String> _galleryUrls;
  final Map<String, String> _photoCaptions = {};

  // ── Account fields ──
  ProfileVisibility _visibility = ProfileVisibility.internal;
  bool _allowSocialMediaFeature = false;
  int _birthYear = DateTime.now().year - 34;
  int? _birthMonth;
  int? _birthDay;
  final _emailController = TextEditingController();
  bool _emailSaved = false;

  final Map<String, bool> _notifSettings = {
    'new_event': true,
    'match_request': true,
    'messaging': true,
    'event_change': true,
    'group_ready': true,
    'spot_freed': true,
    'run_reminder': true,
    'new_members': true,
  };

  int get _calculatedAge {
    final now = DateTime.now();
    int age = now.year - _birthYear;
    if (_birthMonth != null && _birthDay != null) {
      final bday = DateTime(_birthYear, _birthMonth!, _birthDay!);
      if (now.isBefore(DateTime(now.year, bday.month, bday.day))) age--;
    }
    return age;
  }

  static const _allIntentions = [
    'Faire de nouveaux amis',
    'Me remettre en forme',
    'Performer',
    'Découvrir des quartiers',
    'Rencontrer quelqu\'un',
  ];

  @override
  void initState() {
    super.initState();
    final u = currentUser;
    _nameController = TextEditingController(text: u.firstName);
    _bioController = TextEditingController(text: u.bio ?? '');
    _cityController = TextEditingController(text: u.city);
    _selectedNeighborhood = u.neighborhood;
    _gender = u.gender;
    _orientation = u.sexualOrientation;
    _intentions = u.activityGoals.toSet();
    _photoUrl = u.photoUrl;
    _galleryUrls = List.of(u.photoGallery);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _openBioQuiz() async {
    final bio = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => BioQuizScreen(userName: _nameController.text.trim()),
      ),
    );
    if (bio != null && bio.isNotEmpty && mounted) {
      setState(() => _bioController.text = bio);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Mon profil',
            style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor(context))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ════════════════════════════════════════════
            // SECTION: Profil
            // ════════════════════════════════════════════
            _SectionHeader(title: 'Profil', icon: Icons.person_outline),
            const SizedBox(height: 16),
            _buildPhotoGrid(),
            const SizedBox(height: 24),
            _buildField('Prénom', _nameController),
            const SizedBox(height: 20),
            _buildGenderSelector(),
            const SizedBox(height: 20),
            _buildOrientationSelector(),
            const SizedBox(height: 20),
            _buildCityAutocomplete(),
            if (_cityController.text == 'Montréal') ...[
              const SizedBox(height: 16),
              _buildNeighborhoodSelector(),
            ],
            const SizedBox(height: 20),
            _buildIntentionsSelector(),
            const SizedBox(height: 20),
            _buildBioSection(),

            const SizedBox(height: 36),

            // ════════════════════════════════════════════
            // SECTION: Compte
            // ════════════════════════════════════════════
            _SectionHeader(title: 'Compte', icon: Icons.manage_accounts_outlined),
            const SizedBox(height: 16),
            _buildBirthdayCard(),
            const SizedBox(height: 20),
            _buildEmailCard(),
            const SizedBox(height: 20),
            _buildVisibilityCard(),
            const SizedBox(height: 16),
            _buildSocialMediaOptIn(),

            const SizedBox(height: 36),

            // ════════════════════════════════════════════
            // SECTION: Notifications
            // ════════════════════════════════════════════
            _SectionHeader(title: 'Notifications', icon: Icons.notifications_outlined),
            const SizedBox(height: 16),
            _buildNotificationSettings(),

            const SizedBox(height: 36),

            // Save button
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Profil sauvegardé',
                        style: GoogleFonts.dmSans()),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.ocean,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                textStyle: GoogleFonts.nunito(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
              child: const Text('Sauvegarder'),
            ),

            const SizedBox(height: 36),

            // ════════════════════════════════════════════
            // SECTION: Zone dangereuse
            // ════════════════════════════════════════════
            _buildDangerZone(),
          ],
        ),
      ),
    );
  }

  // ── Profile section builders ──────────────────────────────────────────────

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Genre',
            style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor(context))),
        const SizedBox(height: 8),
        Row(
          children: ['Homme', 'Femme', 'Non-binaire'].map((g) {
            final selected = _gender == g;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(g,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : AppTheme.textColor(context),
                    )),
                selected: selected,
                onSelected: (_) => setState(() => _gender = g),
                selectedColor: AppTheme.ocean,
                backgroundColor: AppTheme.slateGrey.withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: selected
                        ? AppTheme.ocean
                        : AppTheme.slateGrey.withValues(alpha: 0.25),
                  ),
                ),
                showCheckmark: false,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOrientationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Orientation',
            style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor(context))),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Hétérosexuel(le)',
            'Homosexuel(le)',
            'Bisexuel(le)',
            'Pansexuel(le)',
            'Autre',
            'Préfère ne pas dire',
          ].map((o) {
            final selected = _orientation == o;
            return ChoiceChip(
              label: Text(o,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? Colors.white
                        : AppTheme.textColor(context),
                  )),
              selected: selected,
              onSelected: (_) => setState(() => _orientation = o),
              selectedColor: AppTheme.ocean,
              backgroundColor: AppTheme.slateGrey.withValues(alpha: 0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: selected
                      ? AppTheme.ocean
                      : AppTheme.slateGrey.withValues(alpha: 0.25),
                ),
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIntentionsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Intentions',
            style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor(context))),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allIntentions.map((intention) {
            final selected = _intentions.contains(intention);
            return FilterChip(
              label: Text(intention,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? Colors.white
                        : AppTheme.textColor(context),
                  )),
              selected: selected,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _intentions.add(intention);
                  } else {
                    _intentions.remove(intention);
                  }
                });
              },
              selectedColor: AppTheme.ocean,
              backgroundColor: AppTheme.slateGrey.withValues(alpha: 0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: selected
                      ? AppTheme.ocean
                      : AppTheme.slateGrey.withValues(alpha: 0.25),
                ),
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Bio',
                style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textColor(context))),
            const Spacer(),
            TextButton.icon(
              onPressed: _openBioQuiz,
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: Text('Régénérer',
                  style: GoogleFonts.dmSans(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.teal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _bioController,
          maxLines: 4,
          maxLength: 500,
          style: GoogleFonts.dmSans(fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Parle de toi...',
            hintStyle: GoogleFonts.dmSans(color: AppTheme.slateGrey),
            filled: true,
            fillColor: AppTheme.cardColor(context),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: AppTheme.slateGrey.withValues(alpha: 0.25)),
            ),
          ),
        ),
      ],
    );
  }

  // ── Account section builders ──────────────────────────────────────────────

  Widget _buildBirthdayCard() {
    final hasFullDate = _birthMonth != null && _birthDay != null;
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
    ];
    final dateText = hasFullDate
        ? '$_birthDay ${months[_birthMonth! - 1]} $_birthYear'
        : 'Année $_birthYear';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cake_outlined, size: 20, color: AppTheme.ocean),
              const SizedBox(width: 8),
              Text('Date de naissance',
                  style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textColor(context))),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _showBirthdayPicker,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.ocean.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.ocean.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dateText,
                            style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textColor(context))),
                        const SizedBox(height: 2),
                        Text('$_calculatedAge ans',
                            style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.ocean)),
                      ],
                    ),
                  ),
                  Icon(Icons.edit_outlined,
                      size: 20, color: AppTheme.secondaryText(context)),
                ],
              ),
            ),
          ),
          if (!hasFullDate) ...[
            const SizedBox(height: 10),
            Text(
              'Ajoute le mois et le jour pour que la communauté te souhaite bonne fête!',
              style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppTheme.secondaryText(context),
                  fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmailCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.email_outlined, size: 20, color: AppTheme.navyIcon(context)),
              const SizedBox(width: 8),
              Text('Courriel',
                  style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textColor(context))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.slateGrey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Facultatif',
                    style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryText(context))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Ajoute ton courriel pour recevoir des rappels et récupérer ton compte.',
            style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppTheme.secondaryText(context),
                height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.dmSans(
                      fontSize: 15, color: AppTheme.textColor(context)),
                  decoration: InputDecoration(
                    hintText: 'ton.courriel@exemple.com',
                    hintStyle: GoogleFonts.dmSans(
                        color: AppTheme.slateGrey.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: AppTheme.slateGrey.withValues(alpha: 0.06),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: AppTheme.slateGrey.withValues(alpha: 0.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: AppTheme.slateGrey.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.teal, width: 2),
                    ),
                    isDense: true,
                    suffixIcon: _emailSaved
                        ? const Icon(Icons.check_circle,
                            color: AppTheme.teal, size: 20)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    final email = _emailController.text.trim();
                    if (email.isNotEmpty && email.contains('@')) {
                      FocusScope.of(context).unfocus();
                      setState(() => _emailSaved = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Courriel enregistré!',
                              style: GoogleFonts.dmSans()),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text('Sauver',
                      style: GoogleFonts.dmSans(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityCard() {
    const options = [
      (ProfileVisibility.public, '🌐', 'Public',
          'Visible sur le site web, tout le monde peut consulter ton profil.'),
      (ProfileVisibility.internal, '👥', 'Interne',
          'Seulement les membres de la communauté Run Date peuvent te voir.'),
      (ProfileVisibility.private_, '🔒', 'Privé',
          'Seuls les membres de tes événements peuvent voir ton profil.'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility_outlined,
                  size: 20, color: AppTheme.navyIcon(context)),
              const SizedBox(width: 8),
              Text('Visibilité du profil',
                  style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textColor(context))),
            ],
          ),
          const SizedBox(height: 14),
          ...options.map((opt) {
            final selected = _visibility == opt.$1;
            return GestureDetector(
              onTap: () => setState(() => _visibility = opt.$1),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.teal.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? AppTheme.teal.withValues(alpha: 0.5)
                        : AppTheme.slateGrey.withValues(alpha: 0.15),
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(opt.$2, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(opt.$3,
                              style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? AppTheme.teal
                                      : AppTheme.textColor(context))),
                          const SizedBox(height: 2),
                          Text(opt.$4,
                              style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: AppTheme.secondaryText(context),
                                  height: 1.3)),
                        ],
                      ),
                    ),
                    if (selected)
                      Icon(Icons.check_circle, size: 22, color: AppTheme.teal),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSocialMediaOptIn() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.campaign_outlined,
                  size: 20, color: AppTheme.navyIcon(context)),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Profil mis de l\'avant',
                    style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textColor(context))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'En activant cette option, tu acceptes que ton profil (photo, prénom et bio) puisse être sélectionné pour apparaître sur les réseaux sociaux de Run Date afin d\'inspirer de nouveaux membres à rejoindre la communauté.',
            style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppTheme.secondaryText(context),
                height: 1.45),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _allowSocialMediaFeature
                  ? AppTheme.teal.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _allowSocialMediaFeature
                    ? AppTheme.teal.withValues(alpha: 0.4)
                    : AppTheme.slateGrey.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _allowSocialMediaFeature
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 22,
                  color: _allowSocialMediaFeature
                      ? AppTheme.teal
                      : AppTheme.secondaryText(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('J\'accepte de figurer comme profil vedette',
                      style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _allowSocialMediaFeature
                              ? AppTheme.teal
                              : AppTheme.textColor(context))),
                ),
                Switch.adaptive(
                  value: _allowSocialMediaFeature,
                  onChanged: (v) =>
                      setState(() => _allowSocialMediaFeature = v),
                  activeTrackColor: AppTheme.teal,
                ),
              ],
            ),
          ),
          if (_allowSocialMediaFeature) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.teal.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppTheme.teal),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Merci! Tu pourrais être sélectionné(e) pour inspirer d\'autres membres sur nos réseaux. Tu peux désactiver à tout moment.',
                      style: GoogleFonts.dmSans(
                          fontSize: 14, color: AppTheme.teal, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    const notifItems = [
      ('new_event', Icons.location_on_outlined, 'Nouvel événement',
          'Une activité est créée près de chez toi'),
      ('match_request', Icons.favorite_outline, 'Demande de connexion',
          'Quelqu\'un veut te connaître!'),
      ('messaging', Icons.chat_bubble_outline, 'Messagerie',
          'Nouveau message de groupe ou privé'),
      ('event_change', Icons.edit_calendar_outlined, 'Changement d\'événement',
          'Modification d\'horaire, lieu ou annulation'),
      ('group_ready', Icons.groups_outlined, 'Formation de groupe',
          'Ton groupe est prêt!'),
      ('spot_freed', Icons.event_available_outlined, 'Place libérée',
          'Une place s\'est libérée dans un événement'),
      ('run_reminder', Icons.alarm_outlined, 'Rappel avant l\'activité',
          'Quelques heures avant ton activité'),
      ('new_members', Icons.person_add_outlined, 'Nouveaux membres',
          'Quelqu\'un rejoint ton groupe'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: notifItems.map((item) {
          return SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            activeTrackColor: AppTheme.teal.withValues(alpha: 0.4),
            thumbColor: WidgetStatePropertyAll(AppTheme.teal),
            secondary: Icon(item.$2,
                size: 20, color: AppTheme.secondaryText(context)),
            title: Text(item.$3,
                style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textColor(context))),
            subtitle: Text(item.$4,
                style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppTheme.secondaryText(context))),
            value: _notifSettings[item.$1] ?? true,
            onChanged: (v) => setState(() => _notifSettings[item.$1] = v),
          );
        }).toList(),
      ),
    );
  }

  // ── Danger zone ───────────────────────────────────────────────────────────

  Widget _buildDangerZone() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Text('Zone dangereuse',
                style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.error)),
          ),
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            leading: const Icon(Icons.pause_circle_outline,
                color: AppTheme.warning, size: 24),
            title: Text('Suspendre mon compte',
                style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textColor(context))),
            trailing: Icon(Icons.chevron_right_rounded,
                color: AppTheme.slateGrey.withValues(alpha: 0.6)),
            onTap: _showSuspendDialog,
          ),
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            leading: const Icon(Icons.delete_outline,
                color: AppTheme.error, size: 24),
            title: Text('Supprimer mon compte',
                style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textColor(context))),
            trailing: Icon(Icons.chevron_right_rounded,
                color: AppTheme.slateGrey.withValues(alpha: 0.6)),
            onTap: _showDeleteDialog,
          ),
        ],
      ),
    );
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────

  void _showSuspendDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Suspendre ton compte?',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        content: Text(
          'Ton profil sera masqué et tu ne recevras plus d\'invitations. '
          'Tu pourras réactiver ton compte à tout moment.',
          style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppTheme.secondaryText(context),
              height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Annuler',
                style: GoogleFonts.dmSans(
                    color: AppTheme.secondaryText(context))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Compte suspendu', style: GoogleFonts.dmSans()),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warning,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Suspendre'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    final reasonController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Supprimer ton compte?',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cette action est irréversible. Toutes tes données seront supprimées.',
              style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppTheme.secondaryText(context),
                  height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 2,
              style: GoogleFonts.dmSans(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Raison (optionnel)',
                hintStyle: GoogleFonts.dmSans(
                    color: AppTheme.secondaryText(context)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Annuler',
                style: GoogleFonts.dmSans(
                    color: AppTheme.secondaryText(context))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              demoMode.value = false;
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showBirthdayPicker() {
    final now = DateTime.now();
    int tmpYear = _birthYear;
    int tmpMonth = _birthMonth ?? 6;
    int tmpDay = _birthDay ?? 15;
    final maxYear = now.year - 18;
    final minYear = now.year - 80;
    final months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            int daysInMonth(int y, int m) => DateUtils.getDaysInMonth(y, m);
            final maxDay = daysInMonth(tmpYear, tmpMonth);
            if (tmpDay > maxDay) tmpDay = maxDay;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.slateGrey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Date de naissance',
                        style: GoogleFonts.nunito(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textColor(ctx))),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 180,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 44, perspective: 0.003,
                              diameterRatio: 1.5,
                              physics: const FixedExtentScrollPhysics(),
                              controller: FixedExtentScrollController(initialItem: tmpDay - 1),
                              onSelectedItemChanged: (i) => setLocal(() => tmpDay = i + 1),
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: maxDay,
                                builder: (_, i) {
                                  final d = i + 1;
                                  final sel = d == tmpDay;
                                  return Center(child: Text('$d',
                                      style: GoogleFonts.nunito(
                                          fontSize: sel ? 22 : 17,
                                          fontWeight: sel ? FontWeight.w800 : FontWeight.w400,
                                          color: sel ? AppTheme.ocean : AppTheme.secondaryText(context))));
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 44, perspective: 0.003,
                              diameterRatio: 1.5,
                              physics: const FixedExtentScrollPhysics(),
                              controller: FixedExtentScrollController(initialItem: tmpMonth - 1),
                              onSelectedItemChanged: (i) => setLocal(() => tmpMonth = i + 1),
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: 12,
                                builder: (_, i) {
                                  final sel = (i + 1) == tmpMonth;
                                  return Center(child: Text(months[i],
                                      style: GoogleFonts.nunito(
                                          fontSize: sel ? 20 : 16,
                                          fontWeight: sel ? FontWeight.w800 : FontWeight.w400,
                                          color: sel ? AppTheme.ocean : AppTheme.secondaryText(context))));
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 44, perspective: 0.003,
                              diameterRatio: 1.5,
                              physics: const FixedExtentScrollPhysics(),
                              controller: FixedExtentScrollController(initialItem: maxYear - tmpYear),
                              onSelectedItemChanged: (i) => setLocal(() => tmpYear = maxYear - i),
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: maxYear - minYear + 1,
                                builder: (_, i) {
                                  final y = maxYear - i;
                                  final sel = y == tmpYear;
                                  return Center(child: Text('$y',
                                      style: GoogleFonts.nunito(
                                          fontSize: sel ? 22 : 17,
                                          fontWeight: sel ? FontWeight.w800 : FontWeight.w400,
                                          color: sel ? AppTheme.ocean : AppTheme.secondaryText(context))));
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _birthYear = tmpYear;
                            _birthMonth = tmpMonth;
                            _birthDay = tmpDay;
                          });
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('Confirmer'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Photo helpers (unchanged from original) ───────────────────────────────

  void _stubAddPhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ajout de photo — bientôt disponible',
            style: GoogleFonts.dmSans()),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildPhotoGrid() {
    final allUrls = <String?>[_photoUrl, ..._galleryUrls];
    const maxSlots = 6;
    final showAdd = allUrls.length < maxSlots;

    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var i = 0; i < allUrls.length; i++)
          _buildPhotoTile(allUrls[i], index: i, isMain: i == 0),
        if (showAdd) _buildAddTile(),
      ],
    );
  }

  Widget _buildPhotoTile(String? url,
      {required int index, bool isMain = false}) {
    final caption = url != null ? _photoCaptions[url] : null;
    return GestureDetector(
      onTap: () {
        if (url != null && url.isNotEmpty) {
          _showPhotoActionsSheet(url, index: index, isMain: isMain);
        } else {
          _stubAddPhoto();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.slateGrey.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: isMain
                  ? Border.all(color: AppTheme.ocean, width: 2.5)
                  : Border.all(
                      color: AppTheme.slateGrey.withValues(alpha: 0.2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isMain ? 11 : 13),
              child: url != null && url.isNotEmpty
                  ? Image.network(url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildLetterAvatar())
                  : _buildLetterAvatar(),
            ),
          ),
          if (isMain)
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.ocean,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Principal',
                    style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          if (caption != null && caption.isNotEmpty)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(6, 12, 6, 6),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(13)),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(caption,
                    style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ),
        ],
      ),
    );
  }

  void _showPhotoActionsSheet(String url,
      {required int index, required bool isMain}) {
    final captionController =
        TextEditingController(text: _photoCaptions[url] ?? '');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.slateGrey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(url,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                            height: 180,
                            color: AppTheme.slateGrey.withValues(alpha: 0.12),
                            child: const Center(
                                child: Icon(Icons.broken_image_outlined,
                                    size: 40, color: AppTheme.slateGrey)))),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: captionController,
                    style: GoogleFonts.dmSans(fontSize: 14),
                    maxLength: 80,
                    decoration: InputDecoration(
                      hintText: 'Ajoute une description...',
                      hintStyle: GoogleFonts.dmSans(
                          color: AppTheme.slateGrey, fontSize: 14),
                      prefixIcon: const Icon(Icons.edit_outlined,
                          size: 18, color: AppTheme.slateGrey),
                      filled: true,
                      fillColor: AppTheme.cardColor(ctx),
                      counterStyle: GoogleFonts.dmSans(
                          fontSize: 11, color: AppTheme.slateGrey),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        if (val.trim().isEmpty) {
                          _photoCaptions.remove(url);
                        } else {
                          _photoCaptions[url] = val.trim();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  _photoActionTile(
                    icon: Icons.fullscreen_rounded,
                    label: 'Voir en grand',
                    onTap: () {
                      Navigator.of(ctx).pop();
                      final allUrls = [
                        ?_photoUrl,
                        ..._galleryUrls,
                      ];
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => UserPhotoViewer(
                            photoUrls: allUrls,
                            initialIndex: index,
                            userName: _nameController.text,
                          ),
                        ),
                      );
                    },
                  ),
                  if (!isMain)
                    _photoActionTile(
                      icon: Icons.star_outline_rounded,
                      label: 'Définir comme principale',
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _setAsMainPhoto(index);
                      },
                    ),
                  if (isMain ? _galleryUrls.isNotEmpty : true)
                    _photoActionTile(
                      icon: Icons.delete_outline_rounded,
                      label: 'Supprimer',
                      color: Colors.red,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _deletePhoto(index, isMain: isMain);
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _photoActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading:
          Icon(icon, size: 22, color: color ?? AppTheme.textColor(context)),
      title: Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: color ?? AppTheme.textColor(context))),
      onTap: onTap,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  void _setAsMainPhoto(int index) {
    setState(() {
      final galleryIndex = index - 1;
      if (galleryIndex >= 0 && galleryIndex < _galleryUrls.length) {
        final newMain = _galleryUrls[galleryIndex];
        if (_photoUrl != null) {
          _galleryUrls[galleryIndex] = _photoUrl!;
        } else {
          _galleryUrls.removeAt(galleryIndex);
        }
        _photoUrl = newMain;
      }
    });
    HapticFeedback.selectionClick();
  }

  void _deletePhoto(int index, {required bool isMain}) {
    setState(() {
      if (isMain) {
        _photoCaptions.remove(_photoUrl);
        if (_galleryUrls.isNotEmpty) {
          _photoUrl = _galleryUrls.removeAt(0);
        } else {
          _photoUrl = null;
        }
      } else {
        final galleryIndex = index - 1;
        if (galleryIndex >= 0 && galleryIndex < _galleryUrls.length) {
          _photoCaptions.remove(_galleryUrls[galleryIndex]);
          _galleryUrls.removeAt(galleryIndex);
        }
      }
    });
    HapticFeedback.mediumImpact();
  }

  Widget _buildAddTile() {
    return GestureDetector(
      onTap: _stubAddPhoto,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.slateGrey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppTheme.slateGrey.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded,
                size: 32,
                color: AppTheme.slateGrey.withValues(alpha: 0.5)),
            const SizedBox(height: 4),
            Text('Ajouter',
                style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.slateGrey.withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterAvatar() {
    return Center(
      child: Text(
        _nameController.text.isNotEmpty
            ? _nameController.text[0].toUpperCase()
            : '?',
        style: GoogleFonts.nunito(
            fontSize: 40, fontWeight: FontWeight.w800, color: AppTheme.ocean),
      ),
    );
  }

  Widget _buildCityAutocomplete() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ville',
            style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor(context))),
        const SizedBox(height: 8),
        Autocomplete<QuebecCity>(
          initialValue: TextEditingValue(text: _cityController.text),
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text.isEmpty) return const Iterable.empty();
            return searchCities(textEditingValue.text).take(8);
          },
          displayStringForOption: (city) => city.name,
          onSelected: (city) {
            HapticFeedback.selectionClick();
            setState(() {
              _cityController.text = city.name;
              if (city.name != 'Montréal') _selectedNeighborhood = null;
            });
          },
          fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              onEditingComplete: onSubmitted,
              style: GoogleFonts.dmSans(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Recherche ta ville...',
                hintStyle: GoogleFonts.dmSans(
                    color: AppTheme.slateGrey, fontSize: 15),
                prefixIcon: const Icon(Icons.location_on_outlined,
                    color: AppTheme.slateGrey, size: 20),
                filled: true,
                fillColor: AppTheme.cardColor(context),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                      color: AppTheme.slateGrey.withValues(alpha: 0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.ocean),
                ),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final city = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        leading: Icon(Icons.location_on_outlined,
                            size: 18, color: AppTheme.slateGrey),
                        title: Text(city.name,
                            style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                        subtitle: Text(city.region,
                            style: GoogleFonts.dmSans(
                                fontSize: 12, color: AppTheme.slateGrey)),
                        onTap: () => onSelected(city),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNeighborhoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quartier',
            style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor(context))),
        const SizedBox(height: 4),
        Text('Optionnel — aide à trouver des événements près de chez toi.',
            style: GoogleFonts.dmSans(
                fontSize: 12, color: AppTheme.slateGrey)),
        const SizedBox(height: 8),
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
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.ocean.withValues(alpha: 0.12)
                      : AppTheme.cardColor(context),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected
                        ? AppTheme.ocean
                        : AppTheme.slateGrey.withValues(alpha: 0.2),
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Text(n,
                    style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected
                            ? AppTheme.ocean
                            : AppTheme.textColor(context))),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor(context))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: GoogleFonts.dmSans(fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.cardColor(context),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: AppTheme.slateGrey.withValues(alpha: 0.25)),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppTheme.ocean),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.textColor(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1.5,
            color: AppTheme.slateGrey.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }
}
