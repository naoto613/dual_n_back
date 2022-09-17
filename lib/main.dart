import 'package:audioplayers/audioplayers.dart';
import 'package:dual_n_back/screens/game_finished.screen.dart';
import 'package:dual_n_back/screens/game_play_type_a.screen.dart';
import 'package:dual_n_back/screens/game_play_type_b.screen.dart';
import 'package:dual_n_back/screens/game_setting.screen.dart';
import 'package:dual_n_back/screens/title.screen.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late AudioPlayer bgm;
  final AudioCache soundEffect = AudioCache();

  @override
  void initState() {
    super.initState();
    Future(() async {
      bgm = await soundEffect.loop('sounds/bgm.mp3',
          volume: 0.1, isNotification: true);
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      bgm.pause();
    } else if (state == AppLifecycleState.resumed) {
      bgm.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'N-Back-Picture',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        canvasColor: Colors.grey.shade100,
        fontFamily: 'SawarabiGothic',
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: OpenUpwardsPageTransitionsBuilder(),
          },
        ),
        textTheme: ThemeData.light().textTheme.copyWith(
              bodyText1: const TextStyle(
                fontSize: 26,
                fontFamily: 'YuseiMagic',
                color: Colors.white,
              ),
              bodyText2: const TextStyle(
                fontSize: 23,
                fontFamily: 'YuseiMagic',
                color: Colors.white,
              ),
              button: const TextStyle(
                fontSize: 22.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => const TitleScreen(),
        GameSettingScreen.routeName: (BuildContext context) =>
            const GameSettingScreen(),
        GamePlayTypeAScreen.routeName: (BuildContext context) =>
            const GamePlayTypeAScreen(),
        GamePlayTypeBScreen.routeName: (BuildContext context) =>
            const GamePlayTypeBScreen(),
        GameFinishedScreen.routeName: (BuildContext context) =>
            const GameFinishedScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (ctx) => const TitleScreen(),
        );
      },
    );
  }
}
