import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inldsevak/core/animated_widgets.dart/custom_animated_loading.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/dimens.dart';
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
import 'package:inldsevak/notification_service.dart';
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
  // Track which filters have been loaded to prevent infinite loading loops
  final Set<int> _loadedTabs = {};

  @override
  void initState() {
    tabController = TabController(
      length: 6,
      vsync: this,
      animationDuration: Duration(milliseconds: 200),
    );
    // Add listener to load data when tabs are switched
    tabController.addListener(_onTabChanged);
    super.initState();
  }

  void _onTabChanged() {
    if (!tabController.indexIsChanging) {
      // Tab animation completed, load data if needed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final provider = context.read<LokVartaViewModel>();
        final eventProvider = context.read<EventsViewModel>();
        final currentIndex = tabController.index;

        // Only load if we haven't loaded this tab yet
        if (_loadedTabs.contains(currentIndex)) return;

        switch (currentIndex) {
          case 0:
            if (eventProvider.upcomingEventList.isEmpty &&
                !eventProvider.isEventLoading) {
              _loadedTabs.add(currentIndex);
              eventProvider.getEvents(EventFilter.upcoming);
            }
            break;
          case 1:
            if (eventProvider.ongoingEventList.isEmpty &&
                !eventProvider.isEventLoading) {
              _loadedTabs.add(currentIndex);
              eventProvider.getEvents(EventFilter.ongoing);
            }
            break;
          case 2:
            if (provider.pressReleasesList.isEmpty &&
                !provider.isLokVartaLoading) {
              _loadedTabs.add(currentIndex);
              provider.getLokVarta(LokVartaFilter.PressRelease);
            }
            break;
          case 3:
            if (provider.interviewsList.isEmpty &&
                !provider.isLokVartaLoading) {
              _loadedTabs.add(currentIndex);
              provider.getLokVarta(LokVartaFilter.Interview);
            }
            break;
          case 4:
            if (provider.videosList.isEmpty && !provider.isLokVartaLoading) {
              _loadedTabs.add(currentIndex);
              provider.getLokVarta(LokVartaFilter.Videos);
            }
            break;
          case 5:
            if (provider.photoLists.isEmpty && !provider.isLokVartaLoading) {
              _loadedTabs.add(currentIndex);
              provider.getLokVarta(LokVartaFilter.PhotoGallery);
            }
            break;
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    NotificationService.triggerPopupIfAvailable();
  }

  @override
  void dispose() {
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
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
                      onSearchChanged: (text) {
                        // Clear loaded flag when search changes to allow reloading
                        _loadedTabs.remove(tabController.index);
                        provider.onSearchChanged(
                          tabController.index,
                          eventProvider.getEvents,
                        );
                      },
                      onClear: () {
                        // Clear loaded flag when search is cleared to allow reloading
                        _loadedTabs.remove(tabController.index);
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
                // Show loading only for initial load (when isLoading is true)
                // For individual tab loading, show content with loading indicator in the widget
                if (value.isLoading || events.isEventLoading) {
                  return Center(child: CustomAnimatedLoading());
                }

                // Load data for current tab if empty and not already loaded
                // Only load once per tab to prevent infinite loops when list is legitimately empty
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  final currentIndex = tabController.index;

                  // Skip if we've already loaded this tab
                  if (_loadedTabs.contains(currentIndex)) return;

                  switch (currentIndex) {
                    case 0:
                      if (events.upcomingEventList.isEmpty &&
                          !events.isEventLoading) {
                        _loadedTabs.add(currentIndex);
                        events.getEvents(EventFilter.upcoming);
                      }
                      break;
                    case 1:
                      if (events.ongoingEventList.isEmpty &&
                          !events.isEventLoading) {
                        _loadedTabs.add(currentIndex);
                        events.getEvents(EventFilter.ongoing);
                      }
                      break;
                    case 2:
                      if (value.pressReleasesList.isEmpty &&
                          !value.isLokVartaLoading) {
                        _loadedTabs.add(currentIndex);
                        value.getLokVarta(LokVartaFilter.PressRelease);
                      }
                      break;
                    case 3:
                      if (value.interviewsList.isEmpty &&
                          !value.isLokVartaLoading) {
                        _loadedTabs.add(currentIndex);
                        value.getLokVarta(LokVartaFilter.Interview);
                      }
                      break;
                    case 4:
                      if (value.videosList.isEmpty &&
                          !value.isLokVartaLoading) {
                        _loadedTabs.add(currentIndex);
                        value.getLokVarta(LokVartaFilter.Videos);
                      }
                      break;
                    case 5:
                      if (value.photoLists.isEmpty &&
                          !value.isLokVartaLoading) {
                        _loadedTabs.add(currentIndex);
                        value.getLokVarta(LokVartaFilter.PhotoGallery);
                      }
                      break;
                  }
                });
                return TabBarView(
                  controller: tabController,
                  children: [
                    EventsBuildWidget(
                      data: events.upcomingEventList,
                      onRefresh: () async {
                        _loadedTabs.remove(
                          0,
                        ); // Clear loaded flag to allow refresh
                        await events.getEvents(EventFilter.upcoming);
                      },
                      type: EventFilter.upcoming,
                      height: 0.1,
                    ),
                    EventsBuildWidget(
                      data: events.ongoingEventList,
                      onRefresh: () async {
                        _loadedTabs.remove(
                          1,
                        ); // Clear loaded flag to allow refresh
                        await events.getEvents(EventFilter.ongoing);
                      },
                      type: EventFilter.ongoing,
                      height: 0.1,
                    ),
                    // Show loading if press releases are loading and list is empty
                    value.isLoadingFilter(LokVartaFilter.PressRelease) &&
                            value.pressReleasesList.isEmpty
                        ? Center(child: CustomAnimatedLoading())
                        : PressReleasesWidget(
                            medias: value.pressReleasesList,
                            onRefresh: () async {
                              _loadedTabs.remove(
                                2,
                              ); // Clear loaded flag to allow refresh
                              await value.getLokVarta(
                                LokVartaFilter.PressRelease,
                              );
                            },
                          ),
                    // Show loading if interviews are loading and list is empty
                    value.isLoadingFilter(LokVartaFilter.Interview) &&
                            value.interviewsList.isEmpty
                        ? Center(child: CustomAnimatedLoading())
                        : InterviewWidget(
                            medias: value.interviewsList,
                            onRefresh: () async {
                              _loadedTabs.remove(
                                3,
                              ); // Clear loaded flag to allow refresh
                              await value.getLokVarta(LokVartaFilter.Interview);
                            },
                          ),
                    // Show loading if videos are loading and list is empty
                    value.isLoadingFilter(LokVartaFilter.Videos) &&
                            value.videosList.isEmpty
                        ? Center(child: CustomAnimatedLoading())
                        : VideoPlayerWidget(
                            medias: value.videosList,
                            onRefresh: () async {
                              _loadedTabs.remove(
                                4,
                              ); // Clear loaded flag to allow refresh
                              await value.getLokVarta(LokVartaFilter.Videos);
                            },
                          ),
                    // Show loading if photos are loading and list is empty
                    value.isLoadingFilter(LokVartaFilter.PhotoGallery) &&
                            value.photoLists.isEmpty
                        ? Center(child: CustomAnimatedLoading())
                        : PhotoWidget(
                            medias: value.photoLists,
                            onRefresh: () async {
                              _loadedTabs.remove(
                                5,
                              ); // Clear loaded flag to allow refresh
                              await value.getLokVarta(
                                LokVartaFilter.PhotoGallery,
                              );
                            },
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
