import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:videoplayerdemo/video_player/material_controls.dart';
import 'dart:io' show Platform;
import 'cupertino_controls.dart';
import 'utils.dart';

class AdvancedVideoPlayer extends StatefulWidget {
  final String link;

  AdvancedVideoPlayer({this.link});

  @override
  _AdvancedVideoPlayerState createState() => _AdvancedVideoPlayerState();
}

class _AdvancedVideoPlayerState extends State<AdvancedVideoPlayer> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayer;
  bool _isFullScreen;
  bool isLoaded = false;

  @override
  void initState() {
    _controller = VideoPlayerController.network(widget.link);
    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayer = _controller.initialize();
    // Use the controller to loop the video when it finish.
//    _controller.setLooping(true);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    //return the default appearance for the application
    enableAllOrientation();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: OrientationBuilder(builder: (context, orientation) {
          _isFullScreen = orientation == Orientation.landscape ? true : false;
          print(orientation);
          return FutureBuilder(
            future: _initializeVideoPlayer,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                //the video will be played once its initialized
                isLoaded ? null : _controller.play();
                isLoaded = true;
                return Stack(
                  children: <Widget>[
                    _videoPlayer(),
                    _buildControls(),
                  ],
                );
              } else {
                // If the VideoPlayerController is still initializing, show a loading spinner.
                return ProgressIndicator();
              }
            },
          );
        }),
      ),
    );
  }

  Widget _videoPlayer() {
    if (_isFullScreen) {
      //hide status bar
      SystemChrome.setEnabledSystemUIOverlays([]);

      return VideoPlayer(_controller);
    } else {
      //show the status bar
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      return Align(
          alignment: Alignment.center,
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            // Use the VideoPlayer widget to display the video.
            child: VideoPlayer(_controller),
          ));
    }
  }

  _buildControls() {
    return
//      Platform.isAndroid
//        ? MaterialControls(controller: _controller, isFullScreen: _isFullScreen)
//        :
        CupertinoControls(controller: _controller, isFullScreen: _isFullScreen);
  }
}

class ProgressIndicator extends StatelessWidget {
  const ProgressIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Center(
            child: Platform.isAndroid
                ? CircularProgressIndicator()
                : CupertinoActivityIndicator()));
  }
}
