// import 'package:flutter/foundation.dart';
// import '../model/thread_model.dart';
// import '../repo/thread_repo.dart';
//
// class ThreadProvider extends ChangeNotifier {
//   final ThreadRepo repo;
//
//   ThreadProvider({required this.repo});
//
//   List<MessageThread> _threads = [];
//   bool _isLoading = false;
//   String? _error;
//
//   List<MessageThread> get threads => _threads;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//
//   Future<void> loadThreads() async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
//
//     try {
//       final data = await repo.fetchThreads();
//       _threads = data;
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   MessageThread? getThreadById(int id) {
//     try {
//       return _threads.firstWhere((t) => t.id == id);
//     } catch (_) {
//       return null;
//     }
//   }
// }

// lib/provider/thread_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../repo/thread_repo.dart';
import '../model/thread_model.dart';

class ThreadProvider extends ChangeNotifier {
  final ThreadRepo repo;
 // Timer? _timer;

  ThreadProvider({required this.repo}) ;

  // List<MessageThread> _threads = [];
 //  bool _isLoading = false;
  // String? _error;
  //
  // List<MessageThread> get threads => _threads;
  // bool get isLoading => _isLoading;
  // String? get error => _error;

  bool loadingChats = false;
  bool loadingGroups = false;
  bool loadingChannels = false;
  String? chatsError;
  String? groupsError;
  String? channelsError;
  List<MessageThread> chatThreads = [];
  List<MessageThread> groupThreads = [];
  List<MessageThread> channelThreads = [];

  List<MessageThread> get allThreads {
    final all = <MessageThread>[...chatThreads, ...groupThreads];

    // If both have same thread id sometimes, remove duplicates:
    final map = <int, MessageThread>{};
    for (final t in all) {
      map[t.id] = t;
    }
    final merged = map.values.toList();

    // Sort newest first if you have a date
  //  merged.sort((a, b) => (b.lastMessageDate ?? "").compareTo(a.lastMessageDate ?? ""));
    return merged;
  }

  Future<void> loadAll() async {
    await Future.wait([loadThreads(), loadgroupThreads()]);
  }
  Future<void> loadThreads() async {
    loadingChats = true;
    notifyListeners();

    try {
      chatThreads  = await repo.fetchThreads();
      chatsError = null;
    } catch (e) {
      chatsError = e.toString();
    }

    loadingChats = false;
    notifyListeners();
  }

  Future<void> loadgroupThreads() async {
    loadingGroups = true;
    notifyListeners();

    try {
      groupThreads = await repo.groupfetchThreads();
      groupsError = null;
    } catch (e) {
      groupsError = e.toString();
    }

    loadingGroups = false;
    notifyListeners();
  }

  Future<void> loadchannelThreads() async {
    loadingChannels = true;
    notifyListeners();

    try {
      channelThreads = await repo.channelfetchThreads();
      channelsError = null;

    } catch (e) {
      channelsError = e.toString();
    }

    loadingChannels = false;
    notifyListeners();
  }


  // Future<void> refreshSilently() async {
  //   try {
  //     final updatedList = await repo.fetchThreads();
  //
  //
  //     _threads = updatedList;
  //     notifyListeners();
  //   } catch (_) {
  //     // ignore errors silently
  //   }
  // }



  @override
  void dispose() {
    //_timer?.cancel();
    super.dispose();
  }
}
