import 'package:dual_n_back/models/previous_records.model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final todayRecordProvider = StateProvider((ref) => 0);
final previousRecordsProvider = StateProvider((ref) => const PreviousRecords(
    yesterdayRecord: 0,
    twoDaysAgoRecord: 0,
    threeDaysAgoRecord: 0,
    fourDaysAgoRecord: 0,
    fiveDaysAgoRecord: 0,
    sixDaysAgoRecord: 0));
