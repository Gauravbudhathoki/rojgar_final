import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rojgar/core/api/api_client.dart';
import 'package:rojgar/core/api/api_endpoints.dart';

const List<String> kLocations = [
  'Remote',
  'Kathmandu, Nepal',
  'Pokhara, Nepal',
  'Lalitpur, Nepal',
  'Bhaktapur, Nepal',
  'Biratnagar, Nepal',
  'Birgunj, Nepal',
];

const List<String> kJobTypes = [
  'Full-Time',
  'Part-Time',
  'Contract',
  'Freelance',
  'Internship',
];

const List<String> kExperienceLevels = [
  'Entry Level',
  'Junior',
  'Mid-Level',
  'Senior',
  'Lead / Principal',
  'Executive',
];

const List<String> kCategories = [
  'Software Development',
  'Design & Creative',
  'Marketing',
  'Sales',
  'Finance & Accounting',
  'HR & Recruitment',
  'Operations',
  'Customer Support',
  'Data & Analytics',
  'Other',
];

class PostJobScreen extends ConsumerStatefulWidget {
  const PostJobScreen({super.key});

  @override
  ConsumerState<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends ConsumerState<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();

  final _jobTitleCtrl = TextEditingController();
  final _companyNameCtrl = TextEditingController();
  final _logoUrlCtrl = TextEditingController();
  final _minSalaryCtrl = TextEditingController();
  final _maxSalaryCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _reqInputCtrl = TextEditingController();
  final _benInputCtrl = TextEditingController();

  String? _selectedLocation;
  String? _selectedJobType;
  String? _selectedExperience;
  String? _selectedCategory;

  final List<String> _requirements = [];
  final List<String> _benefits = [];

  bool _isSubmitting = false;

