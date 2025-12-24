import 'package:flutter/foundation.dart';

import '../model/channel_participants_model.dart';
import '../repo/channel_participants_repo.dart';

class ChannelParticipantsProvider extends ChangeNotifier {
  final ChannelParticipantsRepo repo;

  ChannelParticipantsProvider({required this.repo});

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  int? _threadId;
  String? _threadName;

  int? get threadId => _threadId;
  String? get threadName => _threadName;

  List<ChannelParticipant> _participants = [];
  List<ChannelParticipant> get participants => _participants;

  Future<void> loadParticipants({required int threadId}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await repo.fetchParticipants(threadId: threadId);

      final result = res.result;
      if (result == null) {
        _error = "No result returned from server.";
        _participants = [];
        return;
      }

      _threadId = result.threadId;
      _threadName = result.threadName;
      _participants = result.participants;
    } catch (e) {
      _error = e.toString();
      _participants = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clear() {
    _error = null;
    _participants = [];
    _threadId = null;
    _threadName = null;
    notifyListeners();
  }
}
