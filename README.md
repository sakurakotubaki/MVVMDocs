# MVVMとは?

**全体のコードはこちら**
https://github.com/sakurakotubaki/MVVMDocs

モックサーバーの使い方はこちらを参考にしてください。
https://zenn.dev/joo_hashi/books/20dd2274ba88a9

### このページについて
MVVMについてわかりやすく解説するページです。フォルダの構成とか、ファイルの分け方の学習をするためのものなので、パッケージのインストールとかまではしないです。試してみたい人は、riverpod, Freezed, dioをインストールしてください。
こちらのページは、riverpod generatorでは解説してないです。新しい書き方を知りたい人はこちらの本を読んでみてください。
https://zenn.dev/joo_hashi/books/2c6c47e3d79b63

https://pub.dev/packages/flutter_riverpod

https://pub.dev/packages/dio

https://zenn.dev/jboy_blog/articles/9c6bdebf87b8ae

MVVM（Model-View-ViewModel）は、UIロジックをビジネスロジックから分離するためのソフトウェアアーキテクチャパターンです。MVVMは主に3つのコンポーネントで構成されています：

Model：データアクセスレイヤーまたはビジネスロジックを表します。データベース操作やAPI呼び出し、データの検証や変換などを行います。

```dart
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
```

-----

ViewModel：ViewとModelの間のデータバインディングとコマンドの実行を担当します。Viewが表示するデータの準備と、ユーザーのアクションに対するレスポンスを管理します。

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/entity/posts.dart';
import '../data/repository/api_repository.dart';

final postViewModelProvider = StateNotifierProvider<PostViewModel, AsyncValue<List<Post>>>((ref) {
  return PostViewModel(ref);
});

// FutureProviderを今回は使用しないので、StateNotifierProviderを使用しています。
// AsyncValueのPostViewModelを使うことによって、FutureProviderを使用した場合と同じように、
class PostViewModel extends StateNotifier<AsyncValue<List<Post>>> {
  final Ref ref;

  PostViewModel(this.ref) : super(const AsyncValue.loading()) {
    // レポジトリからデータを取得するメソッドを呼び出して、ViewModelの初期化を行う。ref.watchを使用して、View側にAPIのレスポンスを返す。
    getPosts();
  }
  // レポジトリからデータを取得するメソッドを定義
  Future<void> getPosts() async {
    try {
      final posts = await ref.read(apiTestImplProvider).getPosts();
      state = AsyncValue.data(posts);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}
```

ViewModelは、Viewが必要とするデータを準備し、Viewからのユーザー入力に対するレスポンスを管理します。しかし、ビジネスロジック自体（例えば、データの取得や保存、データの検証や変換など）は通常、Repositoryなどの別のクラスに委譲されます。これにより、ViewModelはUIロジックに集中でき、テストや再利用が容易になります。

これが`Repository`です。APIとのやりとりをするロジック

```dart
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
```

----

View：ユーザーインターフェースを表します。ユーザーの入力を受け取り、ユーザーに情報を表示します。

**APIのデータを表示するView**
`FutureProvider`を使わなくてもViewModelで`AsyncValue`のデータを返せば非同期にデータを取得することができます。

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'post_view_model.dart';

class PostView extends ConsumerWidget {
  const PostView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ViewModelをインスタンス化
    final postViewModel = ref.watch(postViewModelProvider);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Posts'),
        ),
        // ViewModelの状態によって、表示するWidgetを変更する
        body: postViewModel.when(
          data: (posts) => ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return ListTile(
                title: Text(post.title),
                subtitle: Text(post.body),
              );
            },
          ),
          // データ取得中はローディングを表示
          loading: () => const Center(child: Text('Loading...')),
          // データ取得に失敗した場合はエラーを表示
          error: (e, stackTrace) => Center(
            child: Text('Error: $e'),
          ),
        ));
  }
}
```
## アプリを実行するにはこちらのコードを追加
```dart
import 'package:flutter/material.dart';

import 'post_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PostView(),
    );
  }
}
```

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_tutorial/presentation/app.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}
```

## 最後に
ざっくりとですけど、MVVMについて解説しました。以前は、
