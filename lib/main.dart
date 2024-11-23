import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  VideoPlayerController? controller;

  void _incrementCounter() async {
    setState(() {
      controller = VideoPlayerController.networkUrl(
          Uri.parse("https://live5.mobion.vn/test2310/index.m3u8"),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          formatHint: VideoFormat.hls);
    });

    await controller?.initialize();
    controller?.addListener(update);
    controller?.play();
  }

  Duration? duration;
  Timer? timer;
  DateTime? _timeStart;
  Duration watch = Duration.zero;

  void update() {
    print(controller?.value.position);
    print('isBuffering ${controller?.value.isBuffering}');
    if (controller?.value.buffered.isNotEmpty == true) {
      print(
          'isBuffering ${controller?.value.buffered.last.start} - ${controller?.value.buffered.last.end}');
    }

    DateTime current = DateTime.now();

    if (_timeStart == null) {
      _timeStart = current;
    }

    watch += current.difference(_timeStart!);
    _timeStart = current;
    print(watch);

    duration = controller!.value.position;
    if (controller?.value.position == Duration.zero) {
      timer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          duration = Duration(seconds: (duration!.inSeconds - 1));
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Center(
              child: controller != null
                  ? SizedBox(
                      height: 350,
                      width: MediaQuery.sizeOf(context).width,
                      child: VideoPlayer(controller!))
                  : ElevatedButton(
                      onPressed: () {
                        _incrementCounter();
                      },
                      child: const Text('PlayStream'))),
          ElevatedButton(
              onPressed: () {
                timer = Timer.periodic(
                  Duration(milliseconds: 200),
                  (timer) {
                    duration = Duration(
                        milliseconds: (duration!.inMilliseconds - 200));
                  },
                );
                controller?.pause();
              },
              child: Text('PAUSE')),
          ElevatedButton(
              onPressed: () {
                controller?.play();
              },
              child: Text('Play'))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await controller?.pause();

          controller?.play();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
