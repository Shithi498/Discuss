import 'package:flutter/foundation.dart';

import '../model/reaction.dart';
import '../repo/reaction_repo.dart';

class ReactionProvider extends ChangeNotifier {
  final ReactionRepo repo;

  ReactionProvider({required this.repo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? get error => repo.error;

  ReactionResponse? _lastResponse;
  ReactionResponse? get lastResponse => _lastResponse;

  Future<ReactionResponse?> toggleReaction({
    required int messageId,
    required String content,
  }) async {
    return _run(() => repo.toggleReaction(messageId: messageId, content: content));
  }

  Future<ReactionResponse?> addReaction({
    required int messageId,
    required String content,
  }) async {
    return _run(() => repo.addReaction(messageId: messageId, content: content));
  }

  Future<ReactionResponse?> removeReaction({
    required int messageId,
    required String content,
  }) async {
    return _run(() => repo.removeReaction(messageId: messageId, content: content));
  }

  Future<ReactionResponse?> _run(
      Future<ReactionResponse?> Function() action,
      ) async {
    _isLoading = true;
    _lastResponse = null;
    notifyListeners();

    final result = await action();
    _lastResponse = result;

    _isLoading = false;
    notifyListeners();

    return result;
  }

  void clearError() {
    repo.error = null; // make sure repo.error is not `final`
    notifyListeners();
  }
}
