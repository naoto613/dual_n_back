import 'package:dual_n_back/models/game_setting.model.dart';
import 'package:dual_n_back/models/question_map.model.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import 'dart:math';

Future updateQuestion(
  GameSetting gameSetting,
  ValueNotifier<List<QuestionMap>> questionListState,
  ValueNotifier<bool> startState,
  ValueNotifier<bool> displayQuestionState,
  ValueNotifier<bool> displayJudgeFlgState,
  AudioCache soundEffect,
  ValueNotifier<QuestionMap> questionNowState,
  ValueNotifier<bool> disabledButtonState,
  int pictureSelect,
  List<int> answerPictureNumberList,
  ValueNotifier<List<int>> answerPictureNumbersState,
  ValueNotifier<bool> displaySelectPicturesState,
) async {
  final isTypeB = answerPictureNumberList.isNotEmpty;
  final newQuestion = QuestionMap(
    pictureNumber: Random().nextInt(gameSetting.numOfPictures) + pictureSelect,
    colorNumber: gameSetting.judgeColor ? Random().nextInt(3) : 0,
    positionNumber:
        gameSetting.judgePosition ? Random().nextInt(isTypeB ? 3 : 9) : 0,
    soundNumber: gameSetting.judgeSound ? Random().nextInt(3) : 0,
  );

  if (questionListState.value.length == gameSetting.numOfBacks) {
    if (!startState.value) {
      startState.value = true;
    }
  }
  questionListState.value.add(
    newQuestion,
  );
  // 手動更新の場合コメントアウトを外す
  // displayQuestionState.value = false;
  displayJudgeFlgState.value = false;

  if (isTypeB) {
    displaySelectPicturesState.value = true;

    List<int> answerPictureNumbers = answerPictureNumberList
        .where((int value) => value != questionListState.value[0].pictureNumber)
        .take(2)
        .toList();

    answerPictureNumbers.add(questionListState.value[0].pictureNumber);
    answerPictureNumbers.shuffle();

    answerPictureNumbersState.value = answerPictureNumbers;
  }

  await Future.delayed(
    const Duration(milliseconds: 300),
  );
  if (gameSetting.judgeSound) {
    soundEffect.play('sounds/next${newQuestion.soundNumber}.mp3',
        isNotification: true);
  } else {
    soundEffect.play('sounds/next.mp3', isNotification: true);
  }

  questionNowState.value = newQuestion;

  displayQuestionState.value = true;
  disabledButtonState.value = false;

  // 自動で消える
  await Future.delayed(
    const Duration(milliseconds: 1500),
  );
  displayQuestionState.value = false;
}
