import 'package:flutter/material.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/features/profile_tabs/widgets/leaders_info_widget.dart';

class LeadershipInfoView extends StatelessWidget {
  const LeadershipInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.localizations;
    return Scaffold(
      appBar: commonAppBar(title: localization.leadership_information),
      body: Column(
        children: [
          LeadersInfoWidget()
        ],
      ),
    );
  }
}
