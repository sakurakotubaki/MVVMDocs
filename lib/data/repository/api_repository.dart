import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entity/posts.dart';
// ベースとなるabstract classを定義
abstract class APITest {
  Future<List<Post>> getPosts();
}
// dioをインスタンス化するProviderを定義
final dioProvider = Provider((ref) {
  return Dio();
});
// APITestImplをインスタンス化するProviderを定義
final apiTestImplProvider = Provider((ref) {
  return APITestImpl(ref);
});
// APITestを継承してオーバーライドしたAPITestImplクラスを定義
class APITestImpl implements APITest {
  final Ref ref;
  APITestImpl(this.ref);

  @override
  Future<List<Post>> getPosts() async {
    final response = await ref.read(dioProvider).get('http://localhost:3000/posts');

    if (response.statusCode == 200) {
      final List data = response.data;
      return data.map((item) => Post.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }
}
