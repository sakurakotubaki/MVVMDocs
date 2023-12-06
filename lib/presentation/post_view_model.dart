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
