import 'package:flutter/material.dart';

import '../../config/svgs.dart';
import '../../widgets/info_card.dart';

class SFTPPage extends StatefulWidget {
  const SFTPPage({super.key});

  @override
  State<SFTPPage> createState() => _SFTPPageState();
}

class _SFTPPageState extends State<SFTPPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: InfoCard(
          svg: SVGS.secureFiles,
          description: 'Seamless File Transfers: SFTP - Your Gateway to Effortless File Exchange',
          chipText: 'COMING SOON',
        ),
      ),
    );
  }
}
