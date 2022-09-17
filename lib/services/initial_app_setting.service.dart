import 'package:dual_n_back/models/previous_records.model.dart';
import 'package:dual_n_back/providers/game_settings.provider.dart';
import 'package:dual_n_back/providers/picture_select.provider.dart';
import 'package:dual_n_back/providers/records.provider.dart';
import 'package:dual_n_back/providers/sound.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void initialAppSetting(WidgetRef ref) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // 画像選択
  final pictureSelect = prefs.getInt('pictureSelect') ?? 1;
  ref.read(pictureSelectProvider.notifier).state = pictureSelect;

  // 記録
  final todayRecord = prefs.getInt('todayRecord') ?? 0;
  ref.read(todayRecordProvider.notifier).state = todayRecord;

  final previousRecord =
      ref.read(previousRecordsProvider.notifier).state = PreviousRecords(
    yesterdayRecord: prefs.getInt('yesterdayRecord') ?? 0,
    twoDaysAgoRecord: prefs.getInt('twoDaysAgoRecord') ?? 0,
    threeDaysAgoRecord: prefs.getInt('threeDaysAgoRecord') ?? 0,
    fourDaysAgoRecord: prefs.getInt('fourDaysAgoRecord') ?? 0,
    fiveDaysAgoRecord: prefs.getInt('fiveDaysAgoRecord') ?? 0,
    sixDaysAgoRecord: prefs.getInt('sixDaysAgoRecord') ?? 0,
  );

  // 日時
  final String todayString = DateFormat('yyyy/MM/dd').format(DateTime.now());

  if (prefs.getString('dataString') == null) {
    prefs.setString('dataString', todayString);
  }
  final String dataString = prefs.getString('dataString') ?? todayString;

  if (dataString != todayString) {
    // 日にちが変わっていた場合
    prefs.setString('dataString', todayString);

    prefs.setInt('todayRecord', 0);
    prefs.setInt('yesterdayRecord', todayRecord);
    prefs.setInt('twoDaysAgoRecord', previousRecord.yesterdayRecord);
    prefs.setInt('threeDaysAgoRecord', previousRecord.twoDaysAgoRecord);
    prefs.setInt('fourDaysAgoRecord', previousRecord.threeDaysAgoRecord);
    prefs.setInt('fiveDaysAgoRecord', previousRecord.fourDaysAgoRecord);
    prefs.setInt('sixDaysAgoRecord', previousRecord.fiveDaysAgoRecord);

    ref.read(todayRecordProvider.notifier).state = 0;
    ref.read(previousRecordsProvider.notifier).state = PreviousRecords(
      yesterdayRecord: todayRecord,
      twoDaysAgoRecord: previousRecord.yesterdayRecord,
      threeDaysAgoRecord: previousRecord.twoDaysAgoRecord,
      fourDaysAgoRecord: previousRecord.threeDaysAgoRecord,
      fiveDaysAgoRecord: previousRecord.fourDaysAgoRecord,
      sixDaysAgoRecord: previousRecord.fiveDaysAgoRecord,
    );
  }

  // 設定
  ref.read(isNormalTypeProvider.notifier).state =
      prefs.getBool('isNormalType') ?? true;
  ref.read(numOfPicturesProvider.notifier).state =
      prefs.getInt('numOfPictures') ?? 6;
  ref.read(numOfBacksProvider.notifier).state = prefs.getInt('numOfBacks') ?? 1;
  ref.read(judgeColorProvider.notifier).state =
      prefs.getBool('judgeColor') ?? false;
  ref.read(judgePositionProvider.notifier).state =
      prefs.getBool('judgePosition') ?? false;
  ref.read(judgeSoundProvider.notifier).state =
      prefs.getBool('judgeSound') ?? false;

  ref.read(soundEffectProvider.notifier).state.loadAll([
    'sounds/next.mp3',
    'sounds/next0.mp3',
    'sounds/next1.mp3',
    'sounds/next2.mp3',
    'sounds/tap.mp3',
    'sounds/true.mp3',
    'sounds/false.mp3',
    'sounds/ready.mp3',
  ]);
}
