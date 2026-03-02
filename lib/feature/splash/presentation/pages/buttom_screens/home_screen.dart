import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rojgar/core/api/api_client.dart';
import 'package:rojgar/core/api/api_endpoints.dart';
import 'package:rojgar/feature/auth/presentation/view_model/auth_view_model.dart';

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

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      jobTitle: json['jobTitle'] ?? '',
      companyName: json['companyName'] ?? '',
      location: json['location'] ?? '',
      jobType: json['jobType'] ?? '',
      experienceLevel: json['experienceLevel'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      minSalary: json['minSalary'] != null
          ? int.tryParse(json['minSalary'].toString())
          : null,
      maxSalary: json['maxSalary'] != null
          ? int.tryParse(json['maxSalary'].toString())
          : null,
      requirements: List<String>.from(json['requirements'] ?? []),
      benefits: List<String>.from(json['benefits'] ?? []),
      companyLogoUrl: json['companyLogoUrl'] != null
          ? (json['companyLogoUrl'].toString().startsWith('http')
              ? json['companyLogoUrl'].toString()
              : '${ApiEndpoints.mediaServerUrl}/${json['companyLogoUrl']}')
          : null,
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

  String _fmt(int v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return v.toString();
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<JobModel> _jobs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  Future<void> _fetchJobs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get(ApiEndpoints.jobs);
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final outerData = body["data"];
        List<dynamic> rawList = [];
        if (outerData is List) {
          rawList = outerData;
        } else if (outerData is Map) {
          rawList = (outerData["data"] as List?) ?? [];
        }
        setState(() {
          _jobs = rawList
              .whereType<Map<String, dynamic>>()
              .map(JobModel.fromJson)
              .toList();
        });
      }
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? e.response?.data['message']
          : 'Failed to load jobs';
      setState(() => _error = msg ?? 'Failed to load jobs');
    } catch (e) {
      setState(() => _error = 'Something went wrong');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final username = authState.authEntity?.username ?? 'there';
    final profilePic = authState.authEntity?.profilePicture;

    final remoteCount =
        _jobs.where((j) => j.location.toLowerCase().contains('remote')).length;
    final fullTimeCount =
        _jobs.where((j) => j.jobType.toLowerCase().contains('full')).length;
    final partTimeCount =
        _jobs.where((j) => j.jobType.toLowerCase().contains('part')).length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchJobs,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Greeting ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hello\n$username.',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: (profilePic != null &&
                              profilePic.isNotEmpty &&
                              profilePic.startsWith('http'))
                          ? NetworkImage(profilePic)
                          : null,
                      child: (profilePic == null ||
                              profilePic.isEmpty ||
                              !profilePic.startsWith('http'))
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Banner ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          '50% off\ntake any courses',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Join Now'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // ── Job Type Cards ──
                const Text(
                  'Find Your Job',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          _jobCard('Remote Job', '$remoteCount',
                              Colors.lightBlue.shade100,
                              Icons.work_outline),
                          _jobCard('Full Time', '$fullTimeCount',
                              Colors.purple.shade100,
                              Icons.access_time_outlined),
                          _jobCard('Part Time', '$partTimeCount',
                              Colors.orange.shade100,
                              Icons.access_time_filled),
                        ],
                      ),
                const SizedBox(height: 30),

                // ── Recent Jobs ──
                const Text(
                  'Recent Job List',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_error != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.grey),
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
                    ),
                  )
                else if (_jobs.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(Icons.work_off_outlined,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'No jobs posted yet.\nBe the first to post a job!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._jobs.take(5).map((job) => _recentJobItem(job)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _jobCard(
      String title, String count, Color color, IconData iconData) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(iconData, size: 30, color: Colors.black54),
          const SizedBox(height: 10),
          Text(
            count,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _recentJobItem(JobModel job) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.purple,
                    backgroundImage: (job.companyLogoUrl != null &&
                            job.companyLogoUrl!.isNotEmpty)
                        ? NetworkImage(job.companyLogoUrl!)
                        : null,
                    child: (job.companyLogoUrl == null ||
                            job.companyLogoUrl!.isEmpty)
                        ? const Icon(Icons.business, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.jobTitle,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '${job.companyName} · ${job.location}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
              const Icon(Icons.bookmark_border),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                job.salaryRange,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8)),
                child: Text(job.experienceLevel,
                    style: const TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8)),
                child: Text(job.jobType,
                    style: const TextStyle(fontSize: 12)),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Apply'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            job.postedAgo,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}