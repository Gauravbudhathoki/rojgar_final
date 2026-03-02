import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rojgar/core/services/sensor/sensor_service.dart';
import 'package:rojgar/core/widgets/shake_refresh_banner.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rojgar/core/api/api_client.dart';
import 'package:rojgar/core/api/api_endpoints.dart';

// ─── Job Model ────────────────────────────────────────────────────────────────

class JobModel {
  final String id;
  final String jobTitle;
  final String companyName;
  final String location;
  final String jobType;
  final String experienceLevel;
  final String category;
  final String description;
  final int? minSalary;
  final int? maxSalary;
  final List<String> requirements;
  final List<String> benefits;
  final String? companyLogoUrl;
  final DateTime createdAt;

  JobModel({
    required this.id,
    required this.jobTitle,
    required this.companyName,
    required this.location,
    required this.jobType,
    required this.experienceLevel,
    required this.category,
    required this.description,
    this.minSalary,
    this.maxSalary,
    required this.requirements,
    required this.benefits,
    this.companyLogoUrl,
    required this.createdAt,
  });

  static String? _buildLogoUrl(dynamic raw) {
    if (raw == null) return null;
    final s = raw.toString();
    if (s.isEmpty) return null;
    if (s.startsWith('http')) return s;
    return '${ApiEndpoints.mediaServerUrl}/$s';
  }

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      jobTitle: (json['jobTitle'] ?? '').toString(),
      companyName: (json['companyName'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      jobType: (json['jobType'] ?? '').toString(),
      experienceLevel: (json['experienceLevel'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      minSalary: json['minSalary'] != null
          ? int.tryParse(json['minSalary'].toString())
          : null,
      maxSalary: json['maxSalary'] != null
          ? int.tryParse(json['maxSalary'].toString())
          : null,
      requirements: (json['requirements'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      benefits: (json['benefits'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      companyLogoUrl: _buildLogoUrl(json['companyLogoUrl']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String get postedAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return '1 day ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 14) return '1 week ago';
    return '${(diff.inDays / 7).floor()} weeks ago';
  }

  String get salaryRange {
    if (minSalary != null && maxSalary != null) {
      return 'NPR ${_fmt(minSalary!)} - ${_fmt(maxSalary!)}';
    }
    if (minSalary != null) return 'NPR ${_fmt(minSalary!)}+';
    if (maxSalary != null) return 'Up to NPR ${_fmt(maxSalary!)}';
    return 'Negotiable';
  }

  String _fmt(int v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}k' : v.toString();
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final SensorService _sensorService = SensorService();

  List<JobModel> _allJobs = [];
  bool _isLoading = true;
  bool _isShakeRefreshing = false;
  String? _error;

  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedJobType = 'All';
  String _selectedExperience = 'All';
  final Set<String> _savedJobs = {};

  final List<String> _categories = [
    'All', 'Software Development', 'Design & Creative', 'Marketing',
    'Sales', 'Finance & Accounting', 'HR & Recruitment', 'Operations',
    'Customer Support', 'Data & Analytics', 'Other',
  ];

  final List<String> _jobTypes = [
    'All', 'Full-Time', 'Part-Time', 'Contract', 'Freelance', 'Internship',
  ];

  final List<String> _experienceLevels = [
    'All', 'Entry Level', 'Junior', 'Mid-Level', 'Senior',
    'Lead / Principal', 'Executive',
  ];

  @override
  void initState() {
    super.initState();
    _fetchJobs();
    _sensorService.onShake = _handleShake;
    _sensorService.start();
  }

  @override
  void dispose() {
    _sensorService.stop();
    _sensorService.onShake = null;
    _sensorService.onGyroUpdate = null;
    _searchCtrl.dispose();
    super.dispose();
  }

  void _handleShake() async {
    if (_isShakeRefreshing || _isLoading) return;
    setState(() => _isShakeRefreshing = true);
    await _fetchJobs();
    if (mounted) {
      setState(() => _isShakeRefreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.refresh, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Jobs refreshed!',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2563EB),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _fetchJobs() async {
    if (!_isShakeRefreshing) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get(ApiEndpoints.jobs);

      final body = response.data;
      debugPrint('RAW BODY TYPE: ${body.runtimeType}');

      List<dynamic> rawJobs = [];

      if (body is Map<String, dynamic>) {
        final level1 = body['data'];
        debugPrint('LEVEL1 TYPE: ${level1.runtimeType}');

        if (level1 is List) {
          rawJobs = level1;
        } else if (level1 is Map<String, dynamic>) {
          final level2 = level1['data'];
          debugPrint('LEVEL2 TYPE: ${level2.runtimeType}');
          if (level2 is List) {
            rawJobs = level2;
          }
        }
      }

      debugPrint('RAW JOBS COUNT: ${rawJobs.length}');

      final jobs = rawJobs
          .whereType<Map<String, dynamic>>()
          .map(JobModel.fromJson)
          .toList();

      debugPrint('PARSED JOBS COUNT: ${jobs.length}');
      if (jobs.isNotEmpty) {
        debugPrint(
            'FIRST JOB: ${jobs.first.jobTitle} | ${jobs.first.jobType} | ${jobs.first.category}');
      }

      if (mounted) setState(() => _allJobs = jobs);
    } on DioException catch (e) {
      debugPrint('DIO ERROR: ${e.message} | ${e.response?.data}');
      final msg = e.response?.data is Map
          ? e.response?.data['message']
          : 'Failed to load jobs';
      if (mounted) setState(() => _error = msg ?? 'Failed to load jobs');
    } catch (e, st) {
      debugPrint('FETCH ERROR: $e\n$st');
      if (mounted) setState(() => _error = 'Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<JobModel> get _filtered {
    if (_allJobs.isEmpty) return [];
    return _allJobs.where((job) {
      final matchCategory =
          _selectedCategory == 'All' || job.category == _selectedCategory;
      final matchType =
          _selectedJobType == 'All' || job.jobType == _selectedJobType;
      final matchExp = _selectedExperience == 'All' ||
          job.experienceLevel == _selectedExperience;
      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          job.jobTitle.toLowerCase().contains(q) ||
          job.companyName.toLowerCase().contains(q) ||
          job.location.toLowerCase().contains(q);
      return matchCategory && matchType && matchExp && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : RefreshIndicator(
                    onRefresh: _fetchJobs,
                    child: _buildContent(),
                  ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _fetchJobs,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final filtered = _filtered;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        ShakeRefreshBanner(isRefreshing: _isShakeRefreshing),
        const SizedBox(height: 16),
        _buildSearchBar(),
        const SizedBox(height: 20),
        _buildFilterRow('Category', _categories, _selectedCategory,
            (v) => setState(() => _selectedCategory = v)),
        const SizedBox(height: 16),
        _buildFilterRow('Job Type', _jobTypes, _selectedJobType,
            (v) => setState(() => _selectedJobType = v)),
        const SizedBox(height: 16),
        _buildFilterRow('Experience Level', _experienceLevels,
            _selectedExperience,
            (v) => setState(() => _selectedExperience = v)),
        const SizedBox(height: 24),
        Text(
          'Showing ${filtered.length} of ${_allJobs.length} job${filtered.length == 1 ? '' : 's'}',
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          const SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 48, color: Color(0xFFCBD5E1)),
                  SizedBox(height: 12),
                  Text(
                    'No jobs found',
                    style:
                        TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                  ),
                ],
              ),
            ),
          )
        else
          ...filtered.map((job) => _TiltJobCard(
                job: job,
                isSaved: _savedJobs.contains(job.id),
                onSaveToggle: () => setState(() {
                  _savedJobs.contains(job.id)
                      ? _savedJobs.remove(job.id)
                      : _savedJobs.add(job.id);
                }),
                sensorService: _sensorService,
              )),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: const InputDecoration(
          hintText: 'Search by job title, company, or location...',
          hintStyle: TextStyle(color: Color(0xFFADB5BD), fontSize: 14),
          prefixIcon:
              Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterRow(String label, List<String> options, String selected,
      ValueChanged<String> onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151))),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: options.map((opt) {
              final isSelected = selected == opt;
              return GestureDetector(
                onTap: () => onSelect(opt),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Text(opt,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF374151))),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─── Tilt Job Card (Gyroscope) ────────────────────────────────────────────────

class _TiltJobCard extends StatefulWidget {
  final JobModel job;
  final bool isSaved;
  final VoidCallback onSaveToggle;
  final SensorService sensorService;

  const _TiltJobCard({
    required this.job,
    required this.isSaved,
    required this.onSaveToggle,
    required this.sensorService,
  });

  @override
  State<_TiltJobCard> createState() => _TiltJobCardState();
}

class _TiltJobCardState extends State<_TiltJobCard> {
  double _tiltX = 0;
  double _tiltY = 0;

  @override
  void initState() {
    super.initState();
    widget.sensorService.onGyroUpdate = () {
      if (mounted) {
        setState(() {
          _tiltX =
              (widget.sensorService.gyroY * 0.3).clamp(-0.12, 0.12);
          _tiltY =
              (widget.sensorService.gyroX * 0.3).clamp(-0.12, 0.12);
        });
      }
    };
  }

  @override
  void dispose() {
    widget.sensorService.onGyroUpdate = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(_tiltX)
        ..rotateY(_tiltY),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                  0.03 + (_tiltX.abs() + _tiltY.abs()) * 0.15),
              blurRadius: 8 + (_tiltX.abs() + _tiltY.abs()) * 30,
              offset: Offset(_tiltY * 20, _tiltX * 20),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogo(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.job.jobTitle,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 2),
                      Text(widget.job.companyName,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('Apply',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: widget.onSaveToggle,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          widget.isSaved
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 20,
                          color: widget.isSaved
                              ? Colors.red
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Share.share(
                        'Check out: ${widget.job.jobTitle} at ${widget.job.companyName}',
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.share_outlined,
                            size: 20, color: Color(0xFF94A3B8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _meta(Icons.location_on_outlined, widget.job.location),
                _meta(Icons.attach_money, widget.job.salaryRange),
                _meta(Icons.access_time_outlined, widget.job.jobType),
                _meta(Icons.menu_book_outlined, widget.job.experienceLevel),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _chip(widget.job.category, const Color(0xFF2563EB),
                    const Color(0xFFEFF6FF)),
                const SizedBox(width: 8),
                _chip(widget.job.postedAgo, const Color(0xFF64748B),
                    const Color(0xFFF1F5F9)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: widget.job.companyLogoUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                widget.job.companyLogoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.business,
                  color: Color(0xFF2563EB),
                  size: 26,
                ),
              ),
            )
          : const Icon(Icons.business,
              color: Color(0xFF2563EB), size: 26),
    );
  }

  Widget _meta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 3),
        Text(text,
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _chip(String label, Color textColor, Color bgColor) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor)),
    );
  }
}