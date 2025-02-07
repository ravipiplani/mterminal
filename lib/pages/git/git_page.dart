import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../config/svgs.dart';
import '../../widgets/info_card.dart';

class GITPage extends StatefulWidget {
  const GITPage({super.key});

  @override
  State<GITPage> createState() => _GITPageState();
}

class _GITPageState extends State<GITPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: InfoCard(
          svg: SVGS.versionControl,
          description: 'Streamline Your Git Journey: GIT - Navigate Pull Requests and Commits with Ease',
          chipText: 'COMING SOON${kIsWeb ? ' TO WEB' : ''}',
        ),
      ),
    );
  }
}
