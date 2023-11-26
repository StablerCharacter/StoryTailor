import 'package:fluent_ui/fluent_ui.dart';
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
    FluentThemeData theme = FluentTheme.of(context);

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ToggleSwitch(
            checked: generateForPlatform,
            onChanged: (newValue) {
              setState(() {
                generateForPlatform = newValue;
              });
            },
            content: const Text("Generate audio for this platform"),
          ),
          Row(
            children: [
              Text("Codec", style: theme.typography.bodyStrong),
              const Gap(10),
              ComboBox(
                items: const [
                  ComboBoxItem(value: "pcm_alaw", child: Text("PCM A-law")),
                  ComboBoxItem(value: "pcm_mulaw", child: Text("PCM mu-law")),
                  ComboBoxItem(
                      value: "pcm_s16le", child: Text("PCM signed 16-bit")),
                  ComboBoxItem(
                      value: "pcm_s24le", child: Text("PCM signed 24-bit")),
                  ComboBoxItem(
                      value: "pcm_s32le", child: Text("PCM signed 32-bit")),
                  ComboBoxItem(
                      value: "pcm_u8", child: Text("PCM unsigned 8-bit")),
                  ComboBoxItem(
                      value: "adpcm_ima_wav", child: Text("ADPCM IMA WAV")),
                  ComboBoxItem(
                      value: "adpcm_ms", child: Text("ADPCM Microsoft")),
                  ComboBoxItem(value: "mp3", child: Text("MP3")),
                  ComboBoxItem(value: "aac", child: Text("AAC")),
                ],
                onChanged: generateForPlatform ? (value) {} : null,
              ),
            ],
          ),
          const Gap(10),
          Row(
            children: [
              Button(
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
