// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class mytextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hinttext;
  final bool obscuretext;
  mytextfield({
    Key? key,
    required this.controller,
    required this.hinttext,
    required this.obscuretext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: controller,
        obscureText: obscuretext,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: hinttext,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(
                color: Colors.white,
              )),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.white)),
        ));
    ;
  }
}
