import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/extensions/date_formatter.dart';
import 'package:inldsevak/core/extensions/padding_extension.dart';
import 'package:inldsevak/core/extensions/responsive_extension.dart';
import 'package:inldsevak/core/extensions/time_formatter.dart';
import 'package:inldsevak/core/helpers/common_helpers.dart';
import 'package:inldsevak/core/utils/app_images.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
import 'package:inldsevak/core/utils/app_styles.dart';
import 'package:inldsevak/core/utils/dimens.dart';
import 'package:inldsevak/core/utils/sizedBox.dart';
import 'package:inldsevak/core/widgets/common_appbar.dart';
import 'package:inldsevak/core/widgets/read_more_widget.dart';
import 'package:inldsevak/core/widgets/translated_text.dart';
import 'package:inldsevak/features/lok_varta/model/request_lok_varta_model.dart';
import 'package:inldsevak/features/lok_varta/widgets/lokvarta_helpers.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:inldsevak/features/lok_varta/model/lok_varta_model.dart'
    as model;

class VideoPlayerWidget extends StatelessWidget {
  final List<model.Media> medias;
  final Future<void> Function() onRefresh;

  const VideoPlayerWidget({
    super.key,
    required this.onRefresh,
    required this.medias,
  });

  @override
  Widget build(BuildContext context) {
    if (medias.isEmpty) {
      return LokvartaHelpers.lokVartaPlaceholder(
        type: LokVartaFilter.Videos,
        onRefresh: onRefresh,
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.paddingX3),

        child: ListView.separated(
          itemCount: medias.length,
          itemBuilder: (_, index) {
            final data = medias[index];
            final videoID = YoutubePlayer.convertUrlToId(data.videoUrl ?? "");
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Dimens.gapX,
              children: [
                Stack(
                  alignment: AlignmentGeometry.bottomRight,
                  fit: StackFit.passthrough,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerScreen(
                            medias: medias,
                            initialIndex: index,
                          ),
                        ),
                      ),
                      child: Stack(
                        alignment: AlignmentGeometry.center,
                        fit: StackFit.passthrough,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadiusGeometry.circular(
                              Dimens.radiusX2,
                            ),
                            child: SizedBox(
                              height: 200.height(),
                              child: CommonHelpers.getCacheNetworkImage(
                                "https://img.youtube.com/vi/$videoID/hqdefault.jpg",
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                          Center(
                            child: Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: Dimens.scaleX6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      bottom: Dimens.paddingX3,
                      right: Dimens.paddingX3,
                      child: CommonHelpers.buildIcons(
                        onTap: () =>
                            CommonHelpers.shareURL(data.videoUrl ?? "", eventId: data.sId),
                        padding: Dimens.paddingX2,
                        iconSize: Dimens.scaleX2,
                        path: AppImages.shareIcon,
                        iconColor: AppPalettes.whiteColor,
                        color: AppPalettes.blackColor.withOpacityExt(0.5),
                      ),
                    ),
                  ],
                ),
                BuildYoutubeData(data: data),
              ],
            );
          },
          separatorBuilder: (context, index) => SizeBox.sizeHX8,
        ),
      ),
    );
  }
}

