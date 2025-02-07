import 'dart:convert';
import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_side_sheet/modal_side_sheet.dart';
import 'package:provider/provider.dart';
import 'package:xterm/xterm.dart';

import '../config/color_schemes.g.dart';
import '../config/lottie_files.dart';
import '../layout/device.dart';
import '../models/exceptions/no_key_found_exception.dart';
import '../models/host.dart';
import '../pages/host/add_host.dart';
import '../reactive/providers/app_provider.dart';
import '../utilities/helper.dart';
import 'platform_impl/flutter_pty/flutter_pty_stub.dart'
    if (dart.library.io) 'platform_impl/flutter_pty/flutter_pty_mobile.dart'
    if (dart.library.js) 'platform_impl/flutter_pty/flutter_pty_web.dart';

enum SSHConnectionState { connecting, connected, disconnected, noKeyAvailable, failed }

class LoggingShortcutManager extends ShortcutManager {
  @override
  KeyEventResult handleKeypress(BuildContext context, RawKeyEvent event) {
    final KeyEventResult result = super.handleKeypress(context, event);
    if (result == KeyEventResult.handled) {
      debugPrint('Handled shortcut $event in $context');
    }
    return result;
  }
}

/// An ActionDispatcher that logs all the actions that it invokes.
class LoggingActionDispatcher extends ActionDispatcher {
  @override
  Object? invokeAction(
    covariant Action<Intent> action,
    covariant Intent intent, [
    BuildContext? context,
  ]) {
    debugPrint('Action invoked: $action($intent) from $context');
    super.invokeAction(action, intent, context);

    return null;
  }
}

class CloseTerminalIntent extends Intent {
  const CloseTerminalIntent();
}

class CloseTerminalAction extends Action<CloseTerminalIntent> {
  CloseTerminalAction(this.appProvider, this.terminalIndex);

  final AppProvider appProvider;
  final int terminalIndex;

  @override
  Object? invoke(covariant CloseTerminalIntent intent) {
    appProvider.selectedTerminal = null;
    appProvider.selectedNavigationRailIndex = 0;
    appProvider.activeTerminals.removeWhere((sshTerminal) => (sshTerminal.key as ValueKey<int>).value == terminalIndex);

    return null;
  }
}

class SSHTerminal extends StatefulWidget {
  const SSHTerminal({super.key, this.host, this.name, required this.onExit});

  final Host? host;
  final String? name;
  final Function(int) onExit;

  @override
  State<SSHTerminal> createState() => _SSHTerminalState();
}

class _SSHTerminalState extends State<SSHTerminal> with AutomaticKeepAliveClientMixin<SSHTerminal> {
  late final terminal = Terminal();
  final _terminalController = TerminalController();
  final _connectionState = ValueNotifier<SSHConnectionState>(SSHConnectionState.connecting);
  late SocketException _socketException;
  late AppProvider _readAppProvider;
  late int _terminalIndex;

  @override
  void initState() {
    super.initState();
    final key = widget.key as ValueKey<int>;
    _terminalIndex = key.value;
    _readAppProvider = context.read<AppProvider>();
    if (mounted) {
      _initTerminal(widget.host);
    }
  }

  Future<void> _initTerminal(Host? host) async {
    try {
      _connectionState.value == SSHConnectionState.connecting;
      if (host != null) {
        if (host.credential != null) {
          final pemIdentity = SSHKeyPair.fromPem(host.credential!.privateKey!);
          final client = SSHClient(await SSHSocket.connect(host.address, host.port), username: host.username, identities: pemIdentity);
          final session = await client.shell(
            pty: SSHPtyConfig(
              width: terminal.viewWidth,
              height: terminal.viewHeight,
            ),
          );
          session.done.whenComplete(() {
            widget.onExit(_terminalIndex);
          });
          terminal.onResize = (width, height, pixelWidth, pixelHeight) {
            session.resizeTerminal(width, height, pixelWidth, pixelHeight);
          };
          terminal.onOutput = (data) {
            session.write(utf8.encode(data));
          };
          session.stdout.cast<List<int>>().transform(const Utf8Decoder()).listen(terminal.write);
          session.stderr.cast<List<int>>().transform(const Utf8Decoder()).listen(terminal.write);
        } else {
          throw NoKeyFoundException();
        }
      } else {
        final pty = ptyStart(
          shell,
          columns: terminal.viewWidth,
          rows: terminal.viewHeight,
          workingDirectory: Helper.getHomeDirectoryPath(),
          arguments: [],
        );
        pty.output.cast<List<int>>().transform(const Utf8Decoder()).listen(terminal.write);
        pty.exitCode.then((code) {
          widget.onExit(_terminalIndex);
        });
        terminal.onResize = (width, height, pixelWidth, pixelHeight) {
          pty.resize(height, width);
        };
        terminal.onOutput = (data) {
          pty.write(const Utf8Encoder().convert(data));
        };
      }

      terminal.buffer.clear();
      terminal.buffer.setCursor(0, 0);

      _connectionState.value = SSHConnectionState.connected;
    } on NoKeyFoundException {
      _connectionState.value = SSHConnectionState.noKeyAvailable;
    } on SocketException catch (e) {
      _socketException = e;
      _connectionState.value = SSHConnectionState.failed;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _body;
  }

  @override
  bool get wantKeepAlive => true;

  Widget get _body {
    return ValueListenableBuilder(
        valueListenable: _connectionState,
        builder: (context, connectionState, child) {
          if (connectionState == SSHConnectionState.connecting) {
            return _inProgressIndicator;
          } else if (connectionState == SSHConnectionState.noKeyAvailable) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.host?.name ?? '',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'No credentials are mapped to this host. Update credential to connect.',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onErrorContainer),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Device.margin(context)),
                  FilledButton.tonal(
                      onPressed: () {
                        showModalSideSheet(
                            context: context,
                            width: Device.isMobile(context) ? Device.width(context) : null,
                            barrierDismissible: true,
                            withCloseControll: false,
                            body: AddHost(host: widget.host, callback: _initTerminal));
                      },
                      child: const Text('Update Credential')),
                ],
              ),
            );
          } else if (connectionState == SSHConnectionState.failed) {
            final errorCode = _socketException.osError?.errorCode;
            var message = 'Failed to connect.';
            if (errorCode == 51) {
              message = 'Please check your internet connection.';
            }
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.close,
                  color: Colors.red,
                ),
                Text(message),
              ],
            ));
          } else {
            return Actions(
                dispatcher: LoggingActionDispatcher(),
                actions: <Type, Action<Intent>>{
                  CloseTerminalIntent: CloseTerminalAction(_readAppProvider, _terminalIndex),
                },
                child: _terminalView);
          }
        });
  }

  Widget get _inProgressIndicator => Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(LottieFiles.connectingDots),
          Text('Connecting', style: Theme.of(context).textTheme.headlineMedium),
          if (widget.host != null) Text(widget.host!.name, style: Theme.of(context).textTheme.titleSmall)
        ],
      ));

  Widget get _terminalView => TerminalView(
        terminal,
        controller: _terminalController,
        autofocus: true,
        theme: terminalWhiteOnBlack,
        padding: EdgeInsets.all(Device.margin(context) / 2),
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyW): const CloseTerminalIntent(),
        },
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
      );

  String get shell {
    if (Platform.isMacOS || Platform.isLinux) {
      return Platform.environment['SHELL'] ?? 'bash';
    }
    if (Platform.isWindows) {
      return 'cmd.exe';
    }
    return 'sh';
  }
}
