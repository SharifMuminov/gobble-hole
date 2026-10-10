import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';
import 'app/profile.dart';
import 'game/audio/sfx.dart';
import 'game/render/sprite_atlas.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final profile = await PlayerProfile.load();
  Sfx.enabled = profile.sound;
  profile.addListener(() => Sfx.enabled = profile.sound);

  await Future.wait([Sfx.init(), SpriteAtlas.load()]);
  runApp(HoleItApp(profile: profile));
}
