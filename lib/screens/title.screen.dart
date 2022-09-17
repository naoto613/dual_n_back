import 'package:dual_n_back/providers/records.provider.dart';
import 'package:dual_n_back/providers/sound.provider.dart';
import 'package:dual_n_back/screens/game_setting.screen.dart';
import 'package:dual_n_back/services/initial_app_setting.service.dart';
import 'package:dual_n_back/widgets/background.widget.dart';
import 'package:dual_n_back/widgets/select_picture_modal.widget.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class TitleScreen extends HookConsumerWidget {
  const TitleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundEffect = ref.read(soundEffectProvider);
    final height = MediaQuery.of(context).size.height;
    final todayRecord = ref.watch(todayRecordProvider);
    final previousRecords = ref.read(previousRecordsProvider);
    final weekday = DateTime.now().weekday;

    const weekDayList = ['月', '火', '水', '木', '金', '土', '日'];

    // 初期設定
    initialAppSetting(ref);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          const Background('assets/images/title_back.jpg'),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Text(
                      'N-Back-Picture',
                      style: TextStyle(
                        fontFamily: 'YuseiMagic',
                        fontSize: height > 610 ? 40 : 36,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 5
                          ..color = Colors.blueGrey.shade800,
                      ),
                    ),
                    Text(
                      'N-Back-Picture',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: height > 610 ? 40 : 36,
                        fontFamily: 'YuseiMagic',
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: <Color>[
                              Colors.yellow.shade400,
                              Colors.yellow.shade600,
                              Colors.yellow.shade700,
                            ],
                          ).createShader(
                            const Rect.fromLTWH(
                              0.0,
                              100.0,
                              250.0,
                              70.0,
                            ),
                          ),
                        shadows: const [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(8.0, 8.0),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  'ワーキングメモリーUP',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.yellow.shade200,
                    fontFamily: 'YuseiMagic',
                    fontSize: height > 610 ? 25 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: height > 610 ? 80 : 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _moveToSettingButton(
                        context,
                        soundEffect,
                      ),
                      const SizedBox(height: 20),
                      _selectPictureButton(
                        context,
                        soundEffect,
                      ),
                      const SizedBox(height: 50),
                      Row(
                        children: [
                          const Spacer(),
                          _recordBlock(
                              previousRecords.sixDaysAgoRecord,
                              weekDayList[
                                  weekday - 6 <= 0 ? weekday : weekday - 7]),
                          _recordBlock(
                              previousRecords.fiveDaysAgoRecord,
                              weekDayList[weekday - 5 <= 0
                                  ? weekday + 1
                                  : weekday - 6]),
                          _recordBlock(
                              previousRecords.fourDaysAgoRecord,
                              weekDayList[weekday - 4 <= 0
                                  ? weekday + 2
                                  : weekday - 5]),
                          _recordBlock(
                              previousRecords.threeDaysAgoRecord,
                              weekDayList[weekday - 3 <= 0
                                  ? weekday + 3
                                  : weekday - 4]),
                          _recordBlock(
                              previousRecords.twoDaysAgoRecord,
                              weekDayList[weekday - 2 <= 0
                                  ? weekday + 4
                                  : weekday - 3]),
                          _recordBlock(
                              previousRecords.yesterdayRecord,
                              weekDayList[weekday - 1 <= 0
                                  ? weekday + 5
                                  : weekday - 2]),
                          _recordBlock(todayRecord, weekDayList[weekday - 1]),
                          const Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _moveToSettingButton(
    BuildContext context,
    AudioCache soundEffect,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: SizedBox(
        height: 50,
        width: 150,
        child: ElevatedButton(
          onPressed: () => {
            soundEffect..play('sounds/tap.mp3', isNotification: true),
            Navigator.of(context).pushNamed(
              GameSettingScreen.routeName,
            ),
          },
          style: ElevatedButton.styleFrom(
            elevation: 8,
            backgroundColor: Colors.blue.shade100,
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
            'ゲームへ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'YuseiMagic',
              color: Colors.blue.shade900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectPictureButton(
    BuildContext context,
    AudioCache soundEffect,
  ) {
    return SizedBox(
      height: 45,
      width: 130,
      child: ElevatedButton(
        onPressed: () {
          soundEffect.play('sounds/tap.mp3', isNotification: true);

          AwesomeDialog(
            context: context,
            dialogType: DialogType.noHeader,
            headerAnimationLoop: false,
            dismissOnTouchOutside: true,
            dismissOnBackKeyPress: true,
            showCloseIcon: true,
            animType: AnimType.scale,
            width: MediaQuery.of(context).size.width * .86 > 400 ? 400 : null,
            body: const SelectPictureModal(),
          ).show();
        },
        style: ElevatedButton.styleFrom(
          elevation: 8,
          backgroundColor: Colors.green.shade200,
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
          '写真選択',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'YuseiMagic',
            color: Colors.green.shade800,
          ),
        ),
      ),
    );
  }

  Widget _recordBlock(int record, String displayWord) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        children: [
          Text(
            displayWord,
            style: const TextStyle(
              fontFamily: 'YuseiMagic',
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.only(bottom: 2),
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              color: getColorByRecord(record).shade100,
              border: Border.all(
                color: Colors.black,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                record.toString(),
                style: const TextStyle(
                  fontFamily: 'YuseiMagic',
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  MaterialColor getColorByRecord(int record) {
    if (record < 20) {
      return Colors.purple;
    }

    if (record < 40) {
      return Colors.blue;
    }

    if (record < 60) {
      return Colors.green;
    }

    if (record < 80) {
      return Colors.orange;
    }

    return Colors.red;
  }
}
