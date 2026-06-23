import 'dart:typed_data';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../model/post_model.dart';

class PostService {
  final ApiClient apiClient;

  PostService({required this.apiClient});

  Future<List<Post>> getPosts() async {
    final response = await apiClient.get(ApiEndpoints.posts);
    final List<dynamic> postsJson = response['posts'] ?? [];
    return postsJson.map((json) => Post.fromJson(json)).toList();
  }

  Future<List<Post>> getMyPosts(String token) async {
    final response = await apiClient.get(ApiEndpoints.myPosts, token: token);
    final List<dynamic> postsJson = response['posts'] ?? [];
    return postsJson.map((json) => Post.fromJson(json)).toList();
  }

  Future<Post> createPost({
    required String title,
    required String content,
    String? imagePath,
    Uint8List? imageBytes,
    String? imageName,
    required String token,
  }) async {
    final response = await apiClient.postMultipart(
      endpoint: ApiEndpoints.posts,
      fields: {
        'title': title,
        'content': content,
      },
      filePath: imagePath,
      fileBytes: imageBytes,
      fileName: imageName,
      token: token,
    );
    return Post.fromJson(response['post']);
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
    final response = await apiClient.putMultipart(
      endpoint: ApiEndpoints.postDetail(id),
      fields: {
        'title': title,
        'content': content,
      },
      filePath: imagePath,
      fileBytes: imageBytes,
      fileName: imageName,
      token: token,
    );
    return Post.fromJson(response['post']);
  }

  Future<void> deletePost({required String id, required String token}) async {
    await apiClient.delete(ApiEndpoints.postDetail(id), token: token);
  }

  Future<void> reportPost({
    required String id,
    required String reason,
    required String token,
  }) async {
    await apiClient.post(
      ApiEndpoints.reportPost(id),
      {'reason': reason},
      token: token,
    );
  }
}
