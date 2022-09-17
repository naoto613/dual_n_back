enum GameType {
  a,
  b,
}

extension GameTypeExtension on GameType {
  static final names = {
    GameType.a: 'a',
    GameType.b: 'b',
  };

  String get name => names[this]!;
}
