import 'package:flutter/foundation.dart';

import '../model/thread_model.dart';
import '../repo/marked_read_repo.dart';

class MarkedReadProvider extends ChangeNotifier {
  MarkedReadProvider({required MarkedReadRepo repo}) : _repo = repo;

  final MarkedReadRepo _repo;

  final List<MessageThread> _threads = [];
  List<MessageThread> get threads => List.unmodifiable(_threads);

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;


  void setThreads(List<MessageThread> items) {
    _threads
      ..clear()
      ..addAll(items);
    notifyListeners();
  }

  Future<void> markAsRead(MessageThread thread) async {
    print("PROVIDER markAsRead CALLED for threadId=${thread.id}");
    _error = null;

    // final lastId = thread.lastMessageId;
    // if (lastId == null) {
    //   _error = "Missing lastMessageId for thread ${thread.id}";
    //   notifyListeners();
    //   return;
    // }

    _loading = true;
    notifyListeners();

    try {
      await _repo.markThreadAsRead(
        threadId: thread.id,
       // lastMessageId: lastId,
      );


      final idx = _threads.indexWhere((t) => t.id == thread.id);
      if (idx != -1) {
        _threads[idx] = _threads[idx].copyWith(unreadCount: 0);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
