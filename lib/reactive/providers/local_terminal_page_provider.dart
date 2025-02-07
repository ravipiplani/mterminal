import 'package:flutter/material.dart';

import '../../widgets/ssh_terminal.dart';

class LocalTerminalPageProvider with ChangeNotifier {
  List<SSHTerminal> _activeTerminals = <SSHTerminal>[];
  int _selectedTerminal = 0;

  List<SSHTerminal> get activeTerminals => _activeTerminals;

  int get selectedTerminal => _selectedTerminal;

  set selectedTerminal(int value) {
    _selectedTerminal = value;
    notifyListeners();
  }

  set activeTerminals(List<SSHTerminal> value) {
    _activeTerminals = value;
    notifyListeners();
  }
}
