import 'dart:io';

import 'package:ffmpeg_helper/ffmpeg_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:path/path.dart' as p;
import 'package:storytailor/db/key_value_database.dart';
import 'package:storytailor/utils/assets_utility.dart';
import 'package:storytailor/utils/size_unit_conversion.dart';

class AdvancedAudioFileConfig extends StatefulWidget {
  const AdvancedAudioFileConfig(this.audioFile,
      {super.key, this.updateCallback});

  final File audioFile;
  final Function()? updateCallback;

  @override
  State<AdvancedAudioFileConfig> createState() =>
      _AdvancedAudioFileConfigState();
}

class _AdvancedAudioFileConfigState extends State<AdvancedAudioFileConfig> {
  int platformTabIndex = 0;
  KeyValueDatabase? metadataDb;
  late Future<MediaInformation?> mediaInfo;
  String initialValue = "";
  String? codecValue;
  bool isChanged = false;

  static List<String> canConvertTo = [
    "pcm_s16le",
    "pcm_u8",
    "adpcm_ms",
    "mp3",
    "aac"
  ];

  @override
  void initState() {
    super.initState();

    File metadataFile = getMetadataFile(widget.audioFile);
    if (metadataFile.existsSync()) {
      metadataDb = KeyValueDatabase.loadFromFile(metadataFile);
    }
    mediaInfo =
        FFMpegHelper.instance.runProbe(widget.audioFile.path).then((value) {
      if (canConvertTo.contains(value?.getStreams().firstOrNull?.getCodec())) {
        setState(() {
          codecValue = value!.getStreams().first.getCodec();
          initialValue = codecValue!;
        });
      }
      return value;
    });
  }

  String getFormat() {
    switch (codecValue!) {
      case "pcm_s16le":
      case "pcm_u8":
      case "adpcm_ms":
        return ".wav";
      case "mp3":
        return ".mp3";
      case "aac":
        return ".aac";
      default:
        return "";
    }
  }

