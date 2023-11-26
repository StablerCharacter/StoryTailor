# Audio

**Implementation Stage:** Partially Implemented

If configured, StoryTailor automatically converts unsupported 
audio containers for platforms.

You can turn on or off the automatic audio container 
conversion in the Preferences (a.k.a. App Settings).

You can change default audio containers to convert to 
for platforms.

**Note:** StoryTailor considers what format is supported 
by the file extension, the audio container.

## "Advanced Management"
The advanced management page of an audio file is accessible 
by clicking/tapping on an audio file in the Assets page and 
then "Advanced Management." This page allows you to convert 
your audio file to a specific format for a specific platform, 
and it also allows you to view detailed information about 
your audio file. Such as its codec, its bitrate, and its 
sample rate.

### Converting formats
To convert audio formats manually, You can manage it through 
the Advanced Management page of the audio file.

## Choosing Audio Formats
If used right, Audio formats and codecs can save your 
(and your players') storage space while maintaining 
quality.

### The compressed formats
The formats such as MP3, MP4, and AAC are a compressed audio 
format that will save space, especially for an audio file with 
a long duration, such as music and ambience sounds, for example.

### WAVE
This is a format to store uncompressed audio data. So, 
`.wav` files should be used to store shorter sounds, 
like sound effects.

## Windows
StoryTailor considered that Windows supports the following 
audio container and codecs:

| File Extension | Format                             |
|----------------|------------------------------------|
| .asf, .wma     | Advanced Streaming Format (ASF)    |
| .aac, .adts    | Audio Data Transport Stream (ADTS) |
| .wav           | WAVE                               |
| .mp3           | MP3                                |
| .m4a, .mov     | MPEG-4                             |


## macOS
StoryTailor considered that macOS supports the following 
audio containers:

| File Extension     | Format       |
|--------------------|--------------|
| .aac, .adts        | AAC          |
| .aif, .aiff, .aifc | AIFF/AIFC    |
| .mp3               | MPEG Layer 3 |
| .m4a               | MPEG 4 Audio |
| .wav               | WAVE         |


## Linux
StoryTailor considered that Linux supports the following 
audio containers:

| File Extension | Format              |
|----------------|---------------------|
| .aac           | AAC                 |
| .m4a           | MPEG-4              |
| .mp3           | MP3                 |
| .oga, .ogg     | Vorbis              |
| .spx           | Speex               |
| .opus          | Opus                |
| .flac          | FLAC                |
| .wma           | Windows Media Audio |
| .wav           | WAVE                |

## iOS
StoryTailor considered that iOS supports the following 
audio containers:

| File Extension | Format |
|----------------|--------|
| .aac           | AAC    |
| .m4a           | MPEG-4 |
| .mp3           | MP3    |
| .wav           | WAVE   |


## Android
Android supports the following formats:

| File Extension | Format |
|----------------|--------|
| .m4a           | MPEG-4 |
| .mp3           | MP3    |
| .ogg           | Vorbis |
| .wav           | WAVE   |
| .flac          | FLAC   |
| .aac           | AAC    |

## Extra Information
StoryTailor uses `FFmpeg` to process audio files. The `FFmpeg` 
StoryTailor uses is licensed under GNU GPL v2.

## See Also
- [AudioPlayers Troubleshooting Guide on Formats/Encoding](https://github.com/bluefireteam/audioplayers/blob/main/troubleshooting.md#supported-formats--encodings)
- [Media Formats supported by Android](https://developer.android.com/guide/topics/media/media-formats.html)
- [Audio Formats supported by iOS \(Retired Document\)](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/MultimediaPG/UsingAudio/UsingAudio.html#//apple_ref/doc/uid/TP40009767-CH2-SW33)
- [Audio Formats supported by Mac OS X \(10.5\)](https://developer.apple.com/library/archive/documentation/MusicAudio/Conceptual/CoreAudioOverview/SupportedAudioFormatsMacOSX/SupportedAudioFormatsMacOSX.html#//apple_ref/doc/uid/TP40003577-CH7-SW1)
- [Media Formats supported by Windows](https://learn.microsoft.com/en-us/windows/win32/medfound/supported-media-formats-in-media-foundation)
- [List of Audio Types for Linux](https://gstreamer.freedesktop.org/documentation/plugin-development/advanced/media-types.html?gi-language=c#table-of-audio-types)
