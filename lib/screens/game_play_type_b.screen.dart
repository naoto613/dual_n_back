import 'package:dual_n_back/models/game_setting.model.dart';
import 'package:dual_n_back/models/question_map.model.dart';
import 'package:dual_n_back/providers/picture_select.provider.dart';
import 'package:dual_n_back/providers/sound.provider.dart';
import 'package:dual_n_back/screens/game_finished.screen.dart';
import 'package:dual_n_back/screens/game_setting.screen.dart';
import 'package:dual_n_back/services/initial_action.service.dart';
import 'package:dual_n_back/services/update_question.service.dart';
import 'package:dual_n_back/widgets/background.widget.dart';
import 'package:dual_n_back/widgets/question_picture.widget.dart';
import 'package:dual_n_back/widgets/quit_modal.widget.dart';
import 'package:dual_n_back/widgets/top_status.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

class GamePlayTypeBScreen extends HookConsumerWidget {
  const GamePlayTypeBScreen({super.key});

  static const routeName = '/game-play-type-b';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameSetting =
        ModalRoute.of(context)?.settings.arguments as GameSetting;

    final soundEffect = ref.read(soundEffectProvider);
    final pictureSelect = ref.read(pictureSelectProvider);

    final List<int> answerPictureNumberList = [];

    for (int i = pictureSelect;
        i < gameSetting.numOfPictures + pictureSelect;
        i++) {
      answerPictureNumberList.add(i);
    }

    final pictureSize = gameSetting.judgePosition
        ? MediaQuery.of(context).size.width * 0.29
        : MediaQuery.of(context).size.width * 0.6;

    final playCountState = useState<int>(0);
    final positionAnswerState = useState<int>(0);
    final colorAnswerState = useState<int>(0);
    final pictureAnswerState = useState<int>(100);
    final hpState = useState<int>(10);

    final displayQuestionState = useState<bool>(false);
    final displaySelectPicturesState = useState<bool>(true);
    final displayJudgeState = useState<bool>(false);
    final judgePositionState = useState<bool>(true);
    final judgeColorState = useState<bool>(true);
    final judgePictureState = useState<bool>(true);
    final answerPictureNumbersState = useState<List<int>>([1, 2, 3]);

    final disabledButtonState = useState<bool>(false);
    final startState = useState<bool>(false);
    final questionListState = useState<List<QuestionMap>>([]);
    final questionNowState = useState<QuestionMap>(const QuestionMap(
      pictureNumber: 0,
      colorNumber: 0,
      positionNumber: 0,
      soundNumber: 0,
    ));

    final playingState = useState<bool>(true);

    Future checkAnswer() async {
      if (!playingState.value) {
        // ゲーム中断
        Navigator.popUntil(
          context,
          ModalRoute.withName(GameSettingScreen.routeName),
        );
        return;
      }

      disabledButtonState.value = true;

      final answer = questionListState.value.removeAt(0);

      bool judgeFalseFlg = false;
      int hpDamagedValue = 0;

      if (gameSetting.judgePosition) {
        judgePositionState.value =
            positionAnswerState.value - 1 == answer.positionNumber
                ? true
                : false;

        if (!judgePositionState.value) {
          judgeFalseFlg = true;
          hpDamagedValue++;
        }
      }

      if (gameSetting.judgeColor) {
        judgeColorState.value =
            colorAnswerState.value - 1 == answer.colorNumber ? true : false;

        if (!judgeColorState.value) {
          judgeFalseFlg = true;
          hpDamagedValue++;
        }
      }

      judgePictureState.value =
          pictureAnswerState.value == answer.pictureNumber ? true : false;

      if (!judgePictureState.value) {
        judgeFalseFlg = true;
        hpDamagedValue++;
      }

      if (judgeFalseFlg) {
        soundEffect.play('sounds/false.mp3', isNotification: true);
        hpState.value = hpState.value - hpDamagedValue <= 0
            ? 0
            : hpState.value - hpDamagedValue;
      } else {
        soundEffect.play('sounds/true.mp3', isNotification: true);
      }
      displayJudgeState.value = true;

      playCountState.value += 1;

      if (hpState.value == 0) {
        await Future.delayed(const Duration(milliseconds: 1500));
        // ゲーム終了
        Navigator.of(context).pushNamed(
          GameFinishedScreen.routeName,
          arguments: playCountState.value,
        );
        return;
      }

      await Future.delayed(const Duration(milliseconds: 600));

      displaySelectPicturesState.value = false;

      if (gameSetting.judgePosition) {
        positionAnswerState.value = 0;
      }
      if (gameSetting.judgeColor) {
        colorAnswerState.value = 0;
      }

      pictureAnswerState.value = 100;

      await updateQuestion(
        gameSetting,
        questionListState,
        startState,
        displayQuestionState,
        displayJudgeState,
        soundEffect,
        questionNowState,
        disabledButtonState,
        pictureSelect,
        answerPictureNumberList,
        answerPictureNumbersState,
        displaySelectPicturesState,
      );

      if (!playingState.value) {
        // ゲーム中断
        Navigator.popUntil(
          context,
          ModalRoute.withName(GameSettingScreen.routeName),
        );
        return;
      }

      if (!playingState.value) {
        // ゲーム中断
        Navigator.popUntil(
          context,
          ModalRoute.withName(GameSettingScreen.routeName),
        );
        return;
      }

      // 次の判定へ
      await Future.delayed(const Duration(milliseconds: 3000));
      checkAnswer();
    }

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await initialAction(
          context,
          gameSetting,
        );

