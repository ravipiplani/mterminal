import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../app_router.dart';
import '../../config/keys.dart';
import '../../config/lottie_files.dart';
import '../../reactive/blocs/team/team_bloc.dart';
import '../../reactive/providers/app_provider.dart';
import '../../services/user_service.dart';
import '../../widgets/logo.dart';
import '../partials/status_view.dart';

class AcceptTeamInvitePage extends StatefulWidget {
  const AcceptTeamInvitePage({super.key, required this.iid, required this.uid, required this.token});

  final String iid;
  final String uid;
  final String token;

  @override
  State<AcceptTeamInvitePage> createState() => _AcceptTeamInvitePageState();
}

class _AcceptTeamInvitePageState extends State<AcceptTeamInvitePage> {
  @override
  void initState() {
    BlocProvider.of<TeamBloc>(context).add(AcceptTeamInviteEvent(iid: widget.iid, uid: widget.uid, token: widget.token));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        title: const Logo(),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<TeamBloc, TeamState>(builder: (context, state) {
        if (state is TeamInviteAcceptedState) {
          return StatusView(
            lottie: LottieFiles.success,
            title: 'Team joined successfully.',
            buttonText: context.read<AppProvider>().isLoggedIn
                ? 'Go to Home'
                : state.isSignedUp
                    ? 'Login to Continue'
                    : 'Complete profile to Continue',
            onPressed: () async {
              if (context.read<AppProvider>().isLoggedIn) {
                await UserService().me();
                Get.offAllNamed(AppRouter.homePageRoute);
              } else if (state.isSignedUp) {
                Get.offAllNamed(AppRouter.authLoginPageRoute);
              } else {
                Get.offAllNamed(AppRouter.authSignupPageRoute, parameters: {
                  Keys.email: state.email
                });
              }
            },
          );
        } else if (state is AcceptingTeamInviteErrorState) {
          return StatusView(
            lottie: LottieFiles.error,
            title: 'Unable to join the team right now.',
            description: state.message,
            buttonText: 'Go to Home',
            onPressed: () {
              Get.offAllNamed(AppRouter.homePageRoute);
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
