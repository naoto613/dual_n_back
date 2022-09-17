import 'package:dual_n_back/models/question_map.model.dart';
import 'package:dual_n_back/models/game_setting.model.dart';
import 'package:flutter/material.dart';

class QuestionPicture extends StatelessWidget {
  final GameSetting gameSetting;
  final bool positionFlg;
  final ValueNotifier<bool> displayQuestionState;
  final ValueNotifier<QuestionMap> questionNowState;
  final double pictureSize;
  final bool isTypeB;

  const QuestionPicture(
    this.gameSetting,
    this.positionFlg,
    this.displayQuestionState,
    this.questionNowState,
    this.pictureSize,
    this.isTypeB, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: positionFlg ? 5.0 : 0,
        left: 5.0,
        right: 5.0,
      ),
      height: positionFlg && isTypeB
          ? MediaQuery.of(context).size.width * 0.3 + 10
          : isTypeB
              ? MediaQuery.of(context).size.width * 0.6
              : MediaQuery.of(context).size.width * 0.9 + 30,
      child: Stack(
        children: [
          positionFlg && !isTypeB
              ? SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.3 + 10,
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: Colors.grey.shade800,
                              width: 0.4,
                            ),
                            right: BorderSide(
                              color: Colors.grey.shade800,
                              width: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
          positionFlg && !isTypeB
              ? SizedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.width * 0.3 + 10,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey.shade800,
                              width: 0.4,
                            ),
                            bottom: BorderSide(
                              color: Colors.grey.shade800,
                              width: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: displayQuestionState.value ? 1 : 0,
            child: Column(
              mainAxisAlignment: positionFlg
                  ? [0, 1, 2].contains(questionNowState.value.positionNumber)
                      ? MainAxisAlignment.start
                      : [3, 4, 5]
                              .contains(questionNowState.value.positionNumber)
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.end
                  : MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: positionFlg
                      ? [0, 3, 6]
                              .contains(questionNowState.value.positionNumber)
                          ? MainAxisAlignment.start
                          : [
                              1,
                              4,
                              7
                            ].contains(questionNowState.value.positionNumber)
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.end
                      : MainAxisAlignment.center,
                  children: [
                    Container(
                      height: pictureSize,
                      width: pictureSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: gameSetting.judgeColor
                            ? Border.all(
                                color: questionNowState.value.colorNumber == 0
                                    ? Colors.red
                                    : questionNowState.value.colorNumber == 1
                                        ? Colors.blue
                                        : Colors.green,
                                width: 7,
                              )
                            : null,
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/${questionNowState.value.pictureNumber}.jpg',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
