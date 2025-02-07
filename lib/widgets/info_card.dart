import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../layout/device.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.svg, required this.description, this.chipText});

  final String svg;
  final String description;
  final String? chipText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Device.margin(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.all(Device.margin(context) * 2),
              child: SvgPicture.asset(
                svg,
                width: Device.column(context) * 2,
              ),
            ),
          ),
          SizedBox(height: Device.margin(context) * 2),
          Text(description, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center,),
          SizedBox(height: Device.margin(context) * 2),
          if (chipText != null)
            FilterChip(
              label: Text(chipText!),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              selected: true,
              onSelected: (v) {},
              showCheckmark: false,
            )
        ],
      ),
    );
  }
}
