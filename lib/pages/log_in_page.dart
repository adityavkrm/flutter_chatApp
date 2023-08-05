import 'package:chat_app/models/UserModel.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/components/customtextfield.dart';

class LogInPage extends StatefulWidget {
  final Function() onTap;
  LogInPage({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  var emailTextController = TextEditingController();
  var passwordTextController = TextEditingController();

  bool isLoading = false;

  check() {
    String email = emailTextController.text.trim();
    String password = passwordTextController.text.trim();

    if (email == '' || password == '') {
      return ScaffoldMessenger.of(context)
          .showSnackBar(mySnackBar('Fields empty!'));
    } else {
      logIn(email, password);
    }
  }

  logIn(String email, String password) async {
    UserCredential? credential;

    setState(() {
      isLoading = true;
    });

    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseException catch (ex) {
      return ScaffoldMessenger.of(context)
          .showSnackBar(mySnackBar(ex.code.toString()));
    }

    if (credential != null) {
      String uid = credential.user!.uid;

      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);

      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) {
        return HomePage(userModel: userModel, firebaseUser: credential!.user!);
      }));
      emailTextController.clear();
      passwordTextController.clear();
      print('login successful');

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade200,
        body: (isLoading)
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              )
            : SingleChildScrollView(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 70,
                        ),
                        const Icon(Icons.lock, size: 100),

                        const SizedBox(
                          height: 20,
                        ),
                        //welcome text
                        const Text(
                          "Welcome Back!",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 50,
                        ),

                        //email
                        mytextfield(
                            controller: emailTextController,
                            hinttext: 'Email',
                            obscuretext: false),

                        const SizedBox(
                          height: 13,
                        ),
                        //password
                        mytextfield(
                            controller: passwordTextController,
                            hinttext: 'Password',
                            obscuretext: true),

                        const SizedBox(
                          height: 20,
                        ),

                        Container(
                          width: double.infinity,
                          height: 60,
                          child: CupertinoButton(
                              color: Colors.black,
                              child: const Text(
                                'Log in',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: (isLoading) ? null : check),
                        ),

                        SizedBox(
                          height: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Not a Member?',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            GestureDetector(
                              onTap: widget.onTap,
                              child: Text(
                                'Sign up',
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        )
                        //go to register page
                      ],
                    ),
                  ),
                ),
              ));
  }

  SnackBar mySnackBar(String text) {
    return SnackBar(duration: Duration(seconds: 2), content: Text(text));
  }
}
