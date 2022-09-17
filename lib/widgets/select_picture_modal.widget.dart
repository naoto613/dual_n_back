import 'package:audioplayers/audioplayers.dart';
import 'package:dual_n_back/providers/picture_select.provider.dart';
import 'package:dual_n_back/providers/sound.provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectPictureModal extends HookConsumerWidget {
  const SelectPictureModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundEffect = ref.read(soundEffectProvider);
    final pictureSelect = ref.read(pictureSelectProvider);

    final pictureSelectState = useState<int>(pictureSelect);

    return Padding(
      padding: const EdgeInsets.only(
        top: 5,
        left: 20,
        right: 20,
        bottom: 25,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 25,
            ),
            child: Text(
              '画像の種類を選択',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'SawarabiGothic',
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
            ),
            width: double.infinity,
            child: Column(
              children: [
                _selectPictureRow(
                  ref,
                  pictureSelectState,
                  'シンプル',
                  1,
                  soundEffect,
                ),
                _selectPictureRow(
                  ref,
                  pictureSelectState,
                  'ミラ',
                  9,
                  soundEffect,
                ),
                _selectPictureRow(
                  ref,
                  pictureSelectState,
                  'ふうか',
                  17,
                  soundEffect,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectPictureRow(
    WidgetRef ref,
    ValueNotifier<int> pictureSelectState,
    String target,
    int targetNumber,
    AudioCache soundEffect,
  ) {
    return Row(
      children: [
        Checkbox(
          value: pictureSelectState.value == targetNumber,
          onChanged: (bool? checked) async {
            if (checked!) {
              soundEffect.play('sounds/tap.mp3', isNotification: true);
              pictureSelectState.value = targetNumber;
              SharedPreferences prefs = await SharedPreferences.getInstance();

              prefs.setInt('pictureSelect', targetNumber);
              ref.read(pictureSelectProvider.notifier).state = targetNumber;
            }
          },
        ),
        const SizedBox(width: 15),
        SizedBox(
          width: 90,
          child: Text(
            target,
            style: const TextStyle(
              fontSize: 20,
              fontFamily: 'YuseiMagic',
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
