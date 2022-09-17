import 'package:flutter/material.dart';

class TopStatus extends StatelessWidget {
  final int hp;
  final int playCount;

  const TopStatus(
    this.hp,
    this.playCount, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _displayData(
            '残',
            "$hp/10",
          ),
          const SizedBox(width: 15),
          _displayData(
            '回数',
            '$playCount',
          ),
        ],
      ),
    );
  }

  Widget _displayData(
    String text,
    String data,
  ) {
    return SizedBox(
      height: 50,
      width: 100,
      child: Row(
        children: <Widget>[
          Text(
            "$text: ",
            style: const TextStyle(
              fontSize: 20,
              fontFamily: 'YuseiMagic',
              color: Colors.white,
            ),
          ),
          Text(
            data,
            style: const TextStyle(
              fontSize: 20,
              fontFamily: 'YuseiMagic',
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
