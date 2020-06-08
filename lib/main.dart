import 'package:flutter/material.dart';
import 'package:videoplayerdemo/video_player/advanced_video_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Video Player Demo",
        theme: ThemeData(primaryColor: Colors.lightBlueAccent),
        home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: FlatButton(
            child: Text("Start Video Demo"),
            onPressed: () {
              _playVideo(context);
            },
          ),
        ),
      ),
    );
  }
}

void _playVideo(BuildContext context) {
  String link =
      'https://player.vimeo.com/external/420007558.hd.mp4?s=ee97ea501635f356b27e214c88e31a85a0ff3b0f&profile_id=175';
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return AdvancedVideoPlayer(link: link);
  }));
}
