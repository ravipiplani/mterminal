import 'package:flutter/material.dart';

import '../../config/svgs.dart';
import '../../widgets/info_card.dart';

class ShortcutPage extends StatefulWidget {
  const ShortcutPage({super.key});

  @override
  State<ShortcutPage> createState() => _ShortcutPageState();
}

class _ShortcutPageState extends State<ShortcutPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: InfoCard(
          svg: SVGS.shortcut,
          description: 'Unlock Efficiency with SHORTCUTS: One-Click Script Execution on Remote Servers',
          chipText: 'COMING SOON',
        ),
      ),
    );
  }
}
