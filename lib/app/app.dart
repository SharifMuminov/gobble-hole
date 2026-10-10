import 'package:flutter/material.dart';

import '../ui/home_screen.dart';
import 'profile.dart';
import 'theme.dart';

class HoleItApp extends StatelessWidget {
  const HoleItApp({super.key, required this.profile});

  final PlayerProfile profile;

  @override
  Widget build(BuildContext context) {
    return ProfileScope(
      profile: profile,
      child: MaterialApp(
        title: 'Gobble Hole',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}

/// Makes the [PlayerProfile] available below and rebuilds on changes.
class ProfileScope extends InheritedNotifier<PlayerProfile> {
  const ProfileScope({super.key, required PlayerProfile profile, required super.child})
    : super(notifier: profile);

  static PlayerProfile of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ProfileScope>()!.notifier!;

  static PlayerProfile read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<ProfileScope>()!.notifier!;
}
