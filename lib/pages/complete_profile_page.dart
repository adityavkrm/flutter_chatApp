import 'dart:io';
import 'package:chat_app/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:chat_app/components/customtextfield.dart';
import 'package:chat_app/models/UserModel.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  CompleteProfile({
    Key? key,
    required this.userModel,
    required this.firebaseUser,
  }) : super(key: key);

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  bool isLoading = false;
  var fullNameController = TextEditingController();

  File? imageFile;

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    var croppedImage = await ImageCropper().cropImage(
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 20,
        sourcePath: file.path);

    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void showPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Upload Profile picture'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                onTap: () {
                  selectImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
                leading: Icon(Icons.photo_library),
                title: Text('Select from Gallery'),
              ),
              ListTile(
                onTap: () {
                  selectImage(ImageSource.camera);
                  Navigator.pop(context);
                },
                leading: Icon(Icons.camera),
                title: Text('Take a photo'),
              ),
            ]),
          );
        });
  }

  check() {
    String fullname = fullNameController.text.trim();
    if (fullname == '' || imageFile == null) {
      return ScaffoldMessenger.of(context)
          .showSnackBar(mySnackBar('Both fields are mandatory!'));
    } else {
      uploadData();
    }
  }

  uploadData() async {
    setState(() {
      isLoading = true;
    });
    var uploadTaskSnapshot = await FirebaseStorage.instance
        .ref('profilepictures')
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);

    String imageUrl = await uploadTaskSnapshot.ref.getDownloadURL();

    widget.userModel.fullName = fullNameController.text.trim();
    widget.userModel.profilepic = imageUrl;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) {
      print('data updated');
      Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) {
        return HomePage(
            userModel: widget.userModel, firebaseUser: widget.firebaseUser);
      }));
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Complete Profile'),
        centerTitle: true,
      ),
      body: (isLoading)
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  children: [
                    CupertinoButton(
                      onPressed: showPhotoOptions,
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.8),
                        radius: 80,
                        backgroundImage:
                            (imageFile != null) ? FileImage(imageFile!) : null,
                        child: (imageFile == null)
                            ? const Icon(
                                Icons.add_a_photo_rounded,
                                size: 50,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    TextField(
                      controller: fullNameController,
                      decoration: InputDecoration(
                        fillColor: Colors.black.withOpacity(0.07),
                        filled: true,
                        hintText: 'Full name',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity,
                      height: 63,
                      child: CupertinoButton(
                          color: Colors.black,
                          child: const Text(
                            'Submit',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: (isLoading) ? null : check),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  SnackBar mySnackBar(String text) {
    return SnackBar(duration: Duration(seconds: 2), content: Text(text));
  }
}
