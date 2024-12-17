import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class PlatformSpecificAudioConversion extends StatefulWidget {
  const PlatformSpecificAudioConversion({super.key});

  @override
  State<PlatformSpecificAudioConversion> createState() =>
      _PlatformSpecificAudioConversionState();
}

class _PlatformSpecificAudioConversionState
    extends State<PlatformSpecificAudioConversion> {
  bool generateForPlatform = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            value: generateForPlatform,
            onChanged: (newValue) {
              setState(() {
                generateForPlatform = newValue;
              });
            },
            title: const Text("Generate audio for this platform"),
          ),
          Row(
            children: [
              Text("Codec", style: theme.textTheme.bodyLarge),
              const Gap(10),
              DropdownMenu(
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: "pcm_alaw", label: "PCM A-law"),
                  DropdownMenuEntry(value: "pcm_mulaw", label: "PCM mu-law"),
                  DropdownMenuEntry(
                      value: "pcm_s16le", label: "PCM signed 16-bit"),
                  DropdownMenuEntry(
                      value: "pcm_s24le", label: "PCM signed 24-bit"),
                  DropdownMenuEntry(
                      value: "pcm_s32le", label: "PCM signed 32-bit"),
                  DropdownMenuEntry(
                      value: "pcm_u8", label: "PCM unsigned 8-bit"),
                  DropdownMenuEntry(
                      value: "adpcm_ima_wav", label: "ADPCM IMA WAV"),
                  DropdownMenuEntry(
                      value: "adpcm_ms", label: "ADPCM Microsoft"),
                  DropdownMenuEntry(value: "mp3", label: "MP3"),
                  DropdownMenuEntry(value: "aac", label: "AAC"),
                ],
                onSelected: generateForPlatform ? (value) {} : null,
              ),
            ],
          ),
          const Gap(10),
          Row(
            children: [
              OutlinedButton(
                onPressed: () {},
                child: const Text("Revert"),
              ),
              const Gap(5),
              FilledButton(
                onPressed: () {},
                child: const Text("Apply"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
