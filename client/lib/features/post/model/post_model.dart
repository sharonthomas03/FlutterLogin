class Post {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final PostUser createdBy;
  final bool isHidden;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.createdBy,
    required this.isHidden,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    PostUser author;
    final createdByJson = json['createdBy'];
    if (createdByJson is Map<String, dynamic>) {
      author = PostUser.fromJson(createdByJson);
    } else {
      author = PostUser(
        id: createdByJson?.toString() ?? '',
        username: 'User',
        email: '',
      );
    }

    return Post(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      content: (json['content'] ?? '') as String,
      imageUrl: (json['imageUrl'] ?? '') as String,
      createdBy: author,
      isHidden: (json['isHidden'] ?? false) as bool,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'createdBy': createdBy.toJson(),
      'isHidden': isHidden,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Post copyWith({
    String? id,
    String? title,
    String? content,
    String? imageUrl,
    PostUser? createdBy,
    bool? isHidden,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      createdBy: createdBy ?? this.createdBy,
      isHidden: isHidden ?? this.isHidden,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PostUser {
  final String id;
  final String username;
  final String email;

  PostUser({
    required this.id,
    required this.username,
    required this.email,
  });

  factory PostUser.fromJson(Map<String, dynamic> json) {
    return PostUser(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      username: (json['username'] ?? 'User') as String,
      email: (json['email'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
    };
  }
}