  void applyChanges() async {
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    if (codecValue == null) {
      return;
    }
    late BuildContext dialogContext;
    String outputFilePath =
        "${p.dirname(widget.audioFile.path)}/${p.basenameWithoutExtension(widget.audioFile.path)}${getFormat()}";
    FFMpegHelper.instance.runAsync(
      FFMpegCommand(
        inputs: [
          FFMpegInput.asset(
            Platform.isAndroid
                ? '"${widget.audioFile.path}"'
                : widget.audioFile.path,
          )
        ],
        args: [
          const OverwriteArgument(),
          const LogLevelArgument(LogLevel.debug),
          CustomArgument([
            "-acodec",
            codecValue!,
          ]),
        ],
        outputFilepath:
            Platform.isAndroid ? '"$outputFilePath"' : outputFilePath,
      ),
      onComplete: (file) {
        Navigator.pop(dialogContext);
        if (file == null) {
          ScaffoldMessenger.of(dialogContext).showSnackBar(
            SnackBar(
              content: Text(appLocal.reimportError),
            ),
          );
          return;
        }
        widget.audioFile.delete();
        if (widget.updateCallback != null) {
          widget.updateCallback!();
        }
        ScaffoldMessenger.of(dialogContext).showSnackBar(
          SnackBar(
            content: Text(appLocal.assetReimported),
          ),
        );
      },
    );

    if (!context.mounted) {
      return;
    }

    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) {
        dialogContext = context;
        return AlertDialog(
          title: Text(appLocal.reimporting),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(appLocal.reimportDoNotCloseApp),
              const Gap(10),
              const LinearProgressIndicator(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocal.advancedManagement),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder(
                  future: mediaInfo,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      MediaInformation data = snapshot.data!;
                      List<StreamInformation> streams = data.getStreams();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(appLocal.bitrate(
                              SizeUnitConversion.bytesToAppropriateUnits(
                                  int.parse(data.getBitrate() ?? "0")))),
                          Text(appLocal.format(data.getFormat() ?? "")),
                          Text(appLocal.fileSize(
                              SizeUnitConversion.bytesToAppropriateUnits(
                                  int.parse(data.getSize() ?? "0")))),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: streams.length,
                            itemBuilder: (context, index) {
                              StreamInformation stream = streams[index];
                              if (stream.getType() != "audio") {
                                return Container();
                              }
                              return ListTile(
                                title: Text(appLocal.audioStreamNo(
                                    stream.getIndex() ?? "Unknown")),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(appLocal.sampleRate(
                                        stream.getSampleRate() ?? "")),
                                    Text(appLocal
                                        .codecTeller(stream.getCodec() ?? "")),
                                    Text(appLocal.bitrate(SizeUnitConversion
                                        .bytesToAppropriateUnits(int.parse(
                                            stream.getBitrate() ?? "0"))))
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    }

                    return Container(
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator());
                  },
                ),
                Text(
                  appLocal.audioSettings,
                  style: theme.textTheme.titleLarge,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appLocal.wordCodec,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const Gap(5),
                    DropdownMenu(
                      dropdownMenuEntries: const [
                        DropdownMenuEntry(
                          value: "pcm_s16le",
                          label: "PCM (High Quality)",
                        ),
                        DropdownMenuEntry(
                          value: "pcm_u8",
                          label: "PCM (Low Quality)",
                        ),
                        DropdownMenuEntry(
                          value: "adpcm_ms",
                          label: "ADPCM",
                        ),
                        DropdownMenuEntry(
                          value: "mp3",
                          label: "MP3",
                        ),
                        DropdownMenuEntry(
                          value: "aac",
                          label: "AAC",
                        ),
                      ],
                      enableFilter: false,
                      controller: TextEditingController(text: codecValue),
                      onSelected: (newValue) => setState(() {
                        isChanged =
                            newValue != codecValue && newValue != initialValue;
                        codecValue = newValue;
                      }),
                    ),
                    const Gap(10),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: isChanged
                              ? () {
                                  setState(() {
                                    codecValue = initialValue;
                                    isChanged = false;
                                  });
                                }
                              : null,
                          child: Text(appLocal.revert),
                        ),
                        const Gap(5),
                        FilledButton(
                          onPressed: isChanged ? applyChanges : null,
                          child: Text(appLocal.reimport),
                        ),
                      ],
                    ),
                  ],
                )
                // I decided that it is not necessary for now.
                // Text("Platform Specific Versions", style: theme.typography.subtitle),
                // SizedBox(
                //   height: 300,
                //   child: TabView(
                //     currentIndex: platformTabIndex,
                //     onChanged: (newIndex) {
                //       setState(() {
                //         platformTabIndex = newIndex;
                //       });
                //     },
                //     tabs: [
                //       Tab(
                //         icon: const Icon(LineIcons.windows),
                //         text: const Text("Windows"),
                //         body: Container(
                //           color: theme.menuColor,
                //           child: const PlatformSpecificAudioConversion(),
                //         ),
                //       ),
                //       Tab(
                //         text: const Text("macOS"),
                //         body: Container(
                //           color: theme.menuColor,
                //         ),
                //       ),
                //       Tab(
                //         icon: const Icon(LineIcons.linux),
                //         text: const Text("Linux"),
                //         body: Container(
                //           color: theme.menuColor,
                //         ),
                //       ),
                //       Tab(
                //         icon: const Icon(LineIcons.android),
                //         text: const Text("Android"),
                //         body: Container(
                //           color: theme.menuColor,
                //         ),
                //       ),
                //       Tab(
                //         text: const Text("iOS"),
                //         body: Container(
                //           color: theme.menuColor,
                //         ),
                //       ),
                //     ],
                //     tabWidthBehavior: TabWidthBehavior.sizeToContent,
                //     closeButtonVisibility: CloseButtonVisibilityMode.never,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
