import 'dart:async';
import 'dart:math' as math;
import 'package:open_iconic_flutter/open_iconic_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';
import 'package:videoplayerdemo/presentation/my_flutter_app_icons.dart';
import 'package:videoplayerdemo/video_player/constants.dart';
import 'package:videoplayerdemo/video_player/progress_colors.dart';
import 'package:videoplayerdemo/video_player/utils.dart';

import 'cupertino_progress_bar.dart';

class CupertinoControls extends StatefulWidget {
  final VideoPlayerController controller;
  final bool isFullScreen;
  CupertinoControls({this.controller, this.isFullScreen});
  @override
  _CupertinoControlsState createState() => _CupertinoControlsState();
}

class _CupertinoControlsState extends State<CupertinoControls> {
  bool _isClicked;
  Timer _showHideTimer;
  Timer _progressBarTimer;
  double _latestVolume;

  final marginSize = 5.0;
  final backgroundColor = Color.fromRGBO(41, 41, 41, 0.7);
  final backBackgroundColor = Color.fromRGBO(19, 19, 19, 0.7);
  final iconColor = Color.fromARGB(255, 200, 200, 200);

  @override
  void initState() {
    _isClicked = true;
    _showHideControls();
    //This is to show the updates on the porgress bar every sec
    _progressBarTimer =
        Timer.periodic(Duration(seconds: PROGRESS_BAR_UPDATE_SEC), (Timer t) {
      setState(() {
        if (_isClicked) {
          setState(() {});
        }
        if (widget.controller != null &&
            widget.controller.value != null &&
            widget.controller.value.duration != null &&
            widget.controller.value.position != null) {
          if (widget.controller.value.position >=
              widget.controller.value.duration) {
            Navigator.pop(context);
          }
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _showHideTimer?.cancel();
    _progressBarTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.value.hasError) {
      return Center(
        child: Icon(
          OpenIconicIcons.ban,
          color: Colors.white,
          size: 42,
        ),
      );
    }
    final orientation = MediaQuery.of(context).orientation;
    final barHeight = orientation == Orientation.portrait ? 30.0 : 47.0;
    final buttonPadding = orientation == Orientation.portrait ? 16.0 : 24.0;

    return SafeArea(
      child: GestureDetector(
        onTap: _showHideControls,
        child: AbsorbPointer(
          absorbing: !_isClicked,
          child: AnimatedOpacity(
            opacity: _isClicked ? 1 : 0,
            duration:
                Duration(milliseconds: CONTROLS_DISPLAY_ANIMATION_TIME_mSEC),
            child: Column(
              children: <Widget>[
                _buildTopBar(
                    backgroundColor, iconColor, barHeight, buttonPadding),
                _buildHitArea(),
                widget.isFullScreen
                    ? _buildBottomBarFullScreen(
                        backgroundColor, iconColor, barHeight)
                    : _buildBottomBar(backgroundColor, iconColor, barHeight),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(Color backgroundColor, Color iconColor, double barHeight,
      double buttonPadding) {
    return Container(
      height: barHeight,
      margin: EdgeInsets.only(
        top: marginSize,
        right: marginSize,
        left: marginSize,
      ),
      child: Row(
        children: <Widget>[
          _buildTopLeftButtons(barHeight, buttonPadding),
          Expanded(child: Container()),
          _buildMuteButton(widget.controller, backgroundColor, iconColor,
              barHeight, buttonPadding),
        ],
      ),
    );
  }

  Widget _buildTopLeftButtons(double barHeight, double buttonPadding) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Row(
        children: <Widget>[
          _buildBackButton(
              backBackgroundColor, iconColor, barHeight, buttonPadding),
          _buildExpandButton(
              backgroundColor, iconColor, barHeight, buttonPadding)
        ],
      ),
    );
  }

  GestureDetector _buildBackButton(Color backgroundColor, Color iconColor,
      double barHeight, double buttonPadding) {
    return GestureDetector(
      onTap: () {
        _showHideControls();
        Navigator.pop(context);
      },
      child: ClipRRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10.0),
          child: Container(
            height: barHeight,
            padding: EdgeInsets.only(
              left: buttonPadding,
              right: buttonPadding,
            ),
            color: backgroundColor,
            child: Center(
              child: Icon(
                Icons.close,
                color: iconColor,
                size: 16.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildExpandButton(Color backgroundColor, Color iconColor,
      double barHeight, double buttonPadding) {
    return GestureDetector(
      onTap: () {
        widget.isFullScreen ? smallScreenButton() : fullScreenButton();
      },
      child: ClipRRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10.0),
          child: Container(
            height: barHeight,
            padding: EdgeInsets.only(
              left: buttonPadding,
              right: buttonPadding,
            ),
            color: backgroundColor,
            child: Center(
              child: Icon(
                widget.isFullScreen
                    ? OpenIconicIcons.fullscreenExit
                    : OpenIconicIcons.fullscreenEnter,
                color: iconColor,
                size: 12.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildMuteButton(
      VideoPlayerController controller,
      Color backgroundColor,
      Color iconColor,
      double barHeight,
      double buttonPadding) {
    return GestureDetector(
      onTap: () {
        _showHideControls();
        setState(() {
          if (controller.value.volume == 0) {
            controller.setVolume(_latestVolume ?? 0.5);
          } else {
            _latestVolume = controller.value.volume;
            controller.setVolume(0.0);
          }
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10.0),
          child: Container(
            color: backgroundColor,
            child: Container(
              height: barHeight,
              padding: EdgeInsets.only(
                left: buttonPadding,
                right: buttonPadding,
              ),
              child: Icon(
                (widget.controller.value.volume != null &&
                        widget.controller.value.volume > 0)
                    ? Icons.volume_up
                    : Icons.volume_off,
                color: iconColor,
                size: 16.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Expanded _buildHitArea() {
    return Expanded(
      child: Container(
        color: Colors.transparent,
      ),
    );
  }

  Container _buildBottomBar(
      Color backgroundColor, Color iconColor, double barHeight) {
    return Container(
      color: Colors.transparent,
      alignment: Alignment.bottomCenter,
      margin: EdgeInsets.all(marginSize),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: 10.0,
            sigmaY: 10.0,
          ),
          child: Container(
            height: 3 * barHeight,
            color: backgroundColor,
            child: Column(
              children: <Widget>[
                _buildProgressBar(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildPosition(iconColor),
                    Expanded(
                      child: Container(),
                    ),
                    _buildRemaining(iconColor),
                  ],
                ),
                Container(),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _buildSkipBack(iconColor, barHeight),
                      _buildPlayPause(widget.controller, iconColor, barHeight),
                      _buildSkipForward(iconColor, barHeight),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container _buildBottomBarFullScreen(
      Color backgroundColor, Color iconColor, double barHeight) {
    return Container(
      color: Colors.transparent,
      alignment: Alignment.bottomCenter,
      margin: EdgeInsets.all(marginSize),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: 10.0,
            sigmaY: 10.0,
          ),
          child: Container(
            height: barHeight,
            color: backgroundColor,
            child: Row(
              children: <Widget>[
                _buildSkipBack(iconColor, barHeight),
                _buildPlayPause(widget.controller, Colors.white, barHeight),
                _buildSkipForward(iconColor, barHeight),
                _buildPosition(iconColor),
                _buildProgressBar(),
                _buildRemaining(iconColor)
              ],
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildSkipBack(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: _skipBack,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        margin: EdgeInsets.only(left: 10.0),
        padding: EdgeInsets.only(
          left: 6.0,
          right: 6.0,
        ),
        child: Icon(
//            OpenIconicIcons.reload,
          Icons.replay_10,
//            CupertinoIcons.refresh_thick,
          color: iconColor,
          size: 25.0,
        ),
      ),
    );
  }

  GestureDetector _buildSkipForward(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: _skipForward,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: EdgeInsets.only(
          left: 6.0,
          right: 8.0,
        ),
        margin: EdgeInsets.only(
          right: 8.0,
        ),
        child: Icon(
          MyFlutterApp.forward_10,
//          OpenIconicIcons.reload,
//            Icons.replay_10,
//          CupertinoIcons.refresh_thick,
          color: iconColor,
          size: 25.0,
        ),
      ),
    );
  }

  GestureDetector _buildPlayPause(
      VideoPlayerController controller, Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: _playPause,
      child: Container(
//        height: barHeight,
        color: Colors.transparent,
        padding: EdgeInsets.only(
          left: 6.0,
          right: 6.0,
        ),
        child: Icon(
          controller.value.isPlaying
              ? CupertinoIcons.pause_solid
              : CupertinoIcons.play_arrow_solid,
          color: Colors.white,
          size: 35.0,
        ),
      ),
    );
  }

  Widget _buildPosition(Color iconColor) {
    final position = widget.controller.value != null
        ? widget.controller.value.position
        : Duration(seconds: 0);

    return Padding(
      padding: EdgeInsets.only(left: 20.0),
      child: Text(
        formatDuration(position),
        style: TextStyle(
          color: iconColor,
          fontSize: 12.0,
        ),
      ),
    );
  }

  Widget _buildRemaining(Color iconColor) {
    final position = widget.controller.value != null &&
            widget.controller.value.duration != null
        ? widget.controller.value.duration - widget.controller.value.position
        : Duration(seconds: 0);

    return Padding(
      padding: EdgeInsets.only(right: 20.0),
      child: Text(
        '-${formatDuration(position)}',
        style: TextStyle(color: iconColor, fontSize: 12.0),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: CupertinoVideoProgressBar(
          widget.controller,
          onDragStart: () {
            _showHideControls();
          },
          onDragEnd: () {
            _showHideControls();
          },
          colors: ProgressColors(
            playedColor: Color.fromARGB(
              120,
              255,
              255,
              255,
            ),
            handleColor: Color.fromARGB(
              255,
              255,
              255,
              255,
            ),
            bufferedColor: Color.fromARGB(
              60,
              255,
              255,
              255,
            ),
            backgroundColor: Color.fromARGB(
              20,
              255,
              255,
              255,
            ),
          ),
        ),
      ),
    );
  }

  void _showHideControls() {
    if (_showHideTimer != null && _showHideTimer.isActive) {
      _showHideTimer.cancel();
      _showControls();
    } else {
      _showControls();
    }
  }

  void _showControls() {
    if (!_isClicked) {
      setState(() {
        _isClicked = true;
      });
    }
    _showHideTimer =
        new Timer(Duration(seconds: CONTROLS_DISPLAY_TIME_SEC), () {
      setState(() {
        _isClicked = false;
      });
    });
  }

  void _playPause() {
    _showHideControls();
    setState(() {
      widget.controller.value.isPlaying
          ? widget.controller.pause()
          : widget.controller.play();
    });
  }

  void _skipBack() {
    _showHideControls();
    final beginning = Duration(seconds: 0).inMilliseconds;
    final skip =
        (widget.controller.value.position - Duration(seconds: SKIP_BACK_SEC))
            .inMilliseconds;
    widget.controller.seekTo(Duration(milliseconds: math.max(skip, beginning)));
  }

  void _skipForward() {
    _showHideControls();
    final end = widget.controller.value.duration.inMilliseconds;
    final skip =
        (widget.controller.value.position + Duration(seconds: SKIP_FORWARD_SEC))
            .inMilliseconds;
    widget.controller.seekTo(Duration(milliseconds: math.min(skip, end)));
  }
}
