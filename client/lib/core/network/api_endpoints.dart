class ApiEndpoints {
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String profile = '/api/profile';
  static const String posts = '/api/posts';
  static const String myPosts = '/api/posts/my';
  static String reportPost(String id) => '/api/posts/$id/report';
  static String postDetail(String id) => '/api/posts/$id';
}
