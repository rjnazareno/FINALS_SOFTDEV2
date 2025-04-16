import 'package:flutter/material.dart';

class CustomTextFieldWidget extends StatelessWidget {
  final TextEditingController? editingController;
  final IconData? iconData;
  final String? assetRef;
  final String? labelText;
  final bool? isObscure;

  const CustomTextFieldWidget(
    this.editingController, {
    super.key,
    this.iconData,
    this.assetRef,
    this.labelText,
    this.isObscure, required bool isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: editingController,
      style: const TextStyle(
        color: Color.fromARGB(255, 68, 68, 68), 
        fontSize: 18,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: iconData != null
            ? Icon(iconData)
            : Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(assetRef.toString()),
              ),
        labelStyle: const TextStyle(
          fontSize: 20,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
      obscureText: isObscure ?? false,
    );
  }
}