        await Future.delayed(
          const Duration(milliseconds: 1100),
        );

        while (!startState.value) {
          await updateQuestion(
            gameSetting,
            questionListState,
            startState,
            displayQuestionState,
            displayJudgeState,
            soundEffect,
            questionNowState,
            disabledButtonState,
            pictureSelect,
            answerPictureNumberList,
            answerPictureNumbersState,
            displaySelectPicturesState,
          );

          await Future.delayed(
            const Duration(milliseconds: 2000),
          );
        }

        List<int> answerPictureNumbers = answerPictureNumberList
            .where((int value) =>
                value != questionListState.value[0].pictureNumber)
            .take(2)
            .toList();

        answerPictureNumbers.add(questionListState.value[0].pictureNumber);
        answerPictureNumbers.shuffle();

        answerPictureNumbersState.value = answerPictureNumbers;

        checkAnswer();
      });
      return null;
    }, const []);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            iconSize: 27,
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              disabledButtonState.value = true;
              playingState.value = false;
              showDialog<int>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const QuitModal();
                },
              );
            },
          ),
          automaticallyImplyLeading: false,
          title: Text(
            '${gameSetting.numOfBacks}-Back',
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontFamily: 'YuseiMagic',
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.grey[900]?.withOpacity(0.8),
        ),
        body: Stack(
          children: <Widget>[
            const Background(
              'assets/images/back_black.png',
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // 現在状況
                  TopStatus(
                    hpState.value,
                    playCountState.value,
                  ),
                  const SizedBox(height: 25),
                  // 問題画像
                  QuestionPicture(
                    gameSetting,
                    gameSetting.judgePosition,
                    displayQuestionState,
                    questionNowState,
                    pictureSize,
                    true,
                  ),
                  const SizedBox(height: 25),
                  Container(
                      height: MediaQuery.of(context).size.height *
                          (gameSetting.judgePosition && gameSetting.judgeColor
                              ? 0.4
                              : gameSetting.judgePosition ||
                                      gameSetting.judgeColor
                                  ? 0.3
                                  : 0.2),
                      width: MediaQuery.of(context).size.width * 0.95,
                      alignment: Alignment.center,
                      child: startState.value
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity:
                                      displaySelectPicturesState.value ? 1 : 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _selectPicture(
                                        context,
                                        MediaQuery.of(context).size.width *
                                            0.24,
                                        pictureAnswerState,
                                        answerPictureNumbersState.value[0],
                                        disabledButtonState.value,
                                        displayJudgeState.value,
                                        judgePictureState.value,
                                      ),
                                      const SizedBox(width: 15),
                                      _selectPicture(
                                        context,
                                        MediaQuery.of(context).size.width *
                                            0.24,
                                        pictureAnswerState,
                                        answerPictureNumbersState.value[1],
                                        disabledButtonState.value,
                                        displayJudgeState.value,
                                        judgePictureState.value,
                                      ),
                                      const SizedBox(width: 15),
                                      _selectPicture(
                                        context,
                                        MediaQuery.of(context).size.width *
                                            0.24,
                                        pictureAnswerState,
                                        answerPictureNumbersState.value[2],
                                        disabledButtonState.value,
                                        displayJudgeState.value,
                                        judgePictureState.value,
                                      ),
                                    ],
                                  ),
                                ),
                                gameSetting.judgePosition ||
                                        gameSetting.judgeColor
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 35),
                                        child: Column(
                                          children: [
                                            gameSetting.judgePosition
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      bottom: 10.0,
                                                    ),
                                                    child: _selectAnswerRow(
                                                      context,
                                                      positionAnswerState,
                                                      '位置',
                                                      disabledButtonState.value,
                                                      displayJudgeState.value,
                                                      judgePositionState.value,
                                                      ['左', '中', '右'],
                                                      [
                                                        Colors
                                                            .blueGrey.shade600,
                                                        Colors
                                                            .blueGrey.shade600,
                                                        Colors
                                                            .blueGrey.shade600,
                                                      ],
                                                    ),
                                                  )
                                                : Container(),
                                            gameSetting.judgeColor
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 10.0),
                                                    child: _selectAnswerRow(
                                                      context,
                                                      colorAnswerState,
                                                      '色',
                                                      disabledButtonState.value,
                                                      displayJudgeState.value,
                                                      judgeColorState.value,
                                                      ['赤', '青', '緑'],
                                                      [
                                                        Colors.red.shade200,
                                                        Colors.blue.shade200,
                                                        Colors.green.shade200,
                                                      ],
                                                    ),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      )
                                    : Container(),
                              ],
                            )
                          : Container()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectAnswerRow(
    BuildContext context,
    ValueNotifier<int> answerState,
    String text,
    bool disabled,
    bool displayJudgeFlg,
    bool valueJudgeFlg,
    List<String> displayWords,
    List<Color> buttonColors,
  ) {
    return Row(
      children: [
        Container(
          width: 60,
          alignment: Alignment.center,
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: _selectAnswerButton(
            context,
            answerState,
            1,
            disabled,
            displayJudgeFlg,
            valueJudgeFlg,
            displayWords[0],
            buttonColors[0],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: _selectAnswerButton(
            context,
            answerState,
            2,
            disabled,
            displayJudgeFlg,
            valueJudgeFlg,
            displayWords[1],
            buttonColors[1],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: _selectAnswerButton(
            context,
            answerState,
            3,
            disabled,
            displayJudgeFlg,
            valueJudgeFlg,
            displayWords[2],
            buttonColors[2],
          ),
        ),
      ],
    );
  }

  Widget _selectAnswerButton(
    BuildContext context,
    ValueNotifier<int> answerState,
    int changeValue,
    bool disabled,
    bool displayJudgeFlg,
    bool valueJudgeFlg,
    String displayWord,
    Color buttonColor,
  ) {
    return SizedBox(
      height: MediaQuery.of(context).size.width * 0.14,
      width: MediaQuery.of(context).size.width * 0.20,
      child: ElevatedButton(
        onPressed: () => disabled
            ? null
            : {
                answerState.value = changeValue,
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: displayJudgeFlg && answerState.value == changeValue
              ? valueJudgeFlg
                  ? Colors.yellow.shade700
                  : Colors.purple.shade700
              : answerState.value == changeValue
                  ? buttonColor
                  : buttonColor.withOpacity(0.5),
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
          displayWord,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'YuseiMagic',
            color: answerState.value == changeValue
                ? Colors.white
                : Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _selectPicture(
    BuildContext context,
    double pictureSize,
    ValueNotifier<int> answerState,
    int changeValue,
    bool disabled,
    bool displayJudgeFlg,
    bool valueJudgeFlg,
  ) {
    return GestureDetector(
      onTap: () => disabled
          ? {}
          : {
              answerState.value = changeValue,
              // checkAnswer(),
            },
      child: Stack(
        children: [
          Container(
            height: pictureSize,
            width: pictureSize,
            decoration: BoxDecoration(
              color: Colors.white,
              border: displayJudgeFlg && answerState.value == changeValue
                  ? Border.all(
                      width: 10,
                      color: valueJudgeFlg
                          ? Colors.yellow.shade700
                          : Colors.purple.shade700,
                    )
                  : null,
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/$changeValue.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          answerState.value == changeValue
              ? Container()
              : Container(
                  height: pictureSize,
                  width: pictureSize,
                  color: Colors.black26,
                ),
        ],
      ),
    );
  }
}
