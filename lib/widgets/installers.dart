import 'package:flutter/material.dart';

import '../models/release_info.dart';
import '../utilities/get_mterminal.dart';
import '../utilities/helper.dart';
import 'title_card.dart';

class Installers extends StatefulWidget {
  const Installers({super.key});

  @override
  State<Installers> createState() => _InstallersState();
}

class _InstallersState extends State<Installers> {
  late Future<ReleaseInfo?> _futureReleaseInfo;

  @override
  void initState() {
    _futureReleaseInfo = GetMterminal.releaseInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TitleCard(
        title: 'Installers',
        child: FutureBuilder<ReleaseInfo?>(
            future: _futureReleaseInfo,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                final releaseInfo = snapshot.data!;
                return ListTile(
                  leading: const Icon(Icons.install_desktop),
                  title: Text('${releaseInfo.platform.name} Installer'),
                  subtitle: Text(releaseInfo.version),
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () {
                      Helper.openUrl(url: releaseInfo.binaryUrl);
                    },
                  ),
                );
              }
              return Container();
            }));
  }
}
