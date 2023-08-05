// ignore_for_file: public_member_api_docs, sort_constructors_first
class MessageModel {
  String? messageid;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdOn;
  MessageModel({
    required this.messageid,
    this.sender,
    this.text,
    this.seen,
    this.createdOn,
  });

  MessageModel.fromMap(Map<String, dynamic> map) {
    sender = map['sender'];
    text = map['text'];
    seen = map['seen'];
    createdOn = map['createdOn'].toDate();
    messageid = map['messageid'];
  }

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'text': text,
      'seen': seen,
      'createdOn': createdOn,
      'messageid': messageid
    };
  }
}
