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

class GamePlayTypeAScreen extends HookConsumerWidget {
  const GamePlayTypeAScreen({super.key});

  static const routeName = '/game-play-type-a';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameSetting =
        ModalRoute.of(context)?.settings.arguments as GameSetting;

    final soundEffect = ref.read(soundEffectProvider);
    final pictureSelect = ref.read(pictureSelectProvider);

    final pictureSize = gameSetting.judgePosition
        ? MediaQuery.of(context).size.width * 0.29
        : MediaQuery.of(context).size.height * 0.35;

    final playCountState = useState<int>(0);
    final soundAnswerState = useState<bool>(false);
    final positionAnswerState = useState<bool>(false);
    final colorAnswerState = useState<bool>(false);
    final pictureAnswerState = useState<bool>(false);
    final hpState = useState<int>(10);

    final displayQuestionState = useState<bool>(false);
    final displayJudgeState = useState<bool>(false);
    final judgePositionState = useState<bool>(true);
    final judgeColorState = useState<bool>(true);
    final judgeSoundState = useState<bool>(true);
    final judgePictureState = useState<bool>(true);

    final disabledButtonState = useState<bool>(false);
    final startState = useState<bool>(false);
    final questionListState = useState<List<QuestionMap>>([]);
    final questionNowState = useState<QuestionMap>(const QuestionMap(
      pictureNumber: 0,
      colorNumber: 0,
      positionNumber: 0,
      soundNumber: 0,
    ));

    final dummyState = useState<List<int>>([]);

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

      if (gameSetting.judgeSound) {
        judgeSoundState.value = ((soundAnswerState.value &&
                    questionNowState.value.soundNumber == answer.soundNumber) ||
                (!soundAnswerState.value &&
                    questionNowState.value.soundNumber != answer.soundNumber))
            ? true
            : false;

        if (!judgeSoundState.value) {
          judgeFalseFlg = true;
          hpDamagedValue++;
        }
      }

      if (gameSetting.judgePosition) {
        judgePositionState.value = ((positionAnswerState.value &&
                    questionNowState.value.positionNumber ==
                        answer.positionNumber) ||
                (!positionAnswerState.value &&
                    questionNowState.value.positionNumber !=
                        answer.positionNumber))
            ? true
            : false;

        if (!judgePositionState.value) {
          judgeFalseFlg = true;
          hpDamagedValue++;
        }
      }

      if (gameSetting.judgeColor) {
        judgeColorState.value = ((colorAnswerState.value &&
                    questionNowState.value.colorNumber == answer.colorNumber) ||
                (!colorAnswerState.value &&
                    questionNowState.value.colorNumber != answer.colorNumber))
            ? true
            : false;

        if (!judgeColorState.value) {
          judgeFalseFlg = true;
          hpDamagedValue++;
        }
      }

      judgePictureState.value = ((pictureAnswerState.value &&
                  questionNowState.value.pictureNumber ==
                      answer.pictureNumber) ||
              (!pictureAnswerState.value &&
                  questionNowState.value.pictureNumber != answer.pictureNumber))
          ? true
          : false;

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

      pictureAnswerState.value = false;

      if (gameSetting.judgeSound) {
        soundAnswerState.value = false;
      }
      if (gameSetting.judgePosition) {
        positionAnswerState.value = false;
      }
      if (gameSetting.judgeColor) {
        colorAnswerState.value = false;
      }

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
        [],
        dummyState, // 仮
        disabledButtonState, // 仮
      );

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
            [],
            dummyState, // 仮
            disabledButtonState, // 仮
          );

          await Future.delayed(
            const Duration(milliseconds: 2000),
          );
        }

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
                  const SizedBox(height: 10),
                  // 問題画像
                  QuestionPicture(
                    gameSetting,
                    gameSetting.judgePosition,
                    displayQuestionState,
                    questionNowState,
                    pictureSize,
                    false,
                  ),
                  const SizedBox(height: 25),
                  Center(
                    child: SizedBox(
                        height: 110,
                        width: 195,
                        child: startState.value
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      _selectAnswerButton(
                                        context,
                                        pictureAnswerState,
                                        '写真',
                                        checkAnswer,
                                        disabledButtonState.value,
                                        displayJudgeState.value,
                                        judgePictureState.value,
                                      ),
                                      const SizedBox(width: 15),
                                      gameSetting.judgePosition
                                          ? _selectAnswerButton(
                                              context,
                                              positionAnswerState,
                                              '位置',
                                              checkAnswer,
                                              disabledButtonState.value,
                                              displayJudgeState.value,
                                              judgePositionState.value,
                                            )
                                          : Container()
                                    ],
                                  ),
                                  gameSetting.judgeSound ||
                                          gameSetting.judgeColor
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Row(
                                            children: [
                                              gameSetting.judgeColor
                                                  ? _selectAnswerButton(
                                                      context,
                                                      colorAnswerState,
                                                      '色',
                                                      checkAnswer,
                                                      disabledButtonState.value,
                                                      displayJudgeState.value,
                                                      judgeColorState.value,
                                                    )
                                                  : const SizedBox(width: 90),
                                              gameSetting.judgeSound
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 15),
                                                      child:
                                                          _selectAnswerButton(
                                                        context,
                                                        soundAnswerState,
                                                        '音',
                                                        checkAnswer,
                                                        disabledButtonState
                                                            .value,
                                                        displayJudgeState.value,
                                                        judgeSoundState.value,
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectAnswerButton(
    BuildContext context,
    ValueNotifier<bool> answerState,
    String displayWord,
    Function checkAnswer,
    bool disabled,
    bool displayJudgeFlg,
    bool valueJudgeFlg,
  ) {
    return SizedBox(
      height: 50,
      width: 90,
      child: ElevatedButton(
        onPressed: () => disabled
            ? null
            : {
                answerState.value = !answerState.value,
                // checkAnswer(),
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: displayJudgeFlg
              ? valueJudgeFlg
                  ? Colors.yellow.shade700
                  : Colors.purple.shade700
              : answerState.value
                  ? Colors.green.shade400
                  : Colors.blueGrey.shade600.withOpacity(0.5),
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
            color: answerState.value
                ? Colors.white
                : Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
