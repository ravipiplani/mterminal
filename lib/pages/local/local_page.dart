import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:provider/provider.dart';
import 'package:xterm/xterm.dart';

import '../../layout/device.dart';
import '../../reactive/providers/app_provider.dart';

class LocalPage extends StatefulWidget {
  const LocalPage({super.key});

  @override
  State<LocalPage> createState() => _LocalPageState();
}

class _LocalPageState extends State<LocalPage> {
  final terminal = Terminal(
    maxLines: 10000,
  );

  final _terminalController = TerminalController();

  late final Pty pty;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.endOfFrame.then(
      (_) {
        if (mounted) {
          _startPty();
        }
      },
    );
  }

  void _startPty() {
    pty = Pty.start(shell, columns: terminal.viewWidth, rows: terminal.viewHeight, arguments: []);

    pty.output.cast<List<int>>().transform(const Utf8Decoder()).listen(terminal.write);

    pty.exitCode.then((code) {
      context.read<AppProvider>().selectedNavigationRailIndex = 0;
    });

    terminal.onOutput = (data) {
      pty.write(const Utf8Encoder().convert(data));
    };

    // pty.write(const Utf8Encoder().convert('fish\n'));

    terminal.onResize = (w, h, pw, ph) {
      pty.resize(h, w);
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: TerminalView(
        terminal,
        controller: _terminalController,
        autofocus: true,
        theme: TerminalThemes.whiteOnBlack,
        padding: EdgeInsets.all(Device.margin(context) / 2),
        onSecondaryTapDown: (details, offset) async {
          final selection = _terminalController.selection;
          if (selection != null) {
            final text = terminal.buffer.getText(selection);
            _terminalController.clearSelection();
            await Clipboard.setData(ClipboardData(text: text));
          } else {
            final data = await Clipboard.getData('text/plain');
            final text = data?.text;
            if (text != null) {
              terminal.paste(text);
            }
          }
        },
      ),
    );
  }
}

String get shell {
  if (Platform.isMacOS || Platform.isLinux) {
    return Platform.environment['SHELL'] ?? 'bash';
  }

  if (Platform.isWindows) {
    return 'cmd.exe';
  }

  return 'sh';
}
