import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';

final soundEffectProvider = StateProvider((ref) => AudioCache());
