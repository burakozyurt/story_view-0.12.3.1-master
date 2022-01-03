import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';
import 'dart:math';

import '../utils.dart';
import '../controller/story_controller.dart';

class VideoLoader {
  String url;

  File videoFile;

  Map<String, dynamic> requestHeaders;

  LoadState state = LoadState.loading;

  VideoLoader(this.url, {this.requestHeaders});

  void loadVideo(VoidCallback onComplete) {
    if (this.videoFile != null) {
      this.state = LoadState.success;
      onComplete();
    }

    final fileStream = DefaultCacheManager()
        .getFileStream(this.url, headers: this.requestHeaders
    );

    fileStream.listen((fileResponse) {
      if (fileResponse is FileInfo) {
        if (this.videoFile == null) {
          this.state = LoadState.success;
          this.videoFile = fileResponse.file;
          onComplete();
        }
      }
    }
    );
  }
}

class StoryVideo extends StatefulWidget {
  final StoryController storyController;
  final VideoLoader videoLoader;

  StoryVideo(this.videoLoader, {this.storyController, Key key})
      : super(key: key ?? UniqueKey()
  );

  static StoryVideo url(String url,
      {StoryController controller,
        Map<String, dynamic> requestHeaders,
        Key key}) {
    return StoryVideo(
      VideoLoader(url, requestHeaders: requestHeaders
      ),
      storyController: controller,
      key: key,
    );
  }

  @override
  State<StatefulWidget> createState() {
    return StoryVideoState();
  }
}

class StoryVideoState extends State<StoryVideo> {
  Future<void> playerLoader;

  StreamSubscription _streamSubscription;

  VideoPlayerController playerController;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    widget.storyController.pause();

    widget.videoLoader.loadVideo(() {
      if (widget.videoLoader.state == LoadState.success) {
        this.playerController =
            VideoPlayerController.file(widget.videoLoader.videoFile
            );

        playerController.initialize().then((v) {
          setState(() {}
          );
          widget.storyController.play();
        }
        );

        if (widget.storyController != null) {
          _streamSubscription =
              widget.storyController.playbackNotifier.listen((playbackState) {
                if (playbackState == PlaybackState.pause) {
                  playerController.pause();
                } else {
                  playerController.play();
                }
              }
              );
        }
      } else {
        setState(() {}
        );
      }
    }
    );
  }

  Future<void> reInitialize() async {
    widget.storyController.pause();
    playerController.pause();
    widget.videoLoader.loadVideo(() {
      if (widget.videoLoader.state == LoadState.success) {
        this.playerController =
            VideoPlayerController.file(widget.videoLoader.videoFile
            );

        playerController.initialize().then((v) {
          setState(() {}
          );
          widget.storyController.play();
        }
        );

        if (widget.storyController != null) {
          _streamSubscription =
              widget.storyController.playbackNotifier.listen((playbackState) {
                if (playbackState == PlaybackState.pause) {
                  playerController.pause();
                } else {
                  playerController.play();
                }
              }
              );
        }
      } else {
        setState(() {}
        );
      }
    }
    );
  }

  Widget getContentView() {
    if (widget.videoLoader.state == LoadState.success &&
        playerController.value.initialized) {
      return Center(
          child: Transform.rotate(alignment: Alignment.center,
              angle: playerController.value.aspectRatio < 1 ? 0 : pi / 2,
              child:Transform.scale(
                scale: playerController.value.aspectRatio < 1 ? 1 : 1 * playerController.value.aspectRatio,
                child:AspectRatio(
                  aspectRatio: playerController.value.aspectRatio,
                  child: VideoPlayer(playerController
                  ),
                ),
              )
          )
      );
    }
    /* if(widget.videoLoader.state == LoadState.success && !playerController.value.initialized){
      reInitialize();
    }*/
    return widget.videoLoader.state == LoadState.loading
        ? Center(
      child: Container(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white
          ),
          strokeWidth: 2,
        ),
      ),
    )
        : widget.videoLoader.state == LoadState.success ?  Center(
        child: Text(
          "",
          style: TextStyle(
            color: Colors.white,
          ),
        )):Center(
        child: Text(
          "Hikaye yüklenemedi.",
          style: TextStyle(
            color: Colors.white,
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: double.infinity,
      width: double.infinity,
      child: getContentView(),
    );
  }

  @override
  void dispose() {
    playerController.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }
}
