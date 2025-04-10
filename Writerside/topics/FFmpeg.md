# FFmpeg

<tldr>
    A complete, cross-platform solution to record, 
    convert and stream audio and video.
</tldr>

[FFmpeg](https://en.wikipedia.org/wiki/FFmpeg) plays an 
important role of processing media files for StoryTailor.
StoryTailor uses FFmpeg to convert audio and video files.

FFmpeg is *not* available on mobile. FFmpeg used to be 
available on mobile platforms but the library which 
StoryTailor uses is retired, forcing StoryTailor to 
remove the library.

## Installation

### Windows
You can install FFmpeg only for StoryTailor or globally on 
your system.

To install through the StoryTailor settings, Go into the App
Settings, and you'll see the FFmpeg section which you can then 
click "Download & Install FFmpeg."

It is not recommended that you continue to install FFmpeg if 
you see the message "Error getting download size." It is 
recommended that you try again after 20–30 minutes and 
see if the message is still there.

StoryTailor downloads the latest GPL-licensed FFmpeg master build.

To install globally, Pick your favorite package manager and refer
to [gyan.dev FFmpeg builds](https://www.gyan.dev/ffmpeg/builds/).

### Linux

Install FFmpeg through your operating system's package manager.



### macOS
You can install FFmpeg on macOS using Homebrew by running 
`brew install ffmpeg`
