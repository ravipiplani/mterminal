import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:updat/updat.dart';

import '../models/release_info.dart';
import '../utilities/get_mterminal.dart';

class AppUpdateCard extends StatefulWidget {
  const AppUpdateCard({super.key});

  @override
  State<AppUpdateCard> createState() => _AppUpdateCardState();
}

class _AppUpdateCardState extends State<AppUpdateCard> {
  late Future<ReleaseInfo?> _futureReleaseInfo;
  late PackageInfo _packageInfo;

  @override
  void initState() {
    if (!kIsWeb) {
      _futureReleaseInfo = _getReleaseInfo();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? const SizedBox()
        : FutureBuilder<ReleaseInfo?>(
            future: _futureReleaseInfo,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                final releaseInfo = snapshot.data!;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    UpdatWidget(
                      openOnDownload: true,
                      currentVersion: _packageInfo.version,
                      getLatestVersion: () async {
                        return releaseInfo.version;
                      },
                      getBinaryUrl: (latestVersion) async {
                        return releaseInfo.binaryUrl;
                      },
                      appName: "mTerminal",
                      updateChipBuilder: updateChip,
                      closeOnInstall: true,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Current Version: ${_packageInfo.version}',
                      style: Theme.of(context).textTheme.labelSmall,
                    )
                  ],
                );
              }
              return const SizedBox();
            });
  }

  Future<ReleaseInfo?> _getReleaseInfo() async {
    _packageInfo = await PackageInfo.fromPlatform();
    final releaseInfo = await GetMterminal.releaseInfo();
    return releaseInfo;
  }

  Widget updateChip({
    required BuildContext context,
    required String? latestVersion,
    required String appVersion,
    required UpdatStatus status,
    required void Function() checkForUpdate,
    required void Function() openDialog,
    required void Function() startUpdate,
    required Future<void> Function() launchInstaller,
    required void Function() dismissUpdate,
  }) {
    if (UpdatStatus.available == status || UpdatStatus.availableWithChangelog == status) {
      return Tooltip(
        message: 'Update to version ${latestVersion!.toString()}',
        child: FilledButton.tonalIcon(
          onPressed: openDialog,
          icon: const Icon(Icons.system_update_alt_rounded),
          label: const Text('Update available'),
        ),
      );
    }

    if (UpdatStatus.downloading == status) {
      return Tooltip(
        message: 'Please Wait...',
        child: FilledButton.tonalIcon(
          onPressed: () {},
          icon: const SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
          label: const Text('Downloading...'),
        ),
      );
    }

    if (UpdatStatus.readyToInstall == status) {
      return Tooltip(
        message: 'Click to Install',
        child: FilledButton.tonalIcon(
          onPressed: launchInstaller,
          icon: const Icon(Icons.check_circle),
          label: const Text('Ready to install'),
        ),
      );
    }

    if (UpdatStatus.error == status) {
      return Tooltip(
        message: 'There was an issue with the update. Please try again.',
        child: FilledButton.tonalIcon(
          onPressed: startUpdate,
          icon: const Icon(Icons.warning),
          label: const Text('Error. Try Again.'),
        ),
      );
    }

    return Container();
  }
}
