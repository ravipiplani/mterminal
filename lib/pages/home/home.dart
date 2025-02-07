import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/keys.dart';
import '../../layout/device.dart';
import '../../reactive/providers/app_provider.dart';
import '../../utilities/get_mterminal.dart';
import '../../utilities/helper.dart';
import '../../widgets/app_update_card.dart';
import '../../widgets/login_card.dart';
import '../../widgets/logo.dart';
import '../../widgets/plan_upgrade_card.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Device(
        desktopMobileView: true,
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: Device.dockMargin(context) + Device.column(context) + (Device.margin(context) * 2)),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (context.watch<AppProvider>().isLoggedIn) ...[
                  Text('Hi, ${GetMterminal.user().firstName}', style: Theme.of(context).textTheme.headlineSmall),
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
                  SizedBox(height: Device.margin(context) * 2),
                ],
                const Logo(),
                SizedBox(height: Device.margin(context)),
                Text(
                  'Remote servers management made easy',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Device.margin(context) * 2),
                if (context.watch<AppProvider>().isLoggedIn) const PlanUpgradeCard() else const LoginCard(),
                SizedBox(height: Device.margin(context)),
                const AppUpdateCard(),
                SizedBox(height: Device.margin(context)),
                _alerts
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get _alerts => ListView(
        shrinkWrap: true,
        children: GetMterminal.alerts()
            .map((alert) => Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.notifications_active,
                      color: alert.priorityColor,
                    ),
                    title: Text(alert.title),
                    subtitle: Text(DateFormat(Keys.ddMMMMyHma).format(alert.createdAt)),
                    trailing: alert.link != null
                        ? IconButton(
                            onPressed: () {
                              Helper.openUrl(url: alert.link!);
                            },
                            icon: const Icon(Icons.open_in_new))
                        : null,
                  ),
                ))
            .toList(),
      );
}
