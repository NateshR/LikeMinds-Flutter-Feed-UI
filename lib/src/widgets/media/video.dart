import 'dart:async';
import 'dart:io';

// import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:likeminds_feed_ui_fl/src/utils/theme.dart';
import 'package:likeminds_feed_ui_fl/src/widgets/common/buttons/icon_button.dart';
import 'package:likeminds_feed_ui_fl/src/widgets/common/shimmer/post_shimmer.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:media_kit_video/media_kit_video_controls/media_kit_video_controls.dart'
    as media_kit_video_controls;

class LMVideo extends StatefulWidget {
  // late final LMVideo? _instance;

  const LMVideo({
    super.key,
    this.videoUrl,
    this.videoFile,
    this.height,
    this.width,
    this.aspectRatio,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.loaderWidget,
    this.errorWidget,
    this.shimmerWidget,
    this.boxFit,
    this.playButton,
    this.pauseButton,
    this.muteButton,
    this.showControls,
    this.autoPlay,
    this.looping,
    this.allowFullScreen,
    this.allowMuting,
    this.isMute,
    this.progressTextStyle,
    this.seekBarBufferColor,
    this.seekBarColor,
  }) : assert(videoUrl != null || videoFile != null);

  //Video asset variables
  final String? videoUrl;
  final File? videoFile;

  // Video structure variables
  final double? height;
  final double? width;
  final double? aspectRatio; // defaults to 16/9
  final double? borderRadius; // defaults to 0
  final Color? borderColor;
  final double? borderWidth;
  final BoxFit? boxFit; // defaults to BoxFit.cover

  // Video styling variables
  final Color? seekBarColor;
  final Color? seekBarBufferColor;
  final TextStyle? progressTextStyle;
  final Widget? loaderWidget;
  final Widget? errorWidget;
  final Widget? shimmerWidget;
  final LMIconButton? playButton;
  final LMIconButton? pauseButton;
  final LMIconButton? muteButton;

  // Video functionality control variables
  final bool? isMute;
  final bool? showControls;
  final bool? autoPlay;
  final bool? looping;
  final bool? allowFullScreen;
  final bool? allowMuting;

  @override
  State<LMVideo> createState() => _LMVideoState();
}

class _LMVideoState extends State<LMVideo> {
  ValueNotifier<bool> rebuildOverlay = ValueNotifier(false);
  bool _onTouch = true;
  bool initialiseOverlay = false;

  late final Player player;
  late final VideoController controller;

  Timer? _timer;

  @override
  void dispose() async {
    _timer?.cancel();
    player.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {}

  @override
  void initState() {
    player = Player(
      configuration: PlayerConfiguration(
        bufferSize: 24 * 1024 * 1024,
        ready: () {
          if (widget.isMute != null && widget.isMute!) player.setVolume(0);
        },
      ),
    );
    controller = VideoController(
      player,
      configuration: const VideoControllerConfiguration(
        enableHardwareAcceleration: true,
        scale: 0.2,
      ),
    );
    super.initState();
  }

  Future<void> initialiseControllers() async {
    if (widget.videoUrl != null) {
      player.open(
        Media(widget.videoUrl!),
        play: widget.autoPlay ?? true,
      );
    } else {
      player.open(
        Media(widget.videoFile!.uri.toString()),
        play: widget.autoPlay ?? true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return FutureBuilder(
      future: initialiseControllers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LMPostMediaShimmer();
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (!initialiseOverlay) {
            _timer = Timer.periodic(const Duration(milliseconds: 3000), (_) {
              initialiseOverlay = true;
              _onTouch = false;
              rebuildOverlay.value = !rebuildOverlay.value;
            });
          }
          return Stack(children: [
            VisibilityDetector(
              key: Key('post_video_${widget.videoUrl ?? widget.videoFile}'),
              onVisibilityChanged: (visibilityInfo) async {
                var visiblePercentage = visibilityInfo.visibleFraction * 100;
                if (visiblePercentage <= 50) {
                  controller.player.pause();
                }
                if (visiblePercentage > 50) {
                  controller.player.play();
                  rebuildOverlay.value = !rebuildOverlay.value;
                }
              },
              child: Container(
                width: widget.width ?? screenSize.width,
                height: widget.height,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius ?? 0),
                  border: Border.all(
                    color: widget.borderColor ?? Colors.transparent,
                    width: 0,
                  ),
                ),
                alignment: Alignment.center,
                child: MaterialVideoControlsTheme(
                  normal: MaterialVideoControlsThemeData(
                    bottomButtonBar: [
                      const MaterialPositionIndicator(
                        style: TextStyle(
                          color: kWhiteColor,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          player.state.volume > 0.0
                              ? player.setVolume(0)
                              : player.setVolume(100);
                        },
                        icon: LMIcon(
                          type: LMIconType.icon,
                          color: kWhiteColor,
                          icon: player.state.volume > 0.0
                              ? Icons.volume_off
                              : Icons.volume_up,
                        ),
                      )
                    ],
                    seekBarMargin: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    seekBarPositionColor: widget.seekBarColor ??
                        const Color.fromARGB(255, 0, 137, 123),
                    seekBarThumbColor: widget.seekBarColor ??
                        const Color.fromARGB(255, 0, 137, 123),
                  ),
                  fullscreen: const MaterialVideoControlsThemeData(),
                  child: Video(
                    controller: controller,
                    filterQuality: FilterQuality.low,
                    controls: widget.showControls != null &&
                            widget.showControls!
                        ? media_kit_video_controls.AdaptiveVideoControls
                        : (state) {
                            return ValueListenableBuilder(
                              valueListenable: rebuildOverlay,
                              builder: (context, _, __) {
                                return Visibility(
                                  visible: _onTouch,
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: TextButton(
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all(
                                          const CircleBorder(
                                            side: BorderSide(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: Icon(
                                        controller.player.state.playing
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        size: 28,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        _timer?.cancel();
                                        controller.player.state.playing
                                            ? state.widget.controller.player
                                                .pause()
                                            : state.widget.controller.player
                                                .play();
                                        rebuildOverlay.value =
                                            !rebuildOverlay.value;
                                        _timer = Timer.periodic(
                                          const Duration(milliseconds: 2500),
                                          (_) {
                                            _onTouch = false;
                                            rebuildOverlay.value =
                                                !rebuildOverlay.value;
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                  ),
                ),
              ),
            ),
          ]);
        } else {
          return widget.errorWidget ?? const SizedBox();
        }
      },
    );
  }
}
