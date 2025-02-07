import 'package:flutter/material.dart';

import '../layout/device.dart';

class ActionTile extends StatelessWidget {
  const ActionTile(
      {super.key,
      required this.title,
      required this.subTitle,
      required this.leading,
      required this.trailingIcon,
      this.actions = const [],
      this.onIconPressed,
      this.onDoubleTap,
      this.onTap});

  final String title;
  final String subTitle;
  final Widget leading;
  final IconData trailingIcon;
  final List<Widget> actions;
  final VoidCallback? onIconPressed;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: onDoubleTap,
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                  child: ListTile(
                title: Text(title),
                subtitle: Text(subTitle),
                leading: leading,
              )),
              if (actions.isNotEmpty) ...[...actions, SizedBox(width: Device.margin(context))],
              Container(
                color: Theme.of(context).colorScheme.primary,
                padding: EdgeInsets.symmetric(horizontal: Device.margin(context)),
                child: IconButton(icon: Icon(trailingIcon, color: Colors.white), onPressed: onIconPressed),
              )
            ],
          ),
        ),
      ),
    );
  }
}
