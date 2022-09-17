import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class QuitModal extends HookConsumerWidget {
  const QuitModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Theme(
      data: Theme.of(context).copyWith(
        dialogBackgroundColor: Colors.white.withOpacity(0.0),
      ),
      child: const SimpleDialog(
        children: <Widget>[
          Center(
            child: Text(
              '離脱中。。。',
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontFamily: 'YuseiMagic',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
