# Audio Codecs

StoryTailor comes with a few choices of codecs you can choose to use 
which these codecs should work in most platforms.

The codecs you can choose to convert to are:

- PCM (High Quality)
- PCM (Low Quality)
- ADPCM
- MP3
- Advanced Audio Coding (AAC)

## PCM
To simplify, PCM is an audio codec with no compression, which 
StoryTailor has 2 PCM codecs for you to choose from. The High 
Quality version, and the Low quality. Which the quality of the 
audio file will also depend on which platform your game targets.

PCM (HQ) is a signed 16-bit PCM , and the PCM (LQ) is an 
unsigned 8-bit PCM codec.

## ADPCM
ADPCM is an older lossy compression format that is suitable 
for low-bandwidth applications. It can achieve a compression 
ratio of about 4:1 with acceptable quality.

> StoryTailor uses the "ADPCM Microsoft" version of the ADPCM 
> format.

## MP3
The popular and widely supported MP3 we all know and love. 
MP3 (or MPEG-1 Audio Layer III) is a lossy audio format that 
I have no idea why you should choose over the AAC codec.

## AAC
AAC (or Advanced Audio Coding) is a lossy audio format like 
MP3 but with greater efficiency.
