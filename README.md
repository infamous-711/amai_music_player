# Amai Music Player
A sweet and simple music player.

NOTE: This is still a work-in-progress

## Required
- flutter
- flutter_rust_bridge_codegen (via `cargo`)
- System deps (OpenSUSE Tumbleweed) `TODO: Add instructions for other platforms`
  - gtk3-devel
  - gstreamer-devel
  - gstreamer-plugins-base-devel

## Build from source
```sh
flutter create . # Generate missing flutter specific files
flutter pub get # Get deps
flutter_rust_bridge_codegen generate # Generate flutter_rust_bridge files
dart run build_runner build -d # Generate riverpod files
flutter run
```
