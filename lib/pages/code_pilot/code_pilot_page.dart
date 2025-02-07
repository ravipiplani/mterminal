import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../config/svgs.dart';
import '../../widgets/info_card.dart';

class CodePilotPage extends StatefulWidget {
  const CodePilotPage({super.key});

  @override
  State<CodePilotPage> createState() => _CodePilotPageState();
}

class _CodePilotPageState extends State<CodePilotPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: InfoCard(
          svg: SVGS.ai,
          description: 'Navigate Code Challenges with CODE PILOT: Your AI Co-Pilot for Problem Solving',
          chipText: 'COMING SOON${kIsWeb ? ' TO WEB' : ''}',
        ),
      ),
    );
  }
}
