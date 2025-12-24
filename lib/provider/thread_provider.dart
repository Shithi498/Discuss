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

  List<MessageThread> _threads = [];
  bool _isLoading = false;
  String? _error;

  List<MessageThread> get threads => _threads;
  bool get isLoading => _isLoading;
  String? get error => _error;


  Future<void> loadThreads() async {
    _isLoading = true;
    notifyListeners();

    try {
      _threads = await repo.fetchThreads();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadgroupThreads() async {
    _isLoading = true;
    notifyListeners();

    try {
      _threads = await repo.groupfetchThreads();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }


  Future<void> refreshSilently() async {
    try {
      final updatedList = await repo.fetchThreads();

      // Always replace with latest server view to avoid missing new threads.
      _threads = updatedList;
      notifyListeners();
    } catch (_) {
      // ignore errors silently
    }
  }



  @override
  void dispose() {
    //_timer?.cancel();
    super.dispose();
  }
}
