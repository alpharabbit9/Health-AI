import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key, this.recommendedSpecialty});
  final String? recommendedSpecialty;

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  Position? _position;
  bool _locating = false;
  String? _locError;
  late String _selectedSpecialty;
  double _maxDistance = 10.0;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _selectedSpecialty = widget.recommendedSpecialty ?? 'All';
    _getLocation();
  }

  // StatefulShellRoute keeps this widget alive across navigations.
  // When the user arrives from an AI result with a new specialty,
  // GoRouter updates the widget's props but does NOT call initState again.
  // didUpdateWidget fires instead — pick up the new specialty here.
  @override
  void didUpdateWidget(DoctorsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.recommendedSpecialty != oldWidget.recommendedSpecialty) {
      setState(() {
        _selectedSpecialty = widget.recommendedSpecialty ?? 'All';
      });
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    setState(() {
      _locating = true;
      _locError = null;
    });
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        setState(() {
          _locError = 'Location permission denied. Enable it in settings.';
          _locating = false;
        });
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      setState(() {
        _position = pos;
        _locating = false;
      });
    } catch (e) {
      setState(() {
        _locError = 'Could not get location.';
        _locating = false;
      });
    }
  }

  List<_Doctor> get _filtered {
    return _mockDoctors.where((d) {
      final specialtyOk =
          _selectedSpecialty == 'All' || d.specialty == _selectedSpecialty;
      final distOk = d.distanceKm <= _maxDistance;
      return specialtyOk && distOk;
    }).toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
  }

  void _openMaps(String query) async {
    final lat = _position?.latitude;
    final lng = _position?.longitude;
    final Uri uri;
    if (lat != null && lng != null) {
      uri =
          Uri.parse('https://www.google.com/maps/search/$query/@$lat,$lng,14z');
    } else {
      uri = Uri.parse('https://www.google.com/maps/search/$query');
    }
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(24, top + 20, 20, 0),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              border: Border(bottom: BorderSide(color: context.dividerColor)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Find Doctors',
                              style: AppTextStyles.headlineLarge(dark: isDark)),
                          const SizedBox(height: 2),
                          _locating
                              ? Row(children: [
                                  const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          color: AppColors.primary)),
                                  const SizedBox(width: 6),
                                  Text('Getting location…',
                                      style: AppTextStyles.bodySmall(
                                          dark: isDark)),
                                ])
                              : Text(
                                  _position != null
                                      ? 'Near your location'
                                      : _locError ?? 'Location unavailable',
                                  style: AppTextStyles.bodySmall(dark: isDark),
                                ),
                        ],
                      ),
                    ),
                    // Filter button
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.tune_rounded,
                            size: 18, color: AppColors.primary),
                      ),
                      onPressed: () => _showFilters(context, isDark),
                    ),
                    // Maps button
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.map_outlined,
                            size: 18, color: AppColors.primary),
                      ),
                      onPressed: () => _openMaps('hospitals+clinics+doctors'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TabBar(
                  controller: _tabCtrl,
                  tabs: const [
                    Tab(text: 'Nearby'),
                    Tab(text: 'Map View'),
                  ],
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondaryLight,
                  indicatorColor: AppColors.primary,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                ),
              ],
            ),
          ),

          // ── Recommendation banner ────────────────────────
          if (widget.recommendedSpecialty != null &&
              widget.recommendedSpecialty != 'All')
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Showing ${widget.recommendedSpecialty} specialists '
                      'recommended for your condition',
                      style:
                          AppTextStyles.bodySmall(color: AppColors.primaryDark),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _selectedSpecialty = 'All'),
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: AppColors.primary),
                  ),
                ],
              ),
            ),

          // ── Content ─────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                // List view
                _filtered.isEmpty
                    ? _EmptyState(isDark: isDark)
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(20, 16, 20,
                            80 + MediaQuery.of(context).padding.bottom),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) => _DoctorCard(
                          doctor: _filtered[i],
                          isDark: isDark,
                          onCall: () => _openMaps(_filtered[i].name),
                          onDirections: () => _openMaps(
                              '${_filtered[i].name} ${_filtered[i].clinic}'),
                        ),
                      ),

                // Map placeholder — deep links to Google Maps
                _MapView(
                  position: _position,
                  isDark: isDark,
                  onOpen: () => _openMaps('hospitals+clinics+doctors+near+me'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilters(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Filters', style: AppTextStyles.headlineSmall(dark: isDark)),
              const SizedBox(height: 20),
              Text('Specialty', style: AppTextStyles.labelMedium(dark: isDark)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _specialties
                    .map(
                      (s) => FilterChip(
                        label: Text(s),
                        selected: _selectedSpecialty == s,
                        onSelected: (_) {
                          setLocal(() => _selectedSpecialty = s);
                          setState(() => _selectedSpecialty = s);
                        },
                        selectedColor: AppColors.primaryLight,
                        checkmarkColor: AppColors.primary,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Max Distance',
                      style: AppTextStyles.labelMedium(dark: isDark)),
                  Text('${_maxDistance.toStringAsFixed(0)} km',
                      style:
                          AppTextStyles.labelMedium(color: AppColors.primary)),
                ],
              ),
              Slider(
                value: _maxDistance,
                min: 1,
                max: 50,
                divisions: 49,
                activeColor: AppColors.primary,
                onChanged: (v) {
                  setLocal(() => _maxDistance = v);
                  setState(() => _maxDistance = v);
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Map view placeholder ─────────────────────────────────────

class _MapView extends StatelessWidget {
  const _MapView({
    required this.position,
    required this.isDark,
    required this.onOpen,
  });
  final Position? position;
  final bool isDark;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.map_rounded,
                size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text('Open in Google Maps',
              style: AppTextStyles.headlineSmall(dark: isDark)),
          const SizedBox(height: 8),
          Text(
            position != null
                ? 'Lat: ${position!.latitude.toStringAsFixed(4)}, '
                    'Lng: ${position!.longitude.toStringAsFixed(4)}'
                : 'Location not available',
            style: AppTextStyles.bodySmall(dark: isDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: const Text('Find Nearby Doctors'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Opens Google Maps to find hospitals,\nclinics, and doctors near you.',
            style: AppTextStyles.bodySmall(dark: isDark),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Doctor card ──────────────────────────────────────────────

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({
    required this.doctor,
    required this.isDark,
    required this.onCall,
    required this.onDirections,
  });
  final _Doctor doctor;
  final bool isDark;
  final VoidCallback onCall;
  final VoidCallback onDirections;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    doctor.name.split(' ').last[0],
                    style: AppTextStyles.headlineMedium(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.name,
                        style: AppTextStyles.titleSmall(dark: isDark)),
                    Text(doctor.specialty,
                        style:
                            AppTextStyles.bodySmall(color: AppColors.primary)),
                    Text(doctor.clinic,
                        style: AppTextStyles.bodySmall(dark: isDark)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 14, color: AppColors.warning),
                      const SizedBox(width: 2),
                      Text(
                        doctor.rating.toStringAsFixed(1),
                        style: AppTextStyles.labelSmall(dark: isDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${doctor.distanceKm.toStringAsFixed(1)} km',
                    style: AppTextStyles.labelSmall(color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Availability badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: doctor.available
                      ? AppColors.successLight
                      : AppColors.warningLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  doctor.available
                      ? 'Available Today'
                      : 'Next: ${doctor.nextSlot}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: doctor.available
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: onDirections,
                icon: const Icon(Icons.directions_rounded, size: 14),
                label: const Text('Directions'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: onCall,
                icon: const Icon(Icons.search_rounded, size: 14),
                label: const Text('Find'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_search_outlined,
                size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text('No doctors found',
              style: AppTextStyles.headlineSmall(dark: isDark)),
          const SizedBox(height: 8),
          Text('Try adjusting your filters',
              style: AppTextStyles.bodyMedium(dark: isDark)),
        ],
      ),
    );
  }
}

// ─── Data models & mock data ──────────────────────────────────

class _Doctor {
  const _Doctor({
    required this.name,
    required this.specialty,
    required this.clinic,
    required this.rating,
    required this.distanceKm,
    required this.available,
    this.nextSlot = 'Tomorrow',
  });

  final String name;
  final String specialty;
  final String clinic;
  final double rating;
  final double distanceKm;
  final bool available;
  final String nextSlot;
}

const _specialties = [
  'All',
  'General Medicine',
  'Cardiology',
  'Dermatology',
  'ENT',
  'Gastroenterology',
  'Neurology',
  'Paediatrics',
  'Orthopaedics',
  'Gynecology',
  'Psychiatry',
  'Ophthalmology',
  'Urology',
  'Nephrology',
  'Pulmonology',
  'Endocrinology',
  'Oncology',
  'Rheumatology',
  'Dental Surgery',
  'General Surgery',
  'Hepatology',
  'Allergy & Immunology',
  'Physical Medicine',
  'Nutrition & Dietetics',
  'Emergency Medicine',
];

const _mockDoctors = [
  _Doctor(
    name: 'Prof. Dr. Md. Shahadat Hossain',
    specialty: 'General Medicine',
    clinic: 'Mount Adora Hospital, Sylhet',
    rating: 4.8,
    distanceKm: 0.8,
    available: true,
  ),
  _Doctor(
    name: 'Dr. Syed Mahbubur Rahman',
    specialty: 'Cardiology',
    clinic: 'Ibn Sina Hospital, Sylhet',
    rating: 4.9,
    distanceKm: 1.5,
    available: true,
  ),
  _Doctor(
    name: 'Dr. Nusrat Jahan Chowdhury',
    specialty: 'Dermatology',
    clinic: 'Popular Diagnostic Centre, Sylhet',
    rating: 4.7,
    distanceKm: 2.1,
    available: false,
    nextSlot: 'Mon 10:00 AM',
  ),
  _Doctor(
    name: 'Dr. Md. Anwar Hossain',
    specialty: 'ENT',
    clinic: 'North East Medical College Hospital',
    rating: 4.6,
    distanceKm: 3.0,
    available: true,
  ),
  _Doctor(
    name: 'Dr. Farzana Yasmin',
    specialty: 'Gastroenterology',
    clinic: 'Osmani Medical College Hospital',
    rating: 4.7,
    distanceKm: 3.8,
    available: false,
    nextSlot: 'Tue 02:30 PM',
  ),
  _Doctor(
    name: 'Prof. Dr. Mohammad Abdul Hye',
    specialty: 'Neurology',
    clinic: 'Mount Adora Hospital',
    rating: 4.9,
    distanceKm: 4.5,
    available: true,
  ),
  _Doctor(
    name: 'Dr. Sharmeen Akter',
    specialty: 'Paediatrics',
    clinic: 'Women & Children Hospital',
    rating: 4.8,
    distanceKm: 5.2,
    available: true,
  ),
  _Doctor(
    name: 'Dr. Kamrul Islam',
    specialty: 'Orthopaedics',
    clinic: 'Al Haramain Hospital',
    rating: 4.6,
    distanceKm: 6.0,
    available: false,
    nextSlot: 'Wed 09:00 AM',
  ),
  _Doctor(
    name: 'Dr. Samina Begum',
    specialty: 'Gynecology',
    clinic: 'Jalalabad Ragib-Rabeya Medical College',
    rating: 4.9,
    distanceKm: 2.3,
    available: true,
  ),
  _Doctor(
    name: 'Dr. Mahfuzur Rahman',
    specialty: 'Psychiatry',
    clinic: 'Sylhet Mental Health Centre',
    rating: 4.7,
    distanceKm: 4.1,
    available: true,
  ),
  _Doctor(
    name: 'Dr. Arif Ahmed',
    specialty: 'Ophthalmology',
    clinic: 'Sylhet Eye Hospital',
    rating: 4.8,
    distanceKm: 2.9,
    available: true,
  ),
  _Doctor(
    name: 'Dr. Tanjina Sultana',
    specialty: 'Urology',
    clinic: 'Ibn Sina Hospital',
    rating: 4.7,
    distanceKm: 3.6,
    available: false,
    nextSlot: 'Thu 11:30 AM',
  ),
  _Doctor(
    name: 'Dr. Faisal Karim',
    specialty: 'Nephrology',
    clinic: 'Mount Adora Hospital',
    rating: 4.8,
    distanceKm: 3.4,
    available: true,
  ),
  _Doctor(
    name: 'Dr. Rakib Chowdhury',
    specialty: 'Pulmonology',
    clinic: 'North East Medical College Hospital',
    rating: 4.7,
    distanceKm: 5.0,
    available: true,
  ),
  _Doctor(
    name: 'Dr. Nasrin Akter',
    specialty: 'Endocrinology',
    clinic: 'Popular Diagnostic Centre',
    rating: 4.8,
    distanceKm: 4.2,
    available: false,
    nextSlot: 'Fri 03:00 PM',
  ),
  _Doctor(
    name: 'Prof. Dr. Abdul Momin',
    specialty: 'Oncology',
    clinic: 'Osmani Medical College Hospital',
    rating: 4.9,
    distanceKm: 5.8,
    available: true,
  ),
  _Doctor(
    name: 'Dr. Hasan Mahmud',
    specialty: 'Rheumatology',
    clinic: 'Al Haramain Hospital',
    rating: 4.6,
    distanceKm: 4.9,
    available: true,
  ),
  _Doctor(
    name: 'Dr. Sabiha Rahman',
    specialty: 'Dental Surgery',
    clinic: 'Sylhet Dental Care',
    rating: 4.8,
    distanceKm: 1.7,
    available: true,
  ),
  _Doctor(
    name: 'Dr. Imran Hossain',
    specialty: 'General Surgery',
    clinic: 'Mount Adora Hospital',
    rating: 4.8,
    distanceKm: 3.3,
    available: false,
    nextSlot: 'Sat 10:00 AM',
  ),
  _Doctor(
    name: 'Dr. Sharif Uddin',
    specialty: 'Hepatology',
    clinic: 'Ibn Sina Hospital',
    rating: 4.7,
    distanceKm: 4.7,
    available: true,
  ),
  _Doctor(
    name: 'Dr. Nabila Chowdhury',
    specialty: 'Allergy & Immunology',
    clinic: 'Popular Diagnostic Centre',
    rating: 4.8,
    distanceKm: 2.5,
    available: true,
  ),
  _Doctor(
    name: 'Dr. Riad Ahmed',
    specialty: 'Physical Medicine',
    clinic: 'North East Medical College Hospital',
    rating: 4.7,
    distanceKm: 5.5,
    available: false,
    nextSlot: 'Sun 09:30 AM',
  ),
  _Doctor(
    name: 'Dr. Tamanna Islam',
    specialty: 'Nutrition & Dietetics',
    clinic: 'Health Plus Centre',
    rating: 4.9,
    distanceKm: 1.9,
    available: true,
  ),
  _Doctor(
    name: 'Dr. Ashiqur Rahman',
    specialty: 'Emergency Medicine',
    clinic: 'Osmani Medical College Hospital',
    rating: 4.8,
    distanceKm: 2.8,
    available: true,
  ),
  _Doctor(
    name: 'Dr. Mehedi Hasan',
    specialty: 'Cardiology',
    clinic: 'Mount Adora Hospital',
    rating: 4.8,
    distanceKm: 6.3,
    available: true,
  ),
];
