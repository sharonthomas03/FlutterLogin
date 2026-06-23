import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/viewmodel/auth_view_model.dart';
import '../viewmodel/post_viewmodel.dart';
import '../../../core/utils/app_toast.dart';

class ReportDialog extends StatefulWidget {
  final String postId;

  const ReportDialog({super.key, required this.postId});

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewModel>();
    final postViewModel = context.read<PostViewModel>();
    final token = authViewModel.currentUser?.token;

    if (token == null) {
      AppToast.show(context, "You must be logged in to report posts");
      return;
    }

    try {
      await postViewModel.reportPost(
        id: widget.postId,
        reason: _reasonController.text.trim(),
        token: token,
      );
      if (!mounted) return;
      AppToast.show(context, "Post reported successfully");
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppToast.show(context, postViewModel.errorMessage ?? e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isReporting = context.watch<PostViewModel>().isReporting;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? const Color(0xFF161F34) : Colors.white,
      title: Row(
        children: [
          Icon(Icons.report_problem_outlined, color: theme.colorScheme.error),
          const SizedBox(width: 10),
          const Text("Report Post", style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Please provide a reason for reporting this post. Reports are reviewed by administrators.",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              maxLines: 3,
              maxLength: 150,
              decoration: const InputDecoration(
                hintText: "Reason for report (e.g. Inappropriate content, spam)",
                counterText: "",
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Reason is required";
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isReporting ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: isReporting ? null : _submitReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: Colors.white,
            minimumSize: const Size(100, 45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: isReporting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Text("Report"),
        ),
      ],
    );
  }
}
