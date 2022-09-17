import 'package:dual_n_back/providers/sound.provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ReadyModal extends HookConsumerWidget {
  final int numOfBacks;

  const ReadyModal(this.numOfBacks, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundEffect = ref.read(soundEffectProvider);

    final displayFlg1 = useState<bool>(false);
    final displayFlg2 = useState<bool>(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(
          const Duration(milliseconds: 500),
        );
        displayFlg1.value = true;
        soundEffect.play('sounds/ready.mp3', isNotification: true);
        await Future.delayed(
          const Duration(milliseconds: 1200),
        );
        displayFlg2.value = true;
      });
      return null;
    }, const []);

    return Theme(
      data: Theme.of(context)
          .copyWith(dialogBackgroundColor: Colors.white.withOpacity(0.0)),
      child: SimpleDialog(
        children: <Widget>[
          Center(
            child: Column(
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: displayFlg1.value ? 1 : 0,
                  child: Text(
                    '$numOfBacks-Back',
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontFamily: 'YuseiMagic',
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: displayFlg2.value ? 1 : 0,
                  child: const Text(
                    'Start!',
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                      fontFamily: 'YuseiMagic',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
