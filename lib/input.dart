import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final String hint;
  final InputBorder? inputBorder;
  final TextEditingController controller;
  final int maxLine;
  CustomInput({Key? key, this.onChanged, required this.hint, this.inputBorder, required this.controller, this.maxLine=1})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hint),
          SizedBox(height: 10),
          TextField(
            controller: controller,
            keyboardType: maxLine > 1 ? TextInputType.multiline : TextInputType.text,
            decoration: InputDecoration(
                hintText: hint,
                contentPadding: EdgeInsets.all(10),
                border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }
}
