import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:get_x_todo/ui/size_config.dart';
import 'package:get_x_todo/ui/theme.dart';

class InputField extends StatelessWidget {
  const InputField(
      {Key? key,
      required this.titel,
      this.controller,
      required this.hint,
      this.widget})
      : super(key: key);
  final String titel;
  final String hint;
  final TextEditingController? controller;
  final Widget? widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titel,
            style: titelStyel,
          ),
          Container(
            width: SizeConfig.screenWidth,
            height: 52,
            padding: const EdgeInsets.only(
              left: 14,
            ),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey)),
            child: Row(
              children: [
                Expanded(
                    child: TextFormField(
                  readOnly: widget != null ? true : false,
                  style: subTitelStyel,
                  cursorColor:
                      Get.isDarkMode ? Colors.grey[100] : Colors.grey[700],
                  controller: controller,
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: subTitelStyel,
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: context.theme.backgroundColor, width: 0)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: context.theme.backgroundColor)),
                  ),
                )),
                widget ?? Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
