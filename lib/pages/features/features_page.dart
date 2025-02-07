import 'package:flutter/material.dart';

import '../../config/keys.dart';
import '../../layout/device.dart';
import '../../utilities/get_mterminal.dart';

class FeaturesPage extends StatefulWidget {
  const FeaturesPage({super.key});

  @override
  State<FeaturesPage> createState() => _FeaturesPageState();
}

class _FeaturesPageState extends State<FeaturesPage> {
  late List _features;

  @override
  Widget build(BuildContext context) {
    _features = GetMterminal.comingSoon();
    return Scaffold(
        body: Container(
      margin: EdgeInsets.only(top: Device.dockMargin(context)),
      padding: Device.isDesktop(context) ? EdgeInsets.zero : EdgeInsets.all(Device.margin(context)),
      child: Device(
        child: ListView(
            children: _features
                .map((e) => Card(
                        child: ListTile(
                      title: Text(e[Keys.title]),
                      subtitle: Text(e[Keys.description]),
                    )))
                .toList()),
      ),
    ));
  }
}
