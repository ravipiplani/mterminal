import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/colors.dart';
import '../../layout/device.dart';
import '../../reactive/providers/app_provider.dart';
import '../../utilities/analytics.dart';
import '../../widgets/app_update_card.dart';
import '../../widgets/login_card.dart';
import '../../widgets/logo.dart';
import '../../widgets/plan_upgrade_card.dart';
import '../account/account_page.dart';
import '../billing/billing_page.dart';
import '../credential/credential_page.dart';
import '../team/team_page.dart';

class NavigationItem {
  NavigationItem({required this.icon, required this.label});

  final Icon icon;
  final String label;
}

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late AppProvider _readAppProvider;
  late AppProvider _watchAppProvider;
  late List<NavigationItem> _navigationMenu;
  late List<NavigationRailDestination> _navigationRailDestinations;
  late List<Widget> _destinations;
  late bool _isLoggedIn;
  late int _selectedNavigationRailIndex;

  @override
  void initState() {
    _readAppProvider = context.read<AppProvider>();
    _selectedNavigationRailIndex = 0;
    _isLoggedIn = _readAppProvider.isLoggedIn;
    _navigationMenu = <NavigationItem>[
      if (_isLoggedIn) ...[
        NavigationItem(icon: const Icon(Icons.verified_user), label: 'Account'),
        NavigationItem(icon: const Icon(Icons.people), label: 'Team'),
        NavigationItem(icon: const Icon(Icons.credit_card), label: 'Billing')
      ],
      if (!kIsWeb) ...[
        NavigationItem(icon: const Icon(Icons.key), label: 'Credentials'),
      ],
    ];
    _navigationRailDestinations = <NavigationRailDestination>[
      if (_isLoggedIn) ...[
        const NavigationRailDestination(icon: Icon(Icons.verified_user), label: Text('Account')),
        const NavigationRailDestination(icon: Icon(Icons.people), label: Text('Team')),
        const NavigationRailDestination(icon: Icon(Icons.credit_card), label: Text('Billing'))
      ],
      if (!kIsWeb) ...[
        const NavigationRailDestination(icon: Icon(Icons.key), label: Text('Credentials')),
      ],
    ];
    _destinations = <Widget>[
      if (_isLoggedIn) ...[const AccountPage(), const TeamPage(), const BillingPage()],
      if (!kIsWeb) ...[const CredentialPage()],
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _watchAppProvider = context.watch<AppProvider>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_watchAppProvider.isLoggedIn)
          Expanded(
            child: Row(
              children: [
                if (Device.isDesktop(context))
                  SizedBox(
                    width: Device.isDesktop(context) ? 280 : 80,
                    child: _navigationRail,
                  ),
                Expanded(
                  flex: 4,
                  child: Scaffold(
                    body: Container(margin: EdgeInsets.only(top: Device.dockMargin(context)), child: _destinations[_selectedNavigationRailIndex]),
                    bottomNavigationBar: Device.isDesktop(context) ? null : _bottomNavigationBar,
                  ),
                )
              ],
            ),
          )
        else
          const Center(child: LoginCard()),
      ],
    );
  }

  Widget get _navigationRail {
    return NavigationRail(
      extended: Device.isDesktop(context),
      useIndicator: true,
      backgroundColor: Colors.white.withOpacity(0.1),
      selectedLabelTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      leading: Padding(
        padding: EdgeInsets.symmetric(horizontal: Device.margin(context)),
        child: Column(
          children: [
            SizedBox(height: Device.margin(context)),
            Logo(onlyIcon: Device.isMobile(context)),
            SizedBox(height: Device.margin(context)),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Chip(
            //       label: Text(GetMterminal.selectedTeam().name),
            //     ),
            //     IconButton(
            //       onPressed: () {
            //         showTeamChangeDialog(context);
            //       },
            //       icon: const Icon(Icons.change_circle_outlined),
            //       tooltip: 'Change Team',
            //     )
            //   ],
            // ),
            const AppUpdateCard(),
            Padding(
              padding: EdgeInsets.only(top: Device.margin(context), bottom: Device.margin(context) * 2),
              child: Divider(
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
            ),
          ],
        ),
      ),
      destinations: _navigationRailDestinations,
      selectedIndex: _selectedNavigationRailIndex,
      onDestinationSelected: (index) {
        Analytics.logButton(name: (_navigationRailDestinations[index].label as Text).data ?? index.toString());
        setState(() {
          _selectedNavigationRailIndex = index;
        });
      },
      trailing: const PlanUpgradeCard(),
    );
  }

  Widget get _bottomNavigationBar => Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.5, 0.9],
          colors: [
            kPrimaryLight,
            kTertiaryLight,
          ],
        )),
        child: BottomNavigationBar(
          currentIndex: _selectedNavigationRailIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            Analytics.logButton(name: _navigationMenu[index].label);
            setState(() {
              _selectedNavigationRailIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Theme.of(context).colorScheme.outlineVariant,
          selectedIconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.secondaryContainer,
          ),
          unselectedIconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: _navigationMenu
              .map((menuItem) => BottomNavigationBarItem(icon: menuItem.icon, label: menuItem.label, backgroundColor: Colors.transparent))
              .toList(),
        ),
      );
}
