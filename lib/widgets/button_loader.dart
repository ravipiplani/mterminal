import 'package:flutter/material.dart';

import '../config/constants.dart';

class ButtonLoader extends StatefulWidget {
  const ButtonLoader({Key? key, required this.child, required this.isLoading, this.width = double.infinity}) : super(key: key);

  final Widget child;
  final bool isLoading;
  final double width;

  @override
  State<ButtonLoader> createState() => _ButtonLoaderState();
}

class _ButtonLoaderState extends State<ButtonLoader> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [SizedBox(width: double.infinity, child: widget.child), if (widget.isLoading) _loader],
      ),
    );
  }

  Widget get _loader {
    return Container(
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(kButtonRadius), bottomRight: Radius.circular(kButtonRadius))),
        child: const LinearProgressIndicator());
  }
}
