import 'package:flutter_pty/flutter_pty.dart';

Pty ptyStart(String shell, {required int columns, required int rows, String? workingDirectory, required List<String> arguments}) {
  return Pty.start(shell, columns: columns, rows: rows, workingDirectory: workingDirectory, arguments: arguments);
}