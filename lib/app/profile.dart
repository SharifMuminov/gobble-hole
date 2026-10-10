import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../game/model/hole_skin.dart';

/// Everything saved between sessions: progress, wallet, lives, settings.
class PlayerProfile extends ChangeNotifier {
  PlayerProfile._(this._prefs) {
    level = _prefs.getInt(_kLevel) ?? 1;
    coins = _prefs.getInt(_kCoins) ?? 100;
    _lives = _prefs.getInt(_kLives) ?? maxLives;
    _livesSince = DateTime.fromMillisecondsSinceEpoch(
      _prefs.getInt(_kLivesSince) ?? DateTime.now().millisecondsSinceEpoch,
    );
    sound = _prefs.getBool(_kSound) ?? true;
    haptics = _prefs.getBool(_kHaptics) ?? true;
    skinId = _prefs.getString(_kSkin) ?? HoleSkin.classic.id;
    owned = {...?_prefs.getStringList(_kOwned), HoleSkin.classic.id};
    final stars = _prefs.getStringList(_kStars) ?? const [];
    for (var i = 0; i < stars.length; i++) {
      this.stars[i + 1] = int.tryParse(stars[i]) ?? 0;
    }
  }

  static Future<PlayerProfile> load() async =>
      PlayerProfile._(await SharedPreferences.getInstance());

  final SharedPreferences _prefs;

  static const maxLives = 5;
  static const lifeEvery = Duration(minutes: 20);
  static const refillPrice = 250;

  static const _kLevel = 'level';
  static const _kCoins = 'coins';
  static const _kLives = 'lives';
  static const _kLivesSince = 'livesSince';
  static const _kSound = 'sound';
  static const _kHaptics = 'haptics';
  static const _kSkin = 'skin';
  static const _kOwned = 'ownedSkins';
  static const _kStars = 'stars';

  /// The next level to play.
  late int level;
  late int coins;
  late bool sound;
  late bool haptics;
  late String skinId;
  late Set<String> owned;

  /// Best stars per finished level.
  final Map<int, int> stars = {};

  late int _lives;
  late DateTime _livesSince;

  HoleSkin get skin => HoleSkin.byId(skinId);

  /// Lives, counting the ones that regenerated while away.
  int get lives {
    _regen();
    return _lives;
  }

  /// Time until the next life (null when full).
  Duration? get nextLifeIn {
    _regen();
    if (_lives >= maxLives) return null;
    final next = _livesSince.add(lifeEvery);
    final left = next.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  void _regen() {
    if (_lives >= maxLives) return;
    final now = DateTime.now();
    final gained = now.difference(_livesSince).inSeconds ~/ lifeEvery.inSeconds;
    if (gained <= 0) return;
    _lives = math.min(maxLives, _lives + gained);
    _livesSince = _lives >= maxLives ? now : _livesSince.add(lifeEvery * gained);
    _saveLives();
  }

  void _saveLives() {
    _prefs.setInt(_kLives, _lives);
    _prefs.setInt(_kLivesSince, _livesSince.millisecondsSinceEpoch);
  }

  void loseLife() {
    _regen();
    if (_lives <= 0) return;
    if (_lives == maxLives) _livesSince = DateTime.now();
    _lives--;
    _saveLives();
    notifyListeners();
  }

  bool refillLives() {
    if (!spend(refillPrice)) return false;
    _lives = maxLives;
    _livesSince = DateTime.now();
    _saveLives();
    notifyListeners();
    return true;
  }

  void addCoins(int amount) {
    coins += amount;
    _prefs.setInt(_kCoins, coins);
    notifyListeners();
  }

  bool spend(int amount) {
    if (coins < amount) return false;
    coins -= amount;
    _prefs.setInt(_kCoins, coins);
    notifyListeners();
    return true;
  }

  void completeLevel(int number, int starCount) {
    stars[number] = math.max(stars[number] ?? 0, starCount);
    if (number >= level) level = number + 1;
    _prefs.setInt(_kLevel, level);
    _prefs.setStringList(_kStars, [
      for (var i = 1; i < level; i++) '${stars[i] ?? 0}',
    ]);
    notifyListeners();
  }

  void setSound(bool on) {
    sound = on;
    _prefs.setBool(_kSound, on);
    notifyListeners();
  }

  void setHaptics(bool on) {
    haptics = on;
    _prefs.setBool(_kHaptics, on);
    notifyListeners();
  }

  /// Buys (if needed) and equips a skin. False when coins are short.
  bool useSkin(HoleSkin skin) {
    if (!owned.contains(skin.id)) {
      if (!spend(skin.price)) return false;
      owned.add(skin.id);
      _prefs.setStringList(_kOwned, owned.toList());
    }
    skinId = skin.id;
    _prefs.setString(_kSkin, skin.id);
    notifyListeners();
    return true;
  }
}
