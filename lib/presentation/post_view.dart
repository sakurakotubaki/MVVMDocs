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
