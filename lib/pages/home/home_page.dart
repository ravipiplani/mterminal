import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/keys.dart';
import '../../layout/device.dart';
import '../../reactive/providers/app_provider.dart';
import '../../widgets/gradient_container.dart';
import '../../widgets/installers.dart';
import '../features/features_page.dart';
import '../host/host_page.dart';
import '../setting/setting_page.dart';
import 'home.dart';
import 'installer_view.dart';

class ToolNavigationItem {
  ToolNavigationItem({required this.key, required this.label, required this.icon, this.color});

  final String key;
  final String label;
  final Icon icon;
  final Color? color;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.tab});

  final String tab;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AppProvider _watchAppProvider;
  late AppProvider _readAppProvider;
  final _toolsNavigationItems = <ToolNavigationItem>[
    ToolNavigationItem(key: Keys.home, icon: const Icon(Icons.home), label: 'HOME'),
    ToolNavigationItem(key: Keys.hosts, icon: const Icon(Icons.computer), label: 'HOSTS'),
    ToolNavigationItem(key: Keys.settings, icon: const Icon(Icons.settings), label: 'SETTINGS'),
    ToolNavigationItem(
        key: Keys.comingSoon,
        icon: const Icon(
          Icons.timer,
          color: Colors.green,
        ),
        label: 'COMING SOON',
        color: Colors.amber),
  ];
  final _navKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    _readAppProvider = context.read<AppProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _watchAppProvider = context.watch<AppProvider>();
    return GradientContainer(
      child: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Navigator(
              key: _navKey,
              initialRoute: widget.tab,
              onGenerateRoute: (settings) {
                late Widget page;
                if (settings.name == 'home') {
                  page = const Home();
                } else if (settings.name == 'hosts') {
                  page = kIsWeb ? const InstallerView(child: Installers()) : const HostPage();
                } else if (settings.name == 'settings') {
                  page = const SettingPage();
                } else if (settings.name == 'coming_soon') {
                  page = const FeaturesPage();
                } else {
                  throw Exception('Unknown route: ${settings.name}');
                }

                return PageRouteBuilder<dynamic>(
                  transitionDuration: const Duration(microseconds: 1000),
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return page;
                  },
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  settings: settings,
                );
              },
            ),
            _dock
          ],
        ),
      ),
    );
  }

  Widget get _dock => AnimatedPositioned(
        duration: const Duration(milliseconds: 400),
        curve: Curves.linearToEaseOut,
        width: Device.isMobile(context) ? Device.width(context) : null,
        top: !_watchAppProvider.isDockPinned && _watchAppProvider.isDockHidden
            ? Device.isMobile(context)
                ? -200
                : -100
            : _watchAppProvider.isDockCollapsed
                ? 2
                : Device.column(context),
        child: MouseRegion(
          onEnter: _watchAppProvider.isDockCollapsed && !_watchAppProvider.isDockPinned
              ? (event) {
                  _readAppProvider.isDockHidden = false;
                }
              : null,
          onExit: _watchAppProvider.isDockCollapsed && !_watchAppProvider.isDockPinned
              ? (event) {
                  _readAppProvider.isDockHidden = true;
                }
              : null,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(Device.margin(context)),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4), borderRadius: const BorderRadius.all(Radius.circular(8))),
                child: Wrap(
                  spacing: Device.margin(context),
                  runSpacing: Device.margin(context),
                  children: _toolsNavigationItems.map((tool) => _dockItem(tool)).toList(),
                ),
              ),
              if (_watchAppProvider.isDockCollapsed) ...[
                SizedBox(height: Device.margin(context) / 2),
                Tooltip(
                  message: _watchAppProvider.isDockPinned ? 'Unpin Dock' : 'Pin Dock',
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        _readAppProvider.isDockPinned = !_readAppProvider.isDockPinned;
                      },
                      child: SizedBox(
                        width: Device.margin(context) * 2,
                        child: Container(
                            height: Device.margin(context) / 2,
                            decoration: BoxDecoration(
                                color: _watchAppProvider.isDockPinned ? Colors.green.withOpacity(0.8) : Colors.white.withOpacity(0.8),
                                borderRadius: const BorderRadius.all(Radius.circular(8)))),
                      ),
                    ),
                  ),
                )
              ]
            ],
          ),
        ),
      );

  Widget _dockItem(ToolNavigationItem tool) {
    final isSelected = _watchAppProvider.selectedTool == tool.key;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          _readAppProvider.selectedTool = tool.key;
          _navKey.currentState!.pushReplacementNamed(tool.key);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              padding: EdgeInsets.all(Device.margin(context)),
              height: 60,
              width: 60,
              duration: const Duration(milliseconds: 400),
              curve: Curves.linearToEaseOut,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(isSelected ? 1 : 0.4),
                  borderRadius: const BorderRadius.all(Radius.circular(8))),
              child: tool.icon,
            ),
            const SizedBox(height: 4),
            Text(
              tool.label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            if (isSelected)
              const CircleAvatar(
                radius: 2,
                backgroundColor: Colors.black,
              )
          ],
        ),
      ),
    );
  }
}
