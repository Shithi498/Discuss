class Message {
  final int id;
  final int threadId;
  final String body;
  final String? authorName;
  final DateTime createdDate;
  final bool isMine;

  Message({
    required this.id,
    required this.threadId,
    required this.body,
    required this.createdDate,
    this.authorName,
    this.isMine = false,
  });

  factory Message.fromJson(Map<String, dynamic> json, {int? threadId, bool isMine = false}) {
    return Message(
      id: json['id'] ?? json['message_id'] ?? 0,
      threadId: threadId ?? json['thread_id'] ?? 0,
      body: json['body'] ?? '',
      authorName: json['author_name'],
      createdDate: DateTime.tryParse(json['created_date'] ?? '') ?? DateTime.now(),
      isMine: isMine,
    );
  }
}


class SendMessageResponse {
  final bool success;
  final int messageId;
  final DateTime createdDate;

  SendMessageResponse({
    required this.success,
    required this.messageId,
    required this.createdDate,
  });

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'] ?? json;
    return SendMessageResponse(
      success: result['success'] ?? false,
      messageId: result['message_id'] ?? 0,
      createdDate: DateTime.tryParse(result['created_date'] ?? '') ?? DateTime.now(),
    );
  }
}
