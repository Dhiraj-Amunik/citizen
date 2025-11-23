import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/features/events/model/request_event_model.dart';
import 'package:inldsevak/features/events/view/events_view.dart';
import 'package:inldsevak/features/events/view_model/events_view_model.dart';
import 'package:inldsevak/features/lok_varta/model/request_lok_varta_model.dart';
import 'package:inldsevak/features/lok_varta/view_model/lok_varta_view_model.dart';
import 'package:inldsevak/features/lok_varta/widgets/interview_widget.dart';
import 'package:inldsevak/features/lok_varta/widgets/lok_varta_tabbar.dart';
import 'package:inldsevak/features/lok_varta/widgets/mla_details_silver_appbar.dart';
import 'package:inldsevak/features/lok_varta/widgets/photo_widget.dart';
import 'package:inldsevak/features/lok_varta/widgets/press_releases_widget.dart';
import 'package:inldsevak/features/lok_varta/widgets/video_player_widget.dart';
import 'package:provider/provider.dart';

class LokVartaView extends StatefulWidget {
  const LokVartaView({super.key});

  @override
  State<LokVartaView> createState() => _LokVartaViewState();
}

class _LokVartaViewState extends State<LokVartaView>
    with TickerProviderStateMixin {
  late TabController tabController;
  final ScrollController _scrollController = ScrollController();
  bool _previousSearchState = false;

  @override
  void initState() {
    tabController = TabController(
      length: 6,
      vsync: this,
      animationDuration: Duration(milliseconds: 200),
    );
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<LokVartaViewModel>();
    final eventProvider = context.read<EventsViewModel>();
    return ChangeNotifierProvider(
      create: (contextP) => ShowSearchLokVartaProvider(
        clear: () {
          provider.searchController.clear();
          provider.onSearchChanged(
            tabController.index,
            eventProvider.getEvents,
          );
        },
      ),
      builder: (contextP, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppPalettes.liteGreenColor,
            toolbarHeight: 0,
          ),
          body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                Consumer<LokVartaViewModel>(
                  builder: (context, value, _) {
                    return MlaDetailsSilverAppbar(
                      mlaModel: context.read<LokVartaViewModel>().mlaModel,
                    );
                  },
                ),
             
                Consumer<ShowSearchLokVartaProvider>(
                  builder: (contextP, search, _) {
                    // Auto-scroll when search opens
                    if (search.showSearchWidget && !_previousSearchState) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (_scrollController.hasClients) {
                            final searchHeight = 35.h;
                            _scrollController.animateTo(
                              searchHeight,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                            );
                          }
                        });
                      });
                    }
                   
                    _previousSearchState = search.showSearchWidget;
                                        return LokVartaTabbar(

                      showSearch: search.showSearchWidget,
                      searchController: provider.searchController,
                      controller: tabController,
                      onTap: () => search.showSearchWidget = true,
                      onSearchChanged: (text) => provider.onSearchChanged(
                        tabController.index,
                        eventProvider.getEvents,
                      ),
                      onClear: () {
                        provider.searchController.clear();
                        provider.onSearchChanged(
                          tabController.index,
                          eventProvider.getEvents,
                        );
                        search.showSearchWidget = false;
                      },
                    );
                  },
                ),
              ];
            },
            body: Consumer2<LokVartaViewModel, EventsViewModel>(
              builder: (context, value, events, _) {
                if (value.isLoading ||
                    value.isLokVartaLoading ||
                    events.isEventLoading) {
                  return Center(child: CustomAnimatedLoading());
                }
                return TabBarView(
                  controller: tabController,
                  children: [
                    EventsBuildWidget(
                      data: events.upcomingEventList,
                      onRefresh: () =>
                          events.getEvents(EventFilter.upcoming),
                      type: EventFilter.upcoming,
                      height: 0.1,
                    ),
                    EventsBuildWidget(
                      data: events.ongoingEventList,
                      onRefresh: () =>
                          events.getEvents(EventFilter.ongoing),
                      type: EventFilter.ongoing,
                      height: 0.1,
                    ),
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
                    VideoPlayerWidget(
                      medias: value.videosList,
                      onRefresh: () =>
                          value.getLokVarta(LokVartaFilter.Videos),
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
                  top: 0,
                  bottom: Dimens.paddingX2,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
