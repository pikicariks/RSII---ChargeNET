import 'dart:convert';
import 'dart:typed_data';

import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? _originalImageBase64;
  String? _pickedImageBase64;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final api = await ref.read(chargeNetApiProvider.future);
      final profile = await api.getMyProfile();
      if (!mounted) {
        return;
      }
      _firstNameController.text = profile.firstName;
      _lastNameController.text = profile.lastName;
      _phoneController.text = profile.phoneNumber ?? '';
      _addressController.text = profile.address ?? '';
      _originalImageBase64 = profile.profileImageBase64;
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (file == null) {
      return;
    }

    final bytes = await file.readAsBytes();
    if (!mounted) {
      return;
    }
    setState(() {
      _pickedImageBase64 = base64Encode(bytes);
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final api = await ref.read(chargeNetApiProvider.future);
      await api.updateMyProfile({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        if (_pickedImageBase64 != null) 'profileImageBase64': _pickedImageBase64,
      });

      ref.invalidate(authProvider);

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated.')),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: CnLoading(message: 'Loading profile...'));
    }

    Uint8List? imageBytes;
    final activeImageBase64 = _pickedImageBase64 ?? _originalImageBase64;
    if (activeImageBase64 != null && activeImageBase64.isNotEmpty) {
      try {
        imageBytes = base64Decode(activeImageBase64);
      } catch (_) {
        imageBytes = null;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: ListView(
        padding: const EdgeInsets.all(ChargeNetSpacing.mobileHorizontal),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: CnCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: ChargeNetColors.primaryMuted,
                            backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
                            child: imageBytes == null
                                ? Text(
                                    _firstNameController.text.isNotEmpty
                                        ? _firstNameController.text[0].toUpperCase()
                                        : '?',
                                    style: ChargeNetTextStyles.title(
                                      color: ChargeNetColors.primary,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            right: -4,
                            bottom: -4,
                            child: IconButton(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.photo_camera_outlined),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: ChargeNetSpacing.md),
                    CnTextField(
                      controller: _firstNameController,
                      label: 'First name',
                    ),
                    const SizedBox(height: ChargeNetSpacing.md),
                    CnTextField(
                      controller: _lastNameController,
                      label: 'Last name',
                    ),
                    const SizedBox(height: ChargeNetSpacing.md),
                    CnTextField(
                      controller: _phoneController,
                      label: 'Phone number',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: ChargeNetSpacing.md),
                    CnTextField(
                      controller: _addressController,
                      label: 'Address',
                    ),
                    const SizedBox(height: ChargeNetSpacing.lg),
                    CnButton(
                      label: 'Save changes',
                      isLoading: _saving,
                      onPressed: _saving ? null : _save,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
