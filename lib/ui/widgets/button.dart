import 'package:flutter/material.dart';
import 'package:get_x_todo/ui/theme.dart';

class MyButton extends StatelessWidget {
  const MyButton({Key? key, required this.label, required this.onTap})
      : super(key: key);
  final String label;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          alignment: Alignment.center,
          width: 100,
          height: 45,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: primaryClr),
        ),
      ),
    );
  }
}
