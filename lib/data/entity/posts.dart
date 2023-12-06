// This file is "main.dart"
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'posts.freezed.dart';

part 'posts.g.dart';
// モックサーバーのデータに合わせて、Postクラスを定義
@freezed
class Post with _$Post {
  const factory Post({
    @Default(0) int id,
    @Default(0) int userId,
    @Default('') String title,
    @Default('') String body,
  }) = _Post;

  factory Post.fromJson(Map<String, Object?> json)
      => _$PostFromJson(json);
}

// `Posts`クラスは、`Post`オブジェクトのリストを保持する役割を果たします。
// `freezed`パッケージを使用して不変性を保証し、`Post`オブジェクトのリストをデフォルトで空に設定しています。
// また、JSONから`Posts`オブジェクトを生成するためのファクトリメソッドも提供しています。
@freezed
class Posts with _$Posts {
  const factory Posts({
  @Default([]) List<Post> posts,
  }) = _Posts;

  factory Posts.fromJson(Map<String, Object?> json)
      => _$PostsFromJson(json);
}
