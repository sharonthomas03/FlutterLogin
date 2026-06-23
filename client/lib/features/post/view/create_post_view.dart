import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../auth/viewmodel/auth_view_model.dart';
import '../viewmodel/post_viewmodel.dart';
import '../../../core/utils/app_toast.dart';
import '../../../app/widget/theme_toggle_button.dart';

class CreatePostView extends StatefulWidget {
  final VoidCallback onPostCreated;

  const CreatePostView({super.key, required this.onPostCreated});

  @override
  State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  XFile? _selectedImage;
  Uint8List? _webImageBytes;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
            _selectedImage = image;
          });
        } else {
          setState(() {
            _selectedImage = image;
          });
        }
      }
    } catch (e) {
      AppToast.show(context, "Failed to select image: ${e.toString()}");
    }
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewModel>();
    final postViewModel = context.read<PostViewModel>();
    final token = authViewModel.currentUser?.token;

    if (token == null) {
      AppToast.show(context, "You must be logged in to create a post");
      return;
    }

    try {
      await postViewModel.createPost(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        imagePath: _selectedImage?.path,
        imageBytes: _webImageBytes,
        imageName: _selectedImage?.name,
        token: token,
      );

      if (!mounted) return;
      AppToast.show(context, "Post created successfully");
      
      // Reset form
      _titleController.clear();
      _contentController.clear();
      setState(() {
        _selectedImage = null;
        _webImageBytes = null;
      });

      // Redirect to Home Feed
      widget.onPostCreated();
    } catch (e) {
      if (!mounted) return;
      AppToast.show(context, postViewModel.errorMessage ?? e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSaving = context.watch<PostViewModel>().isSaving;

    final pageGradient = isDark
        ? const [Color(0xFF050816), Color(0xFF0B1220), Color(0xFF121A2B)]
        : const [Color(0xFFF7FAFF), Color(0xFFEEF4FF), Color(0xFFE8F7F4)];

    final containerBg = isDark
        ? const [Color(0xFF161F34), Color(0xFF0F172A)]
        : const [Color(0xFFFFFFFF), Color(0xFFF7FBFF)];

    final containerBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFD9E7FF);

    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.30)
        : const Color(0xFF9FB9E8).withValues(alpha: 0.20);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create Post",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        actions: const [
          ThemeToggleButton(),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: pageGradient,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: containerBg,
                  ),
                  border: Border.all(color: containerBorder),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 30,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Share something new",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Create a new post to show on the public feed.",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Title Input ──────────────────────────────────
                        TextFormField(
                          controller: _titleController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: "Title",
                            hintText: "Enter a catchy title",
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Title cannot be empty";
                            }
                            if (value.trim().length < 3) {
                              return "Title must be at least 3 characters";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // ── Content Input ────────────────────────────────
                        TextFormField(
                          controller: _contentController,
                          maxLines: 4,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: "Description",
                            hintText: "Describe what this post is about",
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Description cannot be empty";
                            }
                            if (value.trim().length < 5) {
                              return "Description must be at least 5 characters";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // ── Image Picker ─────────────────────────────────
                        const Text(
                          "Add an image (optional)",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickImage,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 160,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF7FAFF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFDCE8F8),
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _selectedImage != null
                                ? (kIsWeb
                                    ? Image.memory(_webImageBytes!, fit: BoxFit.cover)
                                    : Image.file(File(_selectedImage!.path), fit: BoxFit.cover))
                                : const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey),
                                        SizedBox(height: 8),
                                        Text("Tap to select image", style: TextStyle(color: Colors.grey, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Submit Button ────────────────────────────────
                        ElevatedButton(
                          onPressed: isSaving ? null : _submitPost,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: isDark ? const Color(0xFF04111F) : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : const Text("Publish Post"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
