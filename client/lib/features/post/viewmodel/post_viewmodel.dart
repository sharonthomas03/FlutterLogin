import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../model/post_model.dart';
import '../service/post_service.dart';

class PostViewModel extends ChangeNotifier {
  final PostService postService;

  List<Post> _posts = [];
  List<Post> _myPosts = [];
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isReporting = false;
  String? _errorMessage;

  PostViewModel({required this.postService});

  List<Post> get posts => _posts;
  List<Post> get myPosts => _myPosts;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isReporting => _isReporting;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  void _setReporting(bool value) {
    _isReporting = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> fetchPosts() async {
    _setLoading(true);
    _setError(null);
    try {
      _posts = await postService.getPosts();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMyPosts(String token) async {
    _setLoading(true);
    _setError(null);
    try {
      _myPosts = await postService.getMyPosts(token);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Post> createPost({
    required String title,
    required String content,
    String? imagePath,
    Uint8List? imageBytes,
    String? imageName,
    required String token,
  }) async {
    _setSaving(true);
    _setError(null);
    try {
      final newPost = await postService.createPost(
        title: title,
        content: content,
        imagePath: imagePath,
        imageBytes: imageBytes,
        imageName: imageName,
        token: token,
      );
      _posts.insert(0, newPost);
      _myPosts.insert(0, newPost);
      notifyListeners();
      return newPost;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setSaving(false);
    }
  }

  Future<Post> updatePost({
    required String id,
    required String title,
    required String content,
    String? imagePath,
    Uint8List? imageBytes,
    String? imageName,
    required String token,
  }) async {
    _setSaving(true);
    _setError(null);
    try {
      final updated = await postService.updatePost(
        id: id,
        title: title,
        content: content,
        imagePath: imagePath,
        imageBytes: imageBytes,
        imageName: imageName,
        token: token,
      );

      final feedIndex = _posts.indexWhere((p) => p.id == id);
      if (feedIndex != -1) {
        _posts[feedIndex] = updated;
      }

      final myIndex = _myPosts.indexWhere((p) => p.id == id);
      if (myIndex != -1) {
        _myPosts[myIndex] = updated;
      }

      notifyListeners();
      return updated;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setSaving(false);
    }
  }

  Future<void> deletePost({required String id, required String token}) async {
    _setSaving(true);
    _setError(null);
    try {
      await postService.deletePost(id: id, token: token);
      _posts.removeWhere((p) => p.id == id);
      _myPosts.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setSaving(false);
    }
  }

  Future<void> reportPost({
    required String id,
    required String reason,
    required String token,
  }) async {
    _setReporting(true);
    _setError(null);
    try {
      await postService.reportPost(id: id, reason: reason, token: token);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setReporting(false);
    }
  }
}
