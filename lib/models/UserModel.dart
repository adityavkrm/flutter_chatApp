class UserModel {
  String? uid;
  String? fullName;
  String? email;
  String? profilepic;

  UserModel({
    this.uid,
    this.fullName,
    this.email,
    this.profilepic,
  });

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map['uid'];
    fullName = map['fullname'];
    email = map['email'];
    profilepic = map['profilepic'];
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullname': fullName,
      'email': email,
      'profilepic': profilepic
    };
  }
}
