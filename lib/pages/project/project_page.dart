import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../config/svgs.dart';
import '../../widgets/info_card.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: InfoCard(
          svg: SVGS.projectManagement,
          description: 'Elevate Your Workflow with PROJECTS: Kanban Boards at Your Fingertips',
          chipText: 'COMING SOON${kIsWeb ? ' TO WEB' : ''}',
        ),
      ),
    );
  }
}
