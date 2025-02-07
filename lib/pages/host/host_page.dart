import 'package:flutter/material.dart';
import 'package:modal_side_sheet/modal_side_sheet.dart';
import 'package:provider/provider.dart';
import 'package:xterm/ui.dart';

import '../../config/svgs.dart';
import '../../layout/device.dart';
import '../../models/host.dart';
import '../../reactive/providers/app_provider.dart';
import '../../services/host_service.dart';
import '../../utilities/helper.dart';
import '../../widgets/action_tile.dart';
import '../../widgets/info_card.dart';
import '../../widgets/plan_upgrade_card.dart';
import 'add_host.dart';

class HostPage extends StatefulWidget {
  const HostPage({super.key});

  @override
  State<HostPage> createState() => _HostPageState();
}

class _HostPageState extends State<HostPage> {
  late AppProvider _readAppProvider;
  late Future<List<Host>> _futureHosts;

  @override
  void initState() {
    _readAppProvider = context.read<AppProvider>();
    _futureHosts = _getHosts();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _refresh();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Device.isDesktop(context) && _readAppProvider.activeTerminals.isNotEmpty) _terminalNavigation(_readAppProvider),
                Expanded(
                    child: IndexedStack(
                  index: _readAppProvider.selectedTerminal != null
                      ? _readAppProvider.activeTerminals
                              .indexWhere((sshTerminal) => (sshTerminal.key as ValueKey<int>).value == _readAppProvider.selectedTerminal) +
                          1
                      : 0,
                  children: [_hosts, ...context.watch<AppProvider>().activeTerminals],
                )),
              ],
            ),
          ),
          if (!Device.isDesktop(context) && _readAppProvider.activeTerminals.isNotEmpty) _terminalPicker,
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _readAppProvider.selectedTerminal == null
          ? FloatingActionButton.extended(
              onPressed: () async {
                showModalSideSheet(
                    context: context,
                    width: Device.isMobile(context) ? Device.width(context) : null,
                    barrierDismissible: true,
                    withCloseControll: false,
                    body: AddHost(callback: _addHostCallback));
              },
              label: const Text('Add Host'),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget get _hosts {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(top: Device.dockMargin(context)),
        padding: Device.isDesktop(context) ? EdgeInsets.zero : EdgeInsets.all(Device.margin(context)),
        child: Device(
          child: FutureBuilder<List<Host>>(
              future: _futureHosts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.connectionState == ConnectionState.done && (!snapshot.hasData || snapshot.data!.isEmpty)) {
                  return const Center(
                      child: InfoCard(svg: SVGS.addTask, description: 'Seamless SSH Connections: Reach Remote Hosts with One Click using Hosts'));
                }
                final groupedHosts = snapshot.data!.groupBy((p0) => p0.tag?.name);
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: groupedHosts.keys.map((tagName) {
                      final hosts = groupedHosts[tagName];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                tagName != null ? '#$tagName' : 'Uncategorized',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              if (tagName != null)
                                Text(
                                  ' (Tag)',
                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.grey[500]),
                                ),
                            ],
                          ),
                          Wrap(
                            children: hosts!
                                .map((host) => Container(
                                      width: 360,
                                      margin: EdgeInsets.only(right: Device.margin(context), bottom: Device.margin(context)),
                                      child: ActionTile(
                                          title: host.name,
                                          subTitle: host.tag != null ? '#${host.tag!.name}' : '',
                                          leading: CircleAvatar(child: Text(host.name[0].toUpperCase())),
                                          actions: [
                                            IconButton(
                                                onPressed: () {
                                                  showModalSideSheet(
                                                      context: context,
                                                      width: Device.isMobile(context) ? Device.width(context) : null,
                                                      barrierDismissible: true,
                                                      withCloseControll: false,
                                                      body: AddHost(host: host, callback: _addHostCallback));
                                                },
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: Theme.of(context).disabledColor,
                                                ))
                                          ],
                                          trailingIcon: Icons.arrow_forward,
                                          onIconPressed: () {
                                            final hostConnected = Helper.activateTerminal(appProvider: _readAppProvider, host: host);
                                            if (!hostConnected) {
                                              _showConnectionLimitError;
                                            }
                                          }),
                                    ))
                                .toList(),
                          )
                        ],
                      );
                    }).toList(),
                  ),
                );
              }),
        ),
      ),
    );
  }

  Future<List<Host>> _getHosts() async {
    final hostService = HostService();
    final hosts = await hostService.get();
    return hosts;
  }

  void _addHostCallback(Host host) {
    _refresh();
  }

  void _refresh() {
    setState(() {
      _futureHosts = _getHosts();
    });
  }

  void get _showConnectionLimitError => showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: Icon(Icons.error, color: Theme.of(context).colorScheme.error),
          title: Text('Connection Limit'.toUpperCase()),
          content: const Text('On free plan, you can only connect to 2 remote servers at a time.'),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
                onPressed: () {
                  upgradePlan(context);
                },
                child: const Text('UPGRADE'))
          ],
        );
      });

  Widget _terminalNavigation(AppProvider appProvider) {
    return Container(
      width: 280,
      color: Colors.white.withOpacity(0.1),
      child: ListView(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: Device.column(context) / 2, horizontal: Device.margin(context) * 4),
            child: ElevatedButton(
                onPressed: () {
                  appProvider.selectedTerminal = null;
                },
                child: const Text('ALL HOSTS')),
          ),
          ...appProvider.activeTerminals.map((sshTerminal) {
            final index = (sshTerminal.key as ValueKey<int>).value;
            return ListTile(
              selectedTileColor: Colors.black,
              dense: true,
              selectedColor: TerminalThemes.whiteOnBlack.brightGreen,
              selected: appProvider.selectedTerminal == index,
              title: Text(sshTerminal.host?.name ?? sshTerminal.name ?? 'Local'),
              onTap: () {
                _readAppProvider.selectedNavigationRailIndex = null;
                _readAppProvider.selectedTerminal = index;
              },
              trailing: IconButton(
                  icon: Icon(Icons.close, size: Theme.of(context).textTheme.titleSmall!.fontSize),
                  onPressed: () {
                    _readAppProvider.selectedTerminal = null;
                    _readAppProvider.selectedNavigationRailIndex = 0;
                    _readAppProvider.activeTerminals.removeWhere((sshTerminal) => (sshTerminal.key as ValueKey<int>).value == index);
                  }),
            );
          }).toList()
        ],
      ),
    );
  }

  Widget get _terminalPicker {
    return SizedBox(
      width: Device.width(context),
      height: 34,
      child: Material(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: [
            InputChip(
                selected: context.watch<AppProvider>().selectedTerminal == null,
                label: const Icon(Icons.computer),
                shape: const RoundedRectangleBorder(side: BorderSide.none),
                side: BorderSide.none,
                onSelected: (value) {
                  _readAppProvider.selectedTerminal = null;
                }),
            ..._readAppProvider.activeTerminals.map((sshTerminal) {
              final index = (sshTerminal.key as ValueKey<int>).value;
              return InputChip(
                selected: context.watch<AppProvider>().selectedTerminal == index,
                label: Text(sshTerminal.host?.name ?? sshTerminal.name ?? 'Local'),
                onSelected: (bool value) {
                  if (value) {
                    _readAppProvider.selectedNavigationRailIndex = null;
                    _readAppProvider.selectedTerminal = index;
                  }
                },
                deleteButtonTooltipMessage: 'Disconnect',
                onDeleted: () {
                  _readAppProvider.selectedTerminal = null;
                  _readAppProvider.selectedNavigationRailIndex = 0;
                  _readAppProvider.activeTerminals.removeWhere((sshTerminal) => (sshTerminal.key as ValueKey<int>).value == index);
                },
                shape: const RoundedRectangleBorder(side: BorderSide.none),
                side: BorderSide.none,
              );
            }).toList()
          ],
        ),
      ),
    );
  }
}
