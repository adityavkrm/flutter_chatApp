// ignore_for_file: public_member_api_docs, sort_constructors_first
class ChatRoomModel {
  String? chatroomid;
  Map<String, dynamic>? participants;
  String? lastMessage;

  ChatRoomModel({
    required this.chatroomid,
    required this.participants,
    required this.lastMessage,
  });

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    this.chatroomid = map['chatroomid'];
    this.participants = map['participants'];
    this.lastMessage = map['lastMessage'];
  }

  Map<String, dynamic> toMap() {
    return {
      'chatroomid': chatroomid,
      'participants': participants,
      'lastMessage': lastMessage
    };
  }
}
