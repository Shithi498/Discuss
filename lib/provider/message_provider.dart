import 'package:flutter/foundation.dart';

import '../model/chat_message_model.dart';
import '../repo/chat_message_repo.dart';


class MessageProvider with ChangeNotifier {
  final MessageRepo repo;

  MessageProvider({required this.repo});

  bool _sending = false;
  String? _error;
  final List<Message> _messages = [];

  bool get sending => _sending;
  String? get error => _error;
  List<Message> get messages => List.unmodifiable(_messages);

  // Future<void> sendMessage({
  //   required int threadId,
  //   required String body,
  //   String? authorName,
  //   List<int> attachmentIds = const [],
  // }) async {
  //   final trimmedBody = body.trim();
  //   if (trimmedBody.isEmpty && attachmentIds.isEmpty) return;
  //
  //   _sending = true;
  //   _error = null;
  //   notifyListeners();
  //
  //   try {
  //     final resp = await repo.sendMessage(
  //       threadId: threadId,
  //       body: trimmedBody,
  //
  //     );
  //
  //     if (!resp.success) {
  //       throw Exception('Server returned success = false');
  //     }
  //
  //
  //     final msg = Message(
  //       id: resp.messageId,
  //       threadId: threadId,
  //       body: trimmedBody,
  //       createdDate: resp.createdDate,
  //       authorName: authorName,
  //       isMine: true,
  //     );
  //
  //     _messages.add(msg);
  //   } catch (e) {
  //     _error = e.toString();
  //   } finally {
  //     _sending = false;
  //     notifyListeners();
  //   }
  // }

  Future<void> sendMessage({
    required int threadId,
    required String body,
    String? authorName,
    List<int> attachmentIds = const [],
  }) async {
    final trimmedBody = body.trim();
    if (trimmedBody.isEmpty && attachmentIds.isEmpty) return;

    _sending = true;
    _error = null;
    notifyListeners();

    try {
      final resp = await repo.sendMessage(
        threadId: threadId,
        body: trimmedBody,
        attachmentIds: attachmentIds,
      );

      if (!resp.success) {
        throw Exception('Server returned success = false');
      }

      final msg = Message(
        id: resp.messageId,
        threadId: threadId,
        body: trimmedBody,
        createdDate: resp.createdDate,
        authorName: authorName,
        isMine: true,
        // If you have attachments field in Message model, set it here
      );

      _messages.add(msg);
    } catch (e) {
      _error = e.toString();
    } finally {
      _sending = false;
      notifyListeners();
    }
  }



  void setMessages(List<Message> msgs) {
    _messages
      ..clear()
      ..addAll(msgs);
    notifyListeners();
  }
}
