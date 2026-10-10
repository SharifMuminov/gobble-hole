# Sounds

These `.wav` files are procedural placeholders. `tool/gen_sounds.dart` synthesises them in code from sine waves and filtered noise, so no recordings or third-party samples are used. To regenerate them all, run `dart run tool/gen_sounds.dart` from the project root. To use a final sound, replace any file with one of the same name: `Sfx` (`lib/game/audio/sfx.dart`) loads them by name. A sound that is missing or fails to load is skipped silently, and the rest keep working.
