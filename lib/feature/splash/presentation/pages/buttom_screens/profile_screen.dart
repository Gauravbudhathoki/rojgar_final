import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rojgar/feature/auth/domain/entities/auth_entity.dart';
import 'package:rojgar/feature/auth/presentation/pages/login_screen.dart';
import 'package:rojgar/feature/auth/presentation/state/auth_state.dart';
import 'package:rojgar/feature/auth/presentation/view_model/auth_view_model.dart';


class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditingUsername = false;
  bool _isEditingEmail = false;
  bool _isEditingPhone = false;
  bool _isSaving = false;
  XFile? _selectedImage;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();
  AuthEntity? _lastLoadedEntity;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authViewModelProvider.notifier).getCurrentUser();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _populateFromEntity(AuthEntity entity) {
    if (_lastLoadedEntity == entity) return;
    _lastLoadedEntity = entity;
    if (!_isEditingUsername) _usernameController.text = entity.username;
    if (!_isEditingEmail) _emailController.text = entity.email;
  }

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) return true;
    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }
    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
      return false;
    }
    return false;
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'This feature requires camera or gallery access. '
          'Please enable it in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _openCamera() async {
    final hasPermission = await _requestPermission(Permission.camera);
    if (!hasPermission) return;
    final XFile? image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (image != null) {
      setState(() => _selectedImage = image);
      await _uploadProfilePicture(File(image.path));
    }
  }

  Future<void> _openGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 80);
      if (image != null) {
        setState(() => _selectedImage = image);
        await _uploadProfilePicture(File(image.path));
      }
    } catch (e) {
      debugPrint('Gallery Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Unable to access gallery. Please try the camera.')),
        );
      }
    }
  }

  Future<void> _uploadProfilePicture(File imageFile) async {
    setState(() => _isUploading = true);
    try {
      await ref
          .read(authViewModelProvider.notifier)
          .uploadProfilePicture(imageFile);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to upload profile picture.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showImageSourceSheet() {
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
                onTap: () {
                  Navigator.pop(context);
                  _openCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _openGallery();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveField({
    required String label,
    required String value,
    required VoidCallback onDone,
  }) async {
    if (value.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label cannot be empty')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      onDone();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update $label')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red, size: 22),
            SizedBox(width: 8),
            Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(authViewModelProvider.notifier).logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? profilePictureUrl) {
    ImageProvider? imageProvider;
    if (_selectedImage != null) {
      imageProvider = FileImage(File(_selectedImage!.path));
    } else if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) {
      imageProvider = CachedNetworkImageProvider(profilePictureUrl);
    }

    return GestureDetector(
      onTap: _isUploading ? null : _showImageSourceSheet,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: imageProvider,
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.blue)
                  : imageProvider == null
                      ? const Icon(Icons.person,
                          size: 52, color: Colors.grey)
                      : null,
            ),
          ),
          if (!_isUploading)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt,
                    size: 16, color: Colors.blue),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onEditTap,
    required VoidCallback onSaveTap,
    required VoidCallback onCancelTap,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: isEditing
                  ? TextField(
                      controller: controller,
                      keyboardType: keyboardType,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: label,
                        isDense: true,
                        border: const UnderlineInputBorder(),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 2),
                        Text(
                          controller.text.isNotEmpty
                              ? controller.text
                              : 'Not set',
                          style: TextStyle(
                            fontSize: 15,
                            color: controller.text.isNotEmpty
                                ? Colors.black87
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
            ),
            if (isEditing) ...[
              IconButton(
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check, color: Colors.green),
                onPressed: _isSaving ? null : onSaveTap,
                tooltip: 'Save',
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: _isSaving ? null : onCancelTap,
                tooltip: 'Cancel',
              ),
            ] else
              IconButton(
                icon:
                    const Icon(Icons.edit, size: 18, color: Colors.blue),
                onPressed: onEditTap,
                tooltip: 'Edit $label',
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final entity = authState.authEntity;
    final isLoading = authState.status == AuthStatus.loading;

    // ── Logout listener: navigate to LoginScreen when unauthenticated ──
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.unauthenticated) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
        );
      }
    });

    if (entity != null) {
      _populateFromEntity(entity);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: isLoading && entity == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.blue,
                    padding:
                        const EdgeInsets.only(top: 16, bottom: 32),
                    child: Column(
                      children: [
                        _buildAvatar(entity?.profilePicture),
                        const SizedBox(height: 12),
                        Text(
                          entity?.username ?? 'Your Name',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entity?.email ?? 'your@email.com',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.only(left: 24, bottom: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'PERSONAL INFO',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  _buildEditableField(
                    label: 'Username',
                    icon: Icons.person_outline,
                    controller: _usernameController,
                    isEditing: _isEditingUsername,
                    onEditTap: () =>
                        setState(() => _isEditingUsername = true),
                    onSaveTap: () => _saveField(
                      label: 'Username',
                      value: _usernameController.text,
                      onDone: () =>
                          setState(() => _isEditingUsername = false),
                    ),
                    onCancelTap: () {
                      _usernameController.text =
                          entity?.username ?? '';
                      setState(() => _isEditingUsername = false);
                    },
                  ),
                  _buildEditableField(
                    label: 'Email Address',
                    icon: Icons.email_outlined,
                    controller: _emailController,
                    isEditing: _isEditingEmail,
                    keyboardType: TextInputType.emailAddress,
                    onEditTap: () =>
                        setState(() => _isEditingEmail = true),
                    onSaveTap: () => _saveField(
                      label: 'Email',
                      value: _emailController.text,
                      onDone: () =>
                          setState(() => _isEditingEmail = false),
                    ),
                    onCancelTap: () {
                      _emailController.text = entity?.email ?? '';
                      setState(() => _isEditingEmail = false);
                    },
                  ),
                  _buildEditableField(
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    controller: _phoneController,
                    isEditing: _isEditingPhone,
                    keyboardType: TextInputType.phone,
                    onEditTap: () =>
                        setState(() => _isEditingPhone = true),
                    onSaveTap: () => _saveField(
                      label: 'Phone',
                      value: _phoneController.text,
                      onDone: () =>
                          setState(() => _isEditingPhone = false),
                    ),
                    onCancelTap: () =>
                        setState(() => _isEditingPhone = false),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _confirmLogout,
                        icon: const Icon(Icons.logout,
                            color: Colors.red),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                              color: Colors.red, fontSize: 15),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          side:
                              const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}