import 'package:flutter/material.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/features/lok_varta/model/request_lok_varta_model.dart';
import 'package:inldsevak/features/lok_varta/view_model/lok_varta_view_model.dart';
import 'package:inldsevak/features/lok_varta/widgets/interview_widget.dart';
import 'package:inldsevak/features/lok_varta/widgets/lok_varta_tabbar.dart';
import 'package:inldsevak/features/lok_varta/widgets/lokvarta_helpers.dart';
import 'package:inldsevak/features/lok_varta/widgets/mla_details_silver_appbar.dart';
import 'package:inldsevak/features/lok_varta/widgets/photo_widget.dart';
import 'package:inldsevak/features/lok_varta/widgets/press_releases_widget.dart';
import 'package:provider/provider.dart';

class LokVartaView extends StatefulWidget {
  const LokVartaView({super.key});

  @override
  State<LokVartaView> createState() => _LokVartaViewState();
}

class _LokVartaViewState extends State<LokVartaView>
    with TickerProviderStateMixin {
  late TabController tabController;
  @override
  void initState() {
    tabController = TabController(
      length: 5,
      vsync: this,
      animationDuration: Duration(milliseconds: 200),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppPalettes.liteGreenColor,
        toolbarHeight: 0,
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            Consumer<LokVartaViewModel>(
              builder: (context, value, _) {
                return MlaDetailsSilverAppbar(
                  mlaModel: context.read<LokVartaViewModel>().mlaModel,
                );
              },
            ),
            LokVartaTabbar(controller: tabController),
          ];
        },
        body: Column(
          children: [
            Expanded(
              child: Consumer<LokVartaViewModel>(
                builder: (context, value, _) {
                  if (value.isLoading) {
                    return Center(child: CustomAnimatedLoading());
                  }
                  return TabBarView(
                    controller: tabController,
                    children: [
                      PressReleasesWidget(
                        medias: value.pressReleasesList,
                        onRefresh: () =>
                            value.getLokVarta(LokVartaFilter.PressRelease),
                      ),
                      InterviewWidget(
                        medias: value.interviewsList,
                        onRefresh: () =>
                            value.getLokVarta(LokVartaFilter.Interview),
                      ),

                      LokvartaHelpers.lokVartaPlaceholder(
                        type: LokVartaFilter.Article,
                        onRefresh: () async {},
                      ),
                      LokvartaHelpers.lokVartaPlaceholder(
                        type: LokVartaFilter.Video,
                        onRefresh: () async {},
                      ),
                      PhotoWidget(
                        medias: value.photoLists,
                        onRefresh: () =>
                            value.getLokVarta(LokVartaFilter.PhotoGallery),
                      ),
                    ],
                  ).onlyPadding(
                    left: Dimens.paddingX3,
                    right: Dimens.paddingX3,
                    top: Dimens.verticalspacing,
                  );
                },
              ),
            ),
            SizeBox.sizeHX11,
          ],
        ),
      ),
    );
  }
}
