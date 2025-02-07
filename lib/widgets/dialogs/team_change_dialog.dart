import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_router.dart';
import '../../config/keys.dart';
import '../../utilities/get_mterminal.dart';
import '../../utilities/preferences.dart';

void showTeamChangeDialog(BuildContext context) {
  final selectedTeam = GetMterminal.selectedTeam();
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.change_circle_outlined),
          title: const Text('Select Team'),
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.hardEdge,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: GetMterminal.user().teams.map((team) {
                final isSelected = team.id == selectedTeam.id;
                return ListTile(
                    title: Text(team.name),
                    trailing: isSelected ? const Icon(Icons.done) : null,
                    selected: isSelected,
                    onTap: () {
                      if (!isSelected) {
                        Preferences.setInt(Keys.selectedTeamId, team.id);
                        Get.offAllNamed(AppRouter.homePageRoute);
                      } else {
                        Get.back();
                      }
                    });
              }).toList(),
            ),
          ),
        );
      });
}
