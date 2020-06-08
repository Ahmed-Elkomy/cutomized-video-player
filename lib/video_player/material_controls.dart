import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';
import 'package:videoplayerdemo/video_player/constants.dart';
import 'package:videoplayerdemo/video_player/progress_colors.dart';
import 'package:videoplayerdemo/video_player/utils.dart';

import 'material_progress_bar.dart';

class MaterialControls extends StatefulWidget {
  final VideoPlayerController controller;
  final bool isFullScreen;
  MaterialControls({this.controller, this.isFullScreen});
  @override
  _MaterialControlsState createState() => _MaterialControlsState();
}

class _MaterialControlsState extends State<MaterialControls> {
  bool _isClicked;
  Timer _showHideTimer;
  Timer _progressBarTimer;
  double _latestVolume;

  final barHeight = 48.0;
  final marginSize = 5.0;

  @override
  void initState() {
    _isClicked = true;
    _showHideControls();
    //This is to show the updates on the porgress bar every sec
    _progressBarTimer = Timer.periodic(Duration(seconds: 1), (Timer t) {
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
    final orientation = MediaQuery.of(context).orientation;
//    final barHeight = orientation == Orientation.portrait ? 30.0 : 47.0;
    final buttonPadding = orientation == Orientation.portrait ? 16.0 : 24.0;
    if (widget.controller.value.hasError) {
      return Center(
        child: Icon(
          Icons.error,
          color: Colors.white,
          size: 42,
        ),
      );
    }

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
                _buildBackButton(barHeight, buttonPadding),
                _buildHitArea(),
                _buildBottomBar(
                  context,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildBackButton(double barHeight, double buttonPadding) {
    return GestureDetector(
      onTap: () {
        _showHideControls();
        Navigator.pop(context);
      },
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          height: barHeight,
          margin: EdgeInsets.only(
              top: marginSize, right: marginSize, left: marginSize),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              height: barHeight,
              padding: EdgeInsets.only(
                left: buttonPadding,
                right: buttonPadding,
              ),
              color: Theme.of(context).dialogBackgroundColor,
              child: Icon(
                Icons.close,
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
        child: Center(
          child: GestureDetector(
            onTap: _playPause,
            child: widget.controller.value.isBuffering
                ? CircularProgressIndicator()
                : Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).dialogBackgroundColor,
                      borderRadius: BorderRadius.circular(48.0),
                    ),
                    child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Icon(
                          widget.controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          size: 32,
                        )),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      height: barHeight,
      color: Theme.of(context).dialogBackgroundColor,
      child: Row(
        children: <Widget>[
          _buildPosition(),
          _buildProgressBar(),
          _buildMuteButton(widget.controller),
          _buildExpandButton(),
        ],
      ),
    );
  }

  Widget _buildPosition() {
    final position = widget.controller.value != null &&
            widget.controller.value.position != null
        ? widget.controller.value.position
        : Duration.zero;
    final duration = widget.controller.value != null &&
            widget.controller.value.duration != null
        ? widget.controller.value.duration
        : Duration.zero;

    return Padding(
      padding: EdgeInsets.only(left: 24, right: 24.0),
      child: Text(
        '${formatDuration(position)} / ${formatDuration(duration)}',
        style: TextStyle(
          fontSize: 14.0,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: 20.0),
        child: MaterialVideoProgressBar(
          widget.controller,
          onDragStart: () {
            _showHideControls();
          },
          onDragEnd: () {
            _showHideControls();
          },
          colors: ProgressColors(
              playedColor: Theme.of(context).accentColor,
              handleColor: Theme.of(context).accentColor,
              bufferedColor: Theme.of(context).backgroundColor,
              backgroundColor: Theme.of(context).disabledColor),
        ),
      ),
    );
  }

  GestureDetector _buildMuteButton(VideoPlayerController controller) {
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
      child: ClipRect(
        child: Container(
          child: Container(
            height: barHeight,
            padding: EdgeInsets.only(
              left: 8.0,
              right: 8.0,
            ),
            child: Icon(
              (controller.value != null && controller.value.volume > 0)
                  ? Icons.volume_up
                  : Icons.volume_off,
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildExpandButton() {
    return GestureDetector(
      onTap: () {
        widget.isFullScreen ? smallScreenButton() : fullScreenButton();
      },
      child: Container(
        height: barHeight,
        margin: EdgeInsets.only(right: 12.0),
        padding: EdgeInsets.only(
          left: 8.0,
          right: 8.0,
        ),
        child: Center(
          child: Icon(
            widget.isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
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
}
