import 'package:flutter/material.dart';

class MyTextFormField extends StatelessWidget {
  final String hintText;
  final void Function(String?)? onSaved;
  final _keyForm = GlobalKey<FormState>();

  MyTextFormField({
    Key? key,
    required this.hintText,
    required this.onSaved,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
        key: key,
        padding: EdgeInsets.all(8.0),
        child: SizedBox(
            width: 300,
            child: TextFormField(
              decoration: InputDecoration(
                hintText: hintText,
                contentPadding: EdgeInsets.all(15.0),
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.grey[200],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              onSaved: onSaved,
            )));
  }
}