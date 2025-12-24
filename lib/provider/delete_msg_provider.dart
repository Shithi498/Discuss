import 'package:flutter/foundation.dart';

import '../repo/delete_msg_repo.dart';

class DeleteMessageProvider extends ChangeNotifier {
  final DeleteMessageRepo repo;

  DeleteMessageProvider({
    required this.repo,
  });

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  String? _error;
  String? get error => _error;

  Future<bool> deleteMessage(int messageId) async {
    _isDeleting = true;
    _error = null;
    notifyListeners();
    print("Deleted");
    try {
      final success = await repo.deleteMessage(messageId: messageId);
      if(success){
        print("Deleted");
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }
}
