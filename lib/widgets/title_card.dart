import 'package:flutter/material.dart';

import '../layout/device.dart';

class TitleCard extends StatelessWidget {
  const TitleCard({super.key, required this.child, required this.title, this.color, this.desc, this.isDark = false, this.actions = const []});

  final String title;
  final String? desc;
  final List<Widget> actions;
  final Widget child;
  final Color? color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : null;
    return Card(
      color: color,
      child: Padding(
        padding: EdgeInsets.all(Device.margin(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, color: textColor),
                ),
                if (actions.isNotEmpty) ...[const Spacer(), ...actions]
              ],
            ),
            if (desc != null) Text(desc!, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: textColor)),
            SizedBox(height: Device.margin(context) / 2),
            child
          ],
        ),
      ),
    );
  }
}
