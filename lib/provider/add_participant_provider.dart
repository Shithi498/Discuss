import 'package:flutter/foundation.dart';

import '../model/add_participant.dart';
import '../repo/add_participant_repo.dart';

class AddParticipantProvider extends ChangeNotifier {
  final AddParticipantRepo repo;

  AddParticipantProvider({
    required this.repo,
  });

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  AddParticipantResult? _lastResult;
  AddParticipantResult? get lastResult => _lastResult;

  Participant? get lastParticipant => _lastResult?.participant;

  Future<bool> addParticipant({
    required int threadId,
    required int partnerId,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await repo.addParticipant(
        threadId: threadId,
        partnerId: partnerId,
      );

      _lastResult = res.result;

      final ok = res.result?.success == true;
      if (!ok) {
        _error = "Add participant failed (success=false).";
      }
      return ok;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clear() {
    _error = null;
    _lastResult = null;
    notifyListeners();
  }
}
