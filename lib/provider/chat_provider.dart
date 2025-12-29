import 'package:flutter/cupertino.dart';
import '../model/chat_model.dart';
import '../repo/chat_repo.dart';


class ChatProvider extends ChangeNotifier {
  final ChatRepo repo;

  ChatProvider({required this.repo});
  final Map<int, List<Chat>> _messagesByThread = {};
  bool loading = false;
  String? error;
  Chat? thread;
  List<Chat> messagesForThread(int threadId) =>
      _messagesByThread[threadId] ?? [];

  Future<void> createChatThread({
    required String partnerName,
    required int partnerId,

  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      thread = await repo.createChatThreadForPartner(
        partnerName: partnerName,
        partnerId: partnerId,
      );
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  Future<void> createGroupThread({
    required String partnerName,
    required int partnerId,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      thread = await repo.createGroupThreadForPartner(
        partnerName: partnerName,
        partnerId: partnerId,
      );
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  Future<void> createChannelThread({
    required String partnerName,
    required int partnerId,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      thread = await repo.createChannelThreadForPartner(
        partnerName: partnerName,
        partnerId: partnerId,
      );
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

}






