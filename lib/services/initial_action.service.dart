import 'package:dual_n_back/models/game_setting.model.dart';
import 'package:dual_n_back/widgets/ready_modal.widget.dart';
import 'package:flutter/material.dart';

Future initialAction(
  BuildContext context,
  GameSetting gameSetting,
) async {
  showDialog<int>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return ReadyModal(gameSetting.numOfBacks);
    },
  );
  await Future.delayed(
    const Duration(milliseconds: 3200),
  );
  Navigator.pop(context);
}
