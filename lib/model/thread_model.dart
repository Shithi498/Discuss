class Participant {
  final int id;
  final String name;
  final int? partnerId;
  final int? userId;

  Participant({
    required this.id,
    required this.name,
    this.partnerId,
    this.userId,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'] as int,
      name: json['name'] as String,
      partnerId: json['partner_id'] as int?,
      userId: json['user_id'] as int?,
    );
  }
}

// class MessageThread {
//   final int id;
//   final String name;
//   final String type;
//   final List<Participant> participants;
//   final String? lastMessage;
//   final DateTime? lastMessageDate;
//   final int unreadCount;
//
//   MessageThread({
//     required this.id,
//     required this.name,
//     required this.type,
//     required this.participants,
//     required this.lastMessage,
//     required this.lastMessageDate,
//     required this.unreadCount,
//   });
//
//   factory MessageThread.fromJson(Map<String, dynamic> json) {
//
//     final rawDate = json['last_message_date'] as String?;
//     DateTime? parsedDate;
//     if (rawDate != null) {
//
//       final isoLike = rawDate.replaceFirst(' ', 'T');
//       parsedDate = DateTime.tryParse(isoLike);
//     }
//
//     final participantsJson = (json['participants'] as List<dynamic>? ?? []);
//
//
//
//     return MessageThread(
//       id: json['id'] as int,
//       name: json['name'] as String,
//       type: json['type'] as String,
//       participants: participantsJson
//           .map((p) => Participant.fromJson(p as Map<String, dynamic>))
//           .toList(),
//       lastMessage: json['last_message'] as String?,
//       lastMessageDate: parsedDate,
//       unreadCount: (json['unread_count'] ?? 0) as int,
//     );
//   }
// }

class MessageThread {
  final int id;
  final String name;
  final String type;
  final List<Participant> participants;

  final String? lastMessage;
  final DateTime? lastMessageDate;


  final int? lastMessageId;

  final int unreadCount;

  MessageThread({
    required this.id,
    required this.name,
    required this.type,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageDate,
    required this.lastMessageId,
    required this.unreadCount,
  });

  MessageThread copyWith({
    String? lastMessage,
    DateTime? lastMessageDate,
    int? lastMessageId,
    int? unreadCount,
  }) {
    return MessageThread(
      id: id,
      name: name,
      type: type,
      participants: participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageDate: lastMessageDate ?? this.lastMessageDate,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  factory MessageThread.fromJson(Map<String, dynamic> json) {
    final rawDate = json['last_message_date'] as String?;
    DateTime? parsedDate;
    if (rawDate != null) {
      final isoLike = rawDate.replaceFirst(' ', 'T');
      parsedDate = DateTime.tryParse(isoLike);
    }

    final participantsJson = (json['participants'] as List<dynamic>? ?? []);

    return MessageThread(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      participants: participantsJson
          .map((p) => Participant.fromJson(p as Map<String, dynamic>))
          .toList(),
      lastMessage: json['last_message'] as String?,
      lastMessageDate: parsedDate,

      // ✅ expecting backend provides this:
      lastMessageId: json['last_message_id'] as int?,

      unreadCount: (json['unread_count'] ?? 0) as int,
    );
  }
}

