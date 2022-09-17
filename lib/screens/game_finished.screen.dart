import 'package:dual_n_back/providers/records.provider.dart';
import 'package:dual_n_back/providers/sound.provider.dart';
import 'package:dual_n_back/screens/game_setting.screen.dart';
import 'package:dual_n_back/widgets/background.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameFinishedScreen extends HookConsumerWidget {
  const GameFinishedScreen({Key? key}) : super(key: key);
  static const routeName = '/game-finished';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playCount = ModalRoute.of(context)?.settings.arguments as int;
    final soundEffect = ref.read(soundEffectProvider);
    final todayRecord = ref.read(todayRecordProvider);
    final updatedTodayRecord = playCount + todayRecord;
    final todayRecordState = useState(0);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        todayRecordState.value = updatedTodayRecord;
        SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.setInt('todayRecord', updatedTodayRecord);
        ref.read(todayRecordProvider.notifier).state = updatedTodayRecord;
      });
      return null;
    }, const []);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'リザルト',
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Colors.grey[900]?.withOpacity(0.8),
        ),
        body: Stack(
          children: <Widget>[
            const Background('assets/images/back_black.png'),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    '解答数',
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'YuseiMagic',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "$playCount 回",
                    style: const TextStyle(
                      fontSize: 26,
                      fontFamily: 'YuseiMagic',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    '今日の解答数',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'YuseiMagic',
                      color: Colors.blueGrey.shade100,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${todayRecordState.value} 回",
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'YuseiMagic',
                      color: Colors.blueGrey.shade100,
                    ),
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        soundEffect.play('sounds/tap.mp3',
                            isNotification: true);
                        Navigator.popUntil(
                          context,
                          ModalRoute.withName(GameSettingScreen.routeName),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 8,
                        backgroundColor: Colors.blueGrey,
                        shadowColor: Colors.black45,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(),
                      ),
                      child: Text(
                        '戻る',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.button,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
