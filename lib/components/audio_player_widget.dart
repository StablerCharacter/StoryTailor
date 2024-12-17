import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:storytailor/utils/time_utility.dart';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget(this.audioSource, {super.key});

  final Source audioSource;

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  AudioPlayer audioPlayer = AudioPlayer();
  Duration audioPlayerPosition = const Duration();
  Future<Duration?>? audioSourceDuration;
  IconData playPauseButtonIcon = Icons.play_arrow;

  @override
  void initState() {
    super.initState();

    audioSourceDuration = audioPlayer.setSource(widget.audioSource).then((_) {
      return audioPlayer.getDuration();
    });
    audioPlayer.onPositionChanged.listen((newDuration) {
      if (!mounted) return;
      setState(() {
        audioPlayerPosition = newDuration;
      });
    });
    audioPlayer.onPlayerComplete.listen((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(playPauseButtonIcon),
          onPressed: () {
            switch (audioPlayer.state) {
              case PlayerState.playing:
                playPauseButtonIcon = Icons.play_arrow;
                audioPlayer.pause();
                break;
              case PlayerState.paused:
                playPauseButtonIcon = Icons.pause;
                audioPlayer.resume();
                break;
              case PlayerState.stopped:
              case PlayerState.completed:
                playPauseButtonIcon = Icons.pause;
                audioPlayer.play(widget.audioSource);
                break;
              case PlayerState.disposed:
                break;
            }
            setState(() {});
          },
        ),
        const Gap(10),
        FutureBuilder(
          future: audioSourceDuration,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                if (kDebugMode) {
                  print(snapshot.error);
                }
                return const Text("An error occurred.");
              }

              if (!snapshot.hasData) {
                return Container();
              }

              Duration duration = snapshot.data!;

              return Row(
                children: [
                  Slider(
                    value: audioPlayerPosition.inSeconds.toDouble(),
                    max: duration.inSeconds.toDouble(),
                    onChanged: (newValue) {
                      audioPlayer.seek(Duration(seconds: newValue.toInt()));
                    },
                    onChangeStart: (startValue) {
                      audioPlayer.pause();
                      playPauseButtonIcon = Icons.play_arrow;
                      setState(() {});
                    },
                    onChangeEnd: (newValue) {
                      audioPlayer.resume();
                      playPauseButtonIcon = Icons.pause;
                      setState(() {});
                    },
                  ),
                  const Gap(10),
                  Text(
                      "${durationToDisplay(audioPlayerPosition)}/${durationToDisplay(duration)}"),
                ],
              );
            }

            return const CircularProgressIndicator();
          },
        ),
      ],
    );
  }
}
