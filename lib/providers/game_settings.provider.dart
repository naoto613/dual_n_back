import 'package:hooks_riverpod/hooks_riverpod.dart';

final isNormalTypeProvider = StateProvider((ref) => true);
final numOfPicturesProvider = StateProvider((ref) => 6);
final numOfBacksProvider = StateProvider((ref) => 1);
final judgeColorProvider = StateProvider((ref) => false);
final judgePositionProvider = StateProvider((ref) => false);
final judgeSoundProvider = StateProvider((ref) => false);
