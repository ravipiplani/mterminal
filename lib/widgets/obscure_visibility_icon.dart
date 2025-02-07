import 'package:flutter/material.dart';

class ObscureVisibilityIcon extends StatefulWidget {
  const ObscureVisibilityIcon({super.key, required this.isObscure, required this.onPressed});

  final bool isObscure;
  final VoidCallback onPressed;

  @override
  State<ObscureVisibilityIcon> createState() => _ObscureVisibilityIconState();
}

class _ObscureVisibilityIconState extends State<ObscureVisibilityIcon> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Icon(widget.isObscure ? Icons.visibility_off : Icons.visibility),
        ));
  }
}