class BuildYoutubeData extends StatelessWidget {
  final model.Media data;
  const BuildYoutubeData({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Dimens.gapX,
      children: [
        TranslatedText(
          text: data.title ?? "",
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        ReadMoreWidget(
          text: data.content ?? "",
          style: AppStyles.labelMedium.copyWith(
            color: AppPalettes.lightTextColor,
          ),
        ),
        Row(
          spacing: Dimens.gapX2,
          children: [
            Text(
              data.publishDate?.toDdMmmYyyy() ?? "",
              style: textTheme.labelMedium?.copyWith(
                color: AppPalettes.lightTextColor,
              ),
            ),
            Text(
              data.publishDate?.to12HourTime() ?? "",
              style: textTheme.labelMedium?.copyWith(
                color: AppPalettes.lightTextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final List<model.Media> medias;
  final int initialIndex;
  const VideoPlayerScreen({
    super.key,
    required this.medias,
    required this.initialIndex,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  late YoutubePlayerController _fullScreenController;
  late int _currentIndex;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _initializeController();
  }

  void _initializeController() {
    final videoUrl = widget.medias[_currentIndex].videoUrl ?? "";
    final videoId = YoutubePlayer.convertUrlToId(videoUrl) ?? "";

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        hideControls: false,
        controlsVisibleAtStart: true,
        useHybridComposition: true,
      ),
    );

    // Listen to fullscreen changes from YouTube player
    _controller.addListener(_playerListener);
  }

  void _playerListener() {
    if (_controller.value.isFullScreen && !_isFullScreen) {
      _enterFullScreen();
    } else if (!_controller.value.isFullScreen && _isFullScreen) {
      _exitFullScreen();
    }
  }

  void _enterFullScreen() {
    final videoUrl = widget.medias[_currentIndex].videoUrl ?? "";
    final videoId = YoutubePlayer.convertUrlToId(videoUrl) ?? "";

    _fullScreenController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        hideControls: false,
        controlsVisibleAtStart: true,
        useHybridComposition: true,
      ),
    );

    setState(() {
      _isFullScreen = true;
    });

    // Force landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Hide status bar and navigation bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void _exitFullScreen() {
    final videoUrl = widget.medias[_currentIndex].videoUrl ?? "";
    final videoId = YoutubePlayer.convertUrlToId(videoUrl) ?? "";

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        hideControls: false,
        controlsVisibleAtStart: true,
        useHybridComposition: true,
      ),
    );
    setState(() {
      _isFullScreen = false;
    });

    // Set back to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Show system UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
  }

  void _changeVideo(int newIndex) {
    if (newIndex == _currentIndex) return;

    setState(() {
      _currentIndex = newIndex;
    });

    final videoUrl = widget.medias[newIndex].videoUrl ?? "";
    final videoId = YoutubePlayer.convertUrlToId(videoUrl) ?? "";
    _controller.pause();
    _controller.load(videoId);
    _controller.play();
  }

  Widget _buildFullScreenUI() {
    return Scaffold(
      backgroundColor: AppPalettes.blackColor,
      body: SafeArea(
        child: Stack(
          alignment: AlignmentGeometry.topLeft,
          children: [
            // YouTube Player
            Center(
              child: YoutubePlayer(
                controller: _fullScreenController,
                aspectRatio: 16 / 9,
                width: double.infinity,
              ),
            ),

            // Custom controls
            Padding(
              padding: EdgeInsetsGeometry.all(Dimens.paddingX3),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppPalettes.whiteColor,
                ),
                onPressed: () {
                  _controller.toggleFullScreenMode();
                  _exitFullScreen();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Normal UI with all features
  Widget _buildNormalUI(BuildContext context) {
    final currentVideo = widget.medias[_currentIndex];
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        _controller.pause();
      },
      child: Scaffold(
        appBar: commonAppBar(
          title: context.localizations.lok_varta,
          action: [
            CommonHelpers.buildIcons(
              path: AppImages.shareIcon,
              color: AppPalettes.liteGreenColor,
              iconColor: AppPalettes.blackColor,
              padding: Dimens.paddingX3,
              iconSize: Dimens.scaleX2,
              onTap: () => CommonHelpers.shareURL(currentVideo.videoUrl ?? "", eventId: currentVideo.sId),
            ),
          ],
        ),
        body: Column(
          children: [
            // Video Player
            AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubePlayer(
                key: ObjectKey(_controller.initialVideoId),
                controller: _controller,
              ),
            ),

            // Current Video Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Dimens.gapX2,
              children: [
                SizedBox(
                  height: Dimens.scaleX5,
                  width: Dimens.scaleX5,
                  child: ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(
                      Dimens.radius100,
                    ),
                    child: CommonHelpers.getCacheNetworkImage(""),
                  ),
                ),
                Expanded(child: BuildYoutubeData(data: currentVideo)),
              ],
            ).symmetricPadding(
              horizontal: Dimens.paddingX3,
              vertical: Dimens.paddingX2,
            ),
            // Videos List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "More Videos",
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ).onlyPadding(left: Dimens.paddingX4, bottom: Dimens.paddingX2),

            // Videos List
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: Dimens.paddingX1B),
                itemBuilder: (_, index) {
                  final video = widget.medias[index];
                  final videoID = YoutubePlayer.convertUrlToId(
                    video.videoUrl ?? "",
                  );
                  final isSelected = index == _currentIndex;

                  return _VideoListTile(
                    video: video,
                    videoID: videoID,
                    index: index,
                    isSelected: isSelected,
                    onTap: () => _changeVideo(index),
                  );
                },
                separatorBuilder: (_, __) => SizeBox.sizeHX2,
                itemCount: widget.medias.length,
              ),
            ),
            SizeBox.sizeHX4,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isFullScreen ? _buildFullScreenUI() : _buildNormalUI(context);
  }

  @override
  void dispose() {
    _controller.removeListener(_playerListener);
    _controller.dispose();
    _fullScreenController.dispose();
    // Reset orientation when disposing
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
}

class _VideoListTile extends StatelessWidget {
  final model.Media video;
  final String? videoID;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _VideoListTile({
    required this.video,
    required this.videoID,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: isSelected
            ? EdgeInsets.zero
            : EdgeInsets.symmetric(horizontal: Dimens.marginX2),
        padding: isSelected
            ? EdgeInsets.symmetric(
                horizontal: Dimens.paddingX2,
                vertical: Dimens.paddingX2,
              )
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: isSelected
              ? AppPalettes.liteGreenColor.withOpacityExt(0.1)
              : null,
          borderRadius: BorderRadius.circular(Dimens.radiusX2),
          border: isSelected
              ? Border.all(color: AppPalettes.liteGreenColor)
              : null,
        ),
        child: Row(
          spacing: Dimens.gapX2,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimens.radiusX2),
              child: SizedBox(
                height: 70.height(),
                width: 130.height(),
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [
                    CommonHelpers.getCacheNetworkImage(
                      "https://img.youtube.com/vi/$videoID/hqdefault.jpg",
                      fit: BoxFit.cover,
                    ),
                    Container(
                      color: AppPalettes.blackColor.withOpacityExt(0.3),
                      child: Center(
                        child: Icon(
                          isSelected ? Icons.pause : Icons.play_circle_fill,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Video Info
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: Dimens.paddingX1),
                child: Column(
                  spacing: Dimens.gapX1,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title ?? "",
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      video.publishDate?.toDdMmmYyyy() ?? "",
                      style: context.textTheme.labelSmall?.copyWith(
                        color: AppPalettes.lightTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
