import 'package:flutter/cupertino.dart';

import '../../config/keys.dart';
import '../../utilities/preferences.dart';
import '../../widgets/ssh_terminal.dart';

class AppProvider extends ChangeNotifier {
  int? _selectedNavigationRailIndex = 0;
  List<SSHTerminal> _activeTerminals = [];
  int? _selectedTerminal;
  String _selectedTool = 'home';
  bool _isDockCollapsed = true;
  bool _isDockHidden = false;

  int? get selectedNavigationRailIndex => _selectedNavigationRailIndex;

  List<SSHTerminal> get activeTerminals => _activeTerminals;

  int? get selectedTerminal => _selectedTerminal;

  String get selectedTool => _selectedTool;

  bool get isDockCollapsed => _isDockCollapsed;

  bool get isDockHidden => _isDockHidden;

  bool get isDockPinned => Preferences.getBool(Keys.isDockPinned) ?? true;

  bool get isLoggedIn => Preferences.containsKey(Keys.accessToken) && Preferences.getString(Keys.accessToken).isNotEmpty;

  DateTime get planEndDate => DateTime.now().add(const Duration(days: 14));

  set selectedNavigationRailIndex(int? value) {
    _selectedNavigationRailIndex = value;
    notifyListeners();
  }

  set activeTerminals(List<SSHTerminal> value) {
    _activeTerminals = value;
    notifyListeners();
  }

  set selectedTerminal(int? value) {
    _selectedTerminal = value;
    notifyListeners();
  }

  set selectedTool(String value) {
    _selectedTool = value;
    notifyListeners();
  }

  set isDockCollapsed(bool value) {
    _isDockCollapsed = value;
    notifyListeners();
  }

  set isDockHidden(bool value) {
    _isDockHidden = value;
    notifyListeners();
  }

  set isDockPinned(bool value) {
    Preferences.setBool(Keys.isDockPinned, value);
    notifyListeners();
  }
}