  // ✅ Company logo file picked from gallery/camera
  File? _logoFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _jobTitleCtrl.dispose();
    _companyNameCtrl.dispose();
    _logoUrlCtrl.dispose();
    _minSalaryCtrl.dispose();
    _maxSalaryCtrl.dispose();
    _descriptionCtrl.dispose();
    _reqInputCtrl.dispose();
    _benInputCtrl.dispose();
    super.dispose();
  }

  void _addRequirement() {
    final text = _reqInputCtrl.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _requirements.add(text);
        _reqInputCtrl.clear();
      });
    }
  }

  void _addBenefit() {
    final text = _benInputCtrl.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _benefits.add(text);
        _benInputCtrl.clear();
      });
    }
  }

  void _removeRequirement(int index) =>
      setState(() => _requirements.removeAt(index));

  void _removeBenefit(int index) =>
      setState(() => _benefits.removeAt(index));

  Future<void> _pickLogo() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? img = await _picker.pickImage(
                      source: ImageSource.camera, imageQuality: 80);
                  if (img != null) setState(() => _logoFile = File(img.path));
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? img = await _picker.pickImage(
                      source: ImageSource.gallery, imageQuality: 80);
                  if (img != null) setState(() => _logoFile = File(img.path));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLocation == null ||
        _selectedJobType == null ||
        _selectedExperience == null ||
        _selectedCategory == null) {
      _showSnack('Please fill all required dropdown fields.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final apiClient = ref.read(apiClientProvider);

      // ✅ Build multipart form data to support logo file upload
      final Map<String, dynamic> fields = {
        'jobTitle': _jobTitleCtrl.text.trim(),
        'companyName': _companyNameCtrl.text.trim(),
        'location': _selectedLocation!,
        'jobType': _selectedJobType!,
        'experienceLevel': _selectedExperience!,
        'category': _selectedCategory!,
        'description': _descriptionCtrl.text.trim(),
        if (_minSalaryCtrl.text.isNotEmpty) 'minSalary': _minSalaryCtrl.text.trim(),
        if (_maxSalaryCtrl.text.isNotEmpty) 'maxSalary': _maxSalaryCtrl.text.trim(),
        if (_logoUrlCtrl.text.isNotEmpty) 'companyLogoUrl': _logoUrlCtrl.text.trim(),
      };

      // Add requirements and benefits as repeated fields
      for (final req in _requirements) {
        fields['requirements'] = _requirements;
        break;
      }
      for (final ben in _benefits) {
        fields['benefits'] = _benefits;
        break;
      }

      FormData formData;

      if (_logoFile != null) {
        // ✅ Upload with logo file
        final fileName = _logoFile!.path.split('/').last;
        formData = FormData.fromMap({
          ...fields,
          'companyLogo': await MultipartFile.fromFile(
            _logoFile!.path,
            filename: fileName,
          ),
        });
      } else {
        formData = FormData.fromMap(fields);
      }

      // ✅ Actually call the API — this was missing before!
      final response = await apiClient.post(
        ApiEndpoints.jobs,
        data: formData,
      );

      final body = response.data;
      final success = body is Map ? body['success'] == true : false;

      if (success) {
        _showSnack('Job posted successfully!');
        if (mounted) Navigator.of(context).pop(true); // ✅ return true so caller can refresh
      } else {
        final msg = body is Map ? body['message'] ?? 'Failed to post job' : 'Failed to post job';
        _showSnack(msg, isError: true);
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = data is Map ? data['message'] ?? 'Failed to post job' : 'Failed to post job';
      _showSnack(msg, isError: true);
    } catch (e) {
      _showSnack('Something went wrong: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            isError ? Colors.red.shade700 : const Color(0xFF2563EB),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 24),
                  children: [
                    _SectionCard(
                      title: 'Basic Information',
                      children: [
                        _buildField(
                          label: 'Job Title',
                          required: true,
                          child: TextFormField(
                            controller: _jobTitleCtrl,
                            decoration: const InputDecoration(
                              hintText: 'e.g., Senior Full-Stack Developer',
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                label: 'Company Name',
                                required: true,
                                child: TextFormField(
                                  controller: _companyNameCtrl,
                                  decoration: const InputDecoration(
                                      hintText: 'Your Company'),
                                  validator: (v) =>
                                      (v == null || v.isEmpty)
                                          ? 'Required'
                                          : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildField(
                                label: 'Company Logo URL (optional)',
                                child: TextFormField(
                                  controller: _logoUrlCtrl,
                                  decoration: const InputDecoration(
                                    hintText:
                                        'https://example.com/logo.png',
                                  ),
                                  keyboardType: TextInputType.url,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // ✅ Logo file picker
                        _buildField(
                          label: 'Company Logo (upload image)',
                          child: GestureDetector(
                            onTap: _pickLogo,
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 12),
                                  if (_logoFile != null) ...[
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(6),
                                      child: Image.file(_logoFile!,
                                          width: 36,
                                          height: 36,
                                          fit: BoxFit.cover),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _logoFile!.path.split('/').last,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF374151)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close,
                                          size: 18,
                                          color: Color(0xFF94A3B8)),
                                      onPressed: () =>
                                          setState(() => _logoFile = null),
                                    ),
                                  ] else ...[
                                    const Icon(Icons.upload_outlined,
                                        color: Color(0xFF94A3B8), size: 20),
                                    const SizedBox(width: 8),
                                    const Text('Tap to upload logo',
                                        style: TextStyle(
                                            color: Color(0xFFADB5BD),
                                            fontSize: 14)),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Location & Compensation',
                      children: [
                        _buildField(
                          label: 'Location',
                          required: true,
                          child: _buildDropdown(
                            hint: 'Select a location',
                            value: _selectedLocation,
                            items: kLocations,
                            onChanged: (v) =>
                                setState(() => _selectedLocation = v),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                label: 'Min Salary (NPR)',
                                child: TextFormField(
                                  controller: _minSalaryCtrl,
                                  decoration: const InputDecoration(
                                      hintText: 'e.g., 30000'),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildField(
                                label: 'Max Salary (NPR)',
                                child: TextFormField(
                                  controller: _maxSalaryCtrl,
                                  decoration: const InputDecoration(
                                      hintText: 'e.g., 80000'),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Job Details',
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                label: 'Job Type',
                                required: true,
                                child: _buildDropdown(
                                  hint: 'Select job type',
                                  value: _selectedJobType,
                                  items: kJobTypes,
                                  onChanged: (v) =>
                                      setState(() => _selectedJobType = v),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildField(
                                label: 'Experience Level',
                                required: true,
                                child: _buildDropdown(
                                  hint: 'Select experience level',
                                  value: _selectedExperience,
                                  items: kExperienceLevels,
                                  onChanged: (v) =>
                                      setState(() => _selectedExperience = v),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Category',
                          required: true,
                          child: _buildDropdown(
                            hint: 'Select category',
                            value: _selectedCategory,
                            items: kCategories,
                            onChanged: (v) =>
                                setState(() => _selectedCategory = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Job Description',
                      children: [
                        _buildField(
                          label: 'Description',
                          required: true,
                          child: TextFormField(
                            controller: _descriptionCtrl,
                            maxLines: 6,
                            decoration: const InputDecoration(
                              hintText:
                                  'Provide a detailed description of the job role, responsibilities, and what makes this opportunity unique...',
                              alignLabelWithHint: true,
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Requirements',
                      children: [
                        _buildTagInput(
                          controller: _reqInputCtrl,
                          hint: 'e.g., 5+ years of React experience',
                          onAdd: _addRequirement,
                          tags: _requirements,
                          onRemove: _removeRequirement,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Benefits',
                      children: [
                        _buildTagInput(
                          controller: _benInputCtrl,
                          hint:
                              'e.g., Health Insurance, Remote Work, Stock Options',
                          onAdd: _addBenefit,
                          tags: _benefits,
                          onRemove: _removeBenefit,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildActionButtons(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back,
                    size: 18, color: Color(0xFF64748B)),
                SizedBox(width: 4),
                Text('Go Back',
                    style: TextStyle(
                        fontSize: 14, color: Color(0xFF64748B))),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Post a Job',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Fill in the details below to post a new job opportunity',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    bool required = false,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
            children: required
                ? const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint,
          style: const TextStyle(
              color: Color(0xFFADB5BD), fontSize: 14)),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      ),
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child:
                    Text(e, style: const TextStyle(fontSize: 14)),
              ))
          .toList(),
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF94A3B8)),
      isExpanded: true,
    );
  }

  Widget _buildTagInput({
    required TextEditingController controller,
    required String hint,
    required VoidCallback onAdd,
    required List<String> tags,
    required void Function(int) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(hintText: hint),
                onFieldSubmitted: (_) => onAdd(),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 44,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: tags.asMap().entries.map((entry) {
              return Chip(
                label: Text(entry.value,
                    style: const TextStyle(fontSize: 13)),
                deleteIcon: const Icon(Icons.close, size: 15),
                onDeleted: () => onRemove(entry.key),
                backgroundColor: const Color(0xFFEFF6FF),
                side: const BorderSide(color: Color(0xFFBFDBFE)),
                labelStyle:
                    const TextStyle(color: Color(0xFF1D4ED8)),
                deleteIconColor: const Color(0xFF1D4ED8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).maybePop(),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            foregroundColor: const Color(0xFF374151),
          ),
          child: const Text('Cancel',
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 15)),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Text('Post Job',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}