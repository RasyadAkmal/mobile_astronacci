import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_astronacci/bloc/auth/auth_bloc.dart';
import 'package:mobile_astronacci/bloc/profile/profile_bloc.dart';
import 'package:mobile_astronacci/models/user.dart';
import 'package:mobile_astronacci/presentation/widgets/user_avatar.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();
  File? _avatarFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Colors.indigo,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Crop Image',
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _avatarFile = File(croppedFile.path);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileUpdateFailure) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.error)));
            }
            if (state is ProfileUpdateSuccess) {
              context.read<AuthBloc>().add(AppStarted());
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile Updated Successfully')));
              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          if (_avatarFile != null)
                            CircleAvatar(
                                radius: 60,
                                backgroundImage: FileImage(_avatarFile!))
                          else
                            UserAvatar(imageUrl: widget.user.avatarUrl, radius: 60),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.indigo,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, color: Colors.white),
                                onPressed: _pickImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          labelText: 'Name', border: OutlineInputBorder()),
                      validator: (value) =>
                          value != null && value.isNotEmpty ? null : 'Name cannot be empty',
                    ),
                    const SizedBox(height: 24),
                    if (state is ProfileUpdateLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16)),
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            context.read<ProfileBloc>().add(UpdateProfileRequested(
                                name: _nameController.text,
                                avatar: _avatarFile));
                          }
                        },
                        child: const Text('UPDATE PROFILE'),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}