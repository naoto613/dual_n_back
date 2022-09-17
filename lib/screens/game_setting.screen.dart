import 'package:dual_n_back/environment/training_settings.dart';
import 'package:dual_n_back/models/game_setting.model.dart';
import 'package:dual_n_back/providers/game_settings.provider.dart';
import 'package:dual_n_back/providers/sound.provider.dart';
import 'package:dual_n_back/screens/game_play_type_a.screen.dart';
import 'package:dual_n_back/screens/game_play_type_b.screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameSettingScreen extends HookConsumerWidget {
  const GameSettingScreen({Key? key}) : super(key: key);

  static const routeName = '/game-setting';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundEffect = ref.read(soundEffectProvider);
    final gameType = ref.read(isNormalTypeProvider) ? 'DNB' : '脳トレ';
    final numOfPicturesString = ref.read(numOfPicturesProvider).toString();
    final numOfBacksString = ref.read(numOfBacksProvider).toString();
    final judgeColorString = ref.read(judgeColorProvider) ? 'あり' : 'なし';
    final judgePositionString = ref.read(judgePositionProvider) ? 'あり' : 'なし';
    final judgeSoundString = ref.read(judgeSoundProvider) ? 'あり' : 'なし';

    final gameTypeState = useState<String>(gameType);
    final numOfPicturesState = useState<String>(numOfPicturesString);
    final numOfBacksState = useState<String>(numOfBacksString);
    final judgeColorState = useState<String>(judgeColorString);
    final judgePositionState = useState<String>(judgePositionString);
    final judgeSoundState = useState<String>(judgeSoundString);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ゲーム設定'),
        centerTitle: true,
        backgroundColor: Colors.grey[900]?.withOpacity(0.8),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/back_black.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Column(
                          children: <Widget>[
                            _settingLabel('タイプ'),
                            _settingLabel('写真の種類'),
                            _settingLabel('バック数'),
                            _settingLabel('色'),
                            _settingLabel('位置'),
                            _settingLabel('音'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 28),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: SizedBox(
                          width: 130,
                          child: Column(
                            children: <Widget>[
                              _valueSelect(
                                gameTypeChoices,
                                gameTypeState,
                              ),
                              _valueSelect(
                                numOfPicturesChoices,
                                numOfPicturesState,
                              ),
                              _valueSelect(
                                numOfBacksChoices,
                                numOfBacksState,
                              ),
                              _valueSelect(
                                judgeChoices,
                                judgeColorState,
                              ),
                              _valueSelect(
                                judgeChoices,
                                judgePositionState,
                              ),
                              gameTypeState.value != 'DNB'
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 15),
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                          top: 3,
                                          right: 27,
                                        ),
                                        height: 35,
                                        child: const Text(
                                          'なし',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontFamily: 'YuseiMagic',
                                          ),
                                        ),
                                      ),
                                    )
                                  : _valueSelect(
                                      judgeChoices,
                                      judgeSoundState,
                                    )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 50,
                    ),
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          soundEffect.play('sounds/tap.mp3',
                              isNotification: true);

                          final isNormalType = gameTypeState.value == 'DNB';
                          final numOfPictures =
                              int.parse(numOfPicturesState.value);
                          final numOfBacks = int.parse(numOfBacksState.value);
                          final judgeColor = judgeColorState.value == 'あり';
                          final judgePosition =
                              judgePositionState.value == 'あり';
                          final judgeSound =
                              isNormalType && judgeSoundState.value == 'あり';

                          prefs.setBool('isNormalType', isNormalType);
                          prefs.setInt('numOfPictures', numOfPictures);
                          prefs.setInt('numOfBacks', numOfBacks);
                          prefs.setBool('judgeColor', judgeColor);
                          prefs.setBool('judgePosition', judgePosition);
                          prefs.setBool('judgeSound', judgeSound);

                          final gameSetting = GameSetting(
                            numOfPictures: numOfPictures,
                            numOfBacks: numOfBacks,
                            judgeColor: judgeColor,
                            judgePosition: judgePosition,
                            judgeSound: judgeSound,
                          );

                          isNormalType
                              ? Navigator.of(context).pushNamed(
                                  GamePlayTypeAScreen.routeName,
                                  arguments: gameSetting,
                                )
                              : Navigator.of(context).pushNamed(
                                  GamePlayTypeBScreen.routeName,
                                  arguments: gameSetting,
                                );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 8,
                          backgroundColor: Colors.cyan.shade700,
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
                          '開始！',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.button,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingLabel(
    String label,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: SizedBox(
        height: 35,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 24,
            fontFamily: 'YuseiMagic',
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _valueSelect(
    List<String> wordList,
    ValueNotifier<String> state,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Container(
        width: 90,
        height: 35,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: DropdownButton(
          value: state.value,
          items: wordList.map((String word) {
            return DropdownMenuItem(
              value: word,
              child: Text(
                word,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontFamily: 'YuseiMagic',
                ),
              ),
            );
          }).toList(),
          onChanged: (targetSubject) {
            state.value = targetSubject as String;
          },
        ),
      ),
    );
  }
}
