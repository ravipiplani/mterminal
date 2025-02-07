import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../config/svgs.dart';
import '../../widgets/info_card.dart';

class HTTPPage extends StatefulWidget {
  const HTTPPage({super.key});

  @override
  State<HTTPPage> createState() => _HTTPPageState();
}

class _HTTPPageState extends State<HTTPPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: InfoCard(
          svg: SVGS.serverCluster,
          description: 'Elevate API Testing with HTTP: Your Gateway to RESTful Efficiency',
          chipText: 'COMING SOON${kIsWeb ? ' TO WEB' : ''}',
        ),
      ),
    );
  }
}
