import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:chat_app/login_or_register.dart';
import 'package:chat_app/models/UserModel.dart';
import 'package:chat_app/models/firebase_helper.dart';
import 'package:chat_app/pages/home_page.dart';

import 'firebase_options.dart';

var uuid = Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    UserModel? myuserModel =
        await FirebaseHelper.getUserModelById(currentUser.uid);

    runApp(MyAppLoggedIn(userModel: myuserModel!, firebaseUser: currentUser));
  } else {
    runApp(MyApp());
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: LoginOrSignup(),
    );
  }
}

class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;
  const MyAppLoggedIn({
    Key? key,
    required this.userModel,
    required this.firebaseUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: HomePage(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}
