# StoryTailor
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=flat-square)](https://flame-engine.org)
[![Bitrise Status](https://img.shields.io/bitrise/d866c030-bb66-4d1f-8d81-9b646b2174cd/master?token=Wmdit24tQ22RPU9iJB0mUg&style=flat-square)](https://app.bitrise.io/app/d866c030-bb66-4d1f-8d81-9b646b2174cd)

Create stories easily.

StoryTailor is developed with Dart and Flutter, 
with Flame inside.

It is highly not recommended to use StoryTailor 
for production uses right now, as breaking changes 
might occur even every commit.

## Contributing
Please see [contributing.md](contributing.md)

## Build Instructions

For the most basic setup, You'll only need Flutter.
To install, Follow the [Flutter documentation](https://docs.flutter.dev/get-started/install).

To build, Run `flutter build [target]`. For example, `flutter build windows`, `flutter build linux`, 
and `flutter build apk`.

### AppImage (Linux)

To create an AppImage package, There are two prerequisites, GNU make, and `appimagetool`.

You should be able to install `make` from your Linux package manager. And for `appimagetool`, 
You can download the AppImage to compile your AppImage on [the `appimagetool` GitHub 
Releases](https://github.com/AppImage/appimagetool/releases/tag/continuous)

There are two Makefile targets:

- `appimage`: Normal AppImage packaging for x86_64 architecture
- `appimage-signed`: Signed AppImage packaging for x86_64 architecture

But before you run either of the targets, you *might* need to specify the `APPIMAGE_TOOL` variable
if the `appimagetool` isn't in your PATH variable. You can set the variable through the `make` 
command. If for example your `appimagetool` is inside your Downloads folder, you can run 
`make appimage-signed APPIMAGE_TOOL=~/Downloads/appimagetool-x86_64.AppImage` to make a signed 
package.

The `appimage-signed` target will use your default secret key to sign the AppImage. If you wish to
select a different key, You can run `make appimage-resources` to make the `AppDir` folder, then run
something similar to this pattern:
`ARCH=x86_64 [path to appimagetool] -g -s --sign-key [Your GPG key ID] AppDir`

To build for arm64 (aarch64), You will need to do a similar thing to the above paragraph, which is to
run `make appimage-resources` then run `ARCH=aarch64 [path to appimagetool] -g AppDir` (Add parameters
as needed, such as `-s` to sign)
