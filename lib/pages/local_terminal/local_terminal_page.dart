import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../layout/device.dart';
import '../../reactive/providers/local_terminal_page_provider.dart';
import '../../widgets/ssh_terminal.dart';

class LocalTerminalPage extends StatefulWidget {
  const LocalTerminalPage({super.key});

  @override
  State<LocalTerminalPage> createState() => _LocalTerminalPageState();
}

class _LocalTerminalPageState extends State<LocalTerminalPage> {
  late LocalTerminalPageProvider _readLocalTerminalPageProvider;
  late int _counter;

  @override
  void initState() {
    _readLocalTerminalPageProvider = context.read<LocalTerminalPageProvider>();
    _readLocalTerminalPageProvider.activeTerminals.add(_localTerminal(key: 0, name: 'Terminal 1'));
    _counter = 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: Device.dockMargin(context)),
        padding: Device.isDesktop(context)
            ? EdgeInsets.fromLTRB(Device.column(context), 0, Device.column(context), Device.column(context))
            : EdgeInsets.all(Device.margin(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      ...context
                          .watch<LocalTerminalPageProvider>()
                          .activeTerminals
                          .asMap()
                          .map((index, value) => MapEntry(
                              index,
                              Container(
                                margin: EdgeInsets.only(right: Device.margin(context)),
                                child: InputChip(
                                  label: Text(value.name ?? (value.key as ValueKey).value),
                                  selected: index == _readLocalTerminalPageProvider.selectedTerminal,
                                  onSelected: (selected) {
                                    _readLocalTerminalPageProvider.selectedTerminal = index;
                                  },
                                  onDeleted: _readLocalTerminalPageProvider.activeTerminals.length == 1
                                      ? null
                                      : () {
                                          _readLocalTerminalPageProvider.activeTerminals
                                              .removeWhere((element) => (element.key as ValueKey<int>).value == (value.key as ValueKey<int>).value);
                                          _readLocalTerminalPageProvider.selectedTerminal = 0;
                                        },
                                ),
                              )))
                          .values
                          .toList()
                    ]),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final numberOfActiveTerminals = _readLocalTerminalPageProvider.activeTerminals.length;
                    _counter++;
                    _readLocalTerminalPageProvider.activeTerminals.add(_localTerminal(key: DateTime.now().millisecondsSinceEpoch, name: 'Terminal $_counter'));
                    _readLocalTerminalPageProvider.selectedTerminal = numberOfActiveTerminals;
                  },
                  icon: const Icon(Icons.add),
                  tooltip: 'New Local Terminal',
                )
              ],
            ),
            SizedBox(height: Device.margin(context)),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(kCardRadius))),
                clipBehavior: Clip.hardEdge,
                child: IndexedStack(
                  index: context.watch<LocalTerminalPageProvider>().selectedTerminal,
                  children: context.watch<LocalTerminalPageProvider>().activeTerminals,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SSHTerminal _localTerminal({required int key, required String name}) => SSHTerminal(
        onExit: (index) {},
        name: name,
        key: ValueKey(key),
      );
}
