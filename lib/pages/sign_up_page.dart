import 'package:chat_app/models/UserModel.dart';
import 'package:chat_app/pages/complete_profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/components/customtextfield.dart';

class SignUpPage extends StatefulWidget {
  final Function() onTap;
  SignUpPage({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool isLoading = false;
  var emailTextController = TextEditingController();

  var passwordTextController = TextEditingController();

  var confirmPasswordTextController = TextEditingController();

  check() {
    String emailId = emailTextController.text.trim();
    String pass = passwordTextController.text.trim();
    String confirmPass = confirmPasswordTextController.text.trim();

    if (emailId == '' || pass == '' || confirmPass == '') {
      return ScaffoldMessenger.of(context)
          .showSnackBar(mySnackBar('Empty fields !'));
    } else if (pass != confirmPass) {
      return ScaffoldMessenger.of(context)
          .showSnackBar(mySnackBar('Passwords do not match !'));
    } else if (!emailId.contains('@')) {
      return ScaffoldMessenger.of(context)
          .showSnackBar(mySnackBar('Invalid email'));
    } else {
      signUp(emailId, pass);
    }
  }

  signUp(String email, String password) async {
    UserCredential? credential;
    setState(() {
      isLoading = true;
    });

    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseException catch (ex) {
      return ScaffoldMessenger.of(context)
          .showSnackBar(mySnackBar(ex.message.toString()));
    }

    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser =
          UserModel(uid: uid, email: email, fullName: '', profilepic: '');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(newUser.toMap())
          .then((value) {
        print('new user created !');
        Navigator.pushReplacement(context,
            CupertinoPageRoute(builder: (context) {
          return CompleteProfile(
              userModel: newUser, firebaseUser: credential!.user!);
        }));
      });

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
                          height: 60,
                        ),
                        const Icon(Icons.lock, size: 100),

                        const SizedBox(
                          height: 20,
                        ),
                        //welcome text
                        const Text(
                          "Create account",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 40,
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
                          height: 13,
                        ),
                        //password
                        mytextfield(
                            controller: confirmPasswordTextController,
                            hinttext: 'Confirm Password',
                            obscuretext: true),

                        const SizedBox(
                          height: 20,
                        ),

                        Container(
                          width: double.infinity,
                          height: 60,
                          child: CupertinoButton(
                              color: Colors.black,
                              child: Text(
                                'Sign Up',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: (isLoading) ? null : check),
                        ),

                        const SizedBox(
                          height: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already a Member?',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            GestureDetector(
                              onTap: widget.onTap,
                              child: const Text(
                                'Log in',
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
