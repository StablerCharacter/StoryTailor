---
title: Audio
description: Reference information about audio files
---

Audio-related technical reference.

Underneath, StoryTailor uses the [`audioplayers`](https://pub.dev/packages/audioplayers) package.

## Supported File Formats

StoryTailor considers what platform supports which audio 
format by looking at the file extension (the container format)

### Windows 

StoryTailor considers that Windows supports the following audio 
files:

| File Extension | Format                             |
|----------------|------------------------------------|
| .asf, .wma     | Advanced Streaming Format (ASF)    |
| .aac, .adts    | Audio Data Transport Stream (ADTS) |
| .wav           | WAVE                               |
| .mp3           | MP3                                |
| .m4a, .mov     | MPEG-4                             |

### macOS

StoryTailor considers that macOS supports the following audio 
files:

| File Extension     | Format        |
|--------------------|---------------|
| .aac, .adts        | AAC           |
| .aif, .aiff, .aifc | AIFF/AIFC     |
| .mp3               | MPEG Layer 3  |
| .m4a               | MPEG 4 Audio  |
| .wav               | WAVE          |

### Linux

StoryTailor considers that Linux supports the following audio 
files:

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

### iOS

StoryTailor considers that iOS supports the following audio 
files:

| File Extension | Format |
|----------------|--------|
| .aac           | AAC    |
| .m4a           | MPEG-4 |
| .mp3           | MP3    |
| .wav           | WAVE   |

### Android

StoryTailor considers that Android supports the following audio 
files:

| File Extension | Format |
|----------------|--------|
| .m4a           | MPEG-4 |
| .mp3           | MP3    |
| .ogg           | Vorbis |
| .wav           | WAVE   |
| .flac          | FLAC   |
| .aac           | AAC    |

## Choosing Audio Formats

Compressed audio formats (such as MP3, AAC, and Vorbis) save space,
but will need to use more CPU power to decompress and play it.
So it is more ideal for things like background music.

Uncompressed formats (such as .wav files) is larger, but doesn't 
need to be decompressed before playing. So it is more ideal for 
shorter sounds (sound effects).

## Codecs

The StoryTailor FFmpeg integration allows you to convert your 
audio files into the following codecs:

- PCM (High Quality)
- PCM (Low Quality)
- ADPCM
- MP3
- Advanced Audio Coding (AAC)

### PCM

An uncompressed codec, which the final audio quality may also 
depend on the target platform.

PCM (HQ) is signed 16-bit PCM, and PCM (LQ) is an unsigned 
8-bit PCM codec.

### ADPCM

ADPCM is an older lossy compression format that is suitable for 
low-bandwidth applications. It can achieve a compression ratio of about 4:1 with acceptable quality.

StoryTailor uses the "ADPCM Microsoft" version of the ADPCM format.

### MP3

A well known and well supported compressed (lossy) audio format. 
In most cases, AAC is preferred.

### AAC

Advanced Audio Coding (AAC) is a newer compressed (lossy) audio 
format that is widely used on modern devices.

## See Also

- [AudioPlayers Troubleshooting Guide on Formats/Encoding](https://github.com/bluefireteam/audioplayers/blob/main/troubleshooting.md#supported-formats--encodings)
- [Media Formats supported by Android](https://developer.android.com/guide/topics/media/media-formats.html)
- [Audio Formats supported by iOS \(Retired Document\)](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/MultimediaPG/UsingAudio/UsingAudio.html#//apple_ref/doc/uid/TP40009767-CH2-SW33)
- [Audio Formats supported by Mac OS X \(10.5\)](https://developer.apple.com/library/archive/documentation/MusicAudio/Conceptual/CoreAudioOverview/SupportedAudioFormatsMacOSX/SupportedAudioFormatsMacOSX.html#//apple_ref/doc/uid/TP40003577-CH7-SW1)
- [Media Formats supported by Windows](https://learn.microsoft.com/en-us/windows/win32/medfound/supported-media-formats-in-media-foundation)
- [List of Audio Types for Linux](https://gstreamer.freedesktop.org/documentation/plugin-development/advanced/media-types.html?gi-language=c#table-of-audio-types)

