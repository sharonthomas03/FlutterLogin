import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../auth/viewmodel/auth_view_model.dart';
import '../model/post_model.dart';
import '../viewmodel/post_viewmodel.dart';
import '../../../core/utils/app_toast.dart';

class EditPostDialog extends StatefulWidget {
  final Post post;

  const EditPostDialog({super.key, required this.post});

  @override
  State<EditPostDialog> createState() => _EditPostDialogState();
}

class _EditPostDialogState extends State<EditPostDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  XFile? _selectedImage;
  Uint8List? _webImageBytes;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _contentController = TextEditingController(text: widget.post.content);
  }

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

  Future<void> _savePost() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewModel>();
    final postViewModel = context.read<PostViewModel>();
    final token = authViewModel.currentUser?.token;

    if (token == null) {
      AppToast.show(context, "Unauthorized action");
      return;
    }

    try {
      await postViewModel.updatePost(
        id: widget.post.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        imagePath: _selectedImage?.path,
        imageBytes: _webImageBytes,
        imageName: _selectedImage?.name,
        token: token,
      );
      if (!mounted) return;
      AppToast.show(context, "Post updated successfully");
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppToast.show(context, postViewModel.errorMessage ?? e.toString());
    }
  }

  String _getEffectiveImageUrl(String url) {
    if (kIsWeb) return url;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return url.replaceAll('http://localhost:5000', 'http://10.0.2.2:5000');
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSaving = context.watch<PostViewModel>().isSaving;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? const Color(0xFF161F34) : Colors.white,
      title: const Text("Edit Post", style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title ─────────────────────────────────────────
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Title",
                    hintText: "Enter post title",
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Title is required";
                    }
                    if (value.trim().length < 3) {
                      return "Title must be at least 3 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Description/Content ───────────────────────────
                TextFormField(
                  controller: _contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    hintText: "What's on your mind?",
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Description is required";
                    }
                    if (value.trim().length < 5) {
                      return "Description must be at least 5 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Image Preview and Selector ───────────────────
                const Text(
                  "Post Image",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
                            ? Image.memory(_webImageBytes!, fit: BoxThemeFit)
                            : Image.file(File(_selectedImage!.path), fit: BoxFit.cover))
                        : (widget.post.imageUrl.isNotEmpty
                            ? Image.network(
                                _getEffectiveImageUrl(widget.post.imageUrl),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(child: Icon(Icons.broken_image_outlined, size: 40));
                                },
                              )
                            : const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate_outlined, size: 36, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text("Change post image (optional)", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: isSaving ? null : _savePost,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: isDark ? const Color(0xFF04111F) : Colors.white,
            minimumSize: const Size(100, 45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Text("Save"),
        ),
      ],
    );
  }
}

// Add a fallback BoxFit mapping for compiling.
const BoxThemeFit = BoxFit.cover;
