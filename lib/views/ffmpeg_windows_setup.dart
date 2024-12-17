import 'dart:convert';

import 'package:ffmpeg_helper/ffmpeg_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:storytailor/utils/dialog_util.dart';
import 'package:storytailor/utils/size_unit_conversion.dart';

/// FFmpeg Setup Interface (only for Windows)
class FFmpegWindowsSetup extends StatefulWidget {
  const FFmpegWindowsSetup({super.key});

  @override
  State<FFmpegWindowsSetup> createState() => _FFmpegWindowsSetupState();
}

class _InstallationStep extends StatelessWidget {
  final Widget content;
  final List<Widget> buttons;
  final int stepNumber;
  final String stepName;

  const _InstallationStep({
    this.content = const SizedBox.shrink(),
    this.buttons = const [],
    this.stepNumber = 1,
    this.stepName = "",
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  shape: BoxShape.circle,
                ),
                child: Text(stepNumber.toString()),
              ),
              const Gap(10),
              Text(stepName, style: theme.textTheme.titleLarge),
            ],
          ),
          const Gap(10),
          content,
          const Gap(10),
          Row(
            children: buttons,
          ),
        ],
      ),
    );
  }
}

enum SubStepState { done, doing, planned, error }

class _CompletableSubStep extends StatelessWidget {
  final String stepName;
  final SubStepState state;
  final double? progress;

  const _CompletableSubStep(this.stepName, this.state, {this.progress});

  Widget getStepIcon(BuildContext context) {
    ThemeData theme = Theme.of(context);

    switch (state) {
      case SubStepState.planned:
        return Icon(
          Icons.more,
          color: theme.cardColor,
          size: 22,
        );
      case SubStepState.doing:
        return SizedBox.square(
          dimension: 22,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            value: progress,
          ),
        );
      case SubStepState.done:
        return Icon(
          Icons.check,
          color: Colors.green,
          size: 22,
        );
      case SubStepState.error:
        return Icon(
          Icons.close,
          color: Colors.red,
          size: 22,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        getStepIcon(context),
        const Gap(10),
        Text(stepName),
      ],
    );
  }
}

class _FFmpegWindowsSetupState extends State<FFmpegWindowsSetup> {
  ScrollController scrollController = ScrollController();
  Future<String>? ffmpegSize;
  FFMpegProgress? ffmpegInstallProgress;
  int stepNo = 1;

  Future<String> getFFmpegSize() async {
    http.Response latestFFmpegRelease = await http.get(
        Uri.parse(
            "https://api.github.com/repos/BtbN/FFmpeg-Builds/releases/latest"),
        headers: {
          "Accept": "application/vnd.github+json",
          "X-GitHub-Api-Version": "2022-11-28"
        });

    if (latestFFmpegRelease.statusCode == 200) {
      for (var asset in jsonDecode(latestFFmpegRelease.body)["assets"]) {
        if (asset["name"] == "ffmpeg-master-latest-win64-gpl.zip") {
          return SizeUnitConversion.bytesToAppropriateUnits(asset["size"]);
        }
      }
    }

    if (!context.mounted) {
      return "Error ${latestFFmpegRelease.statusCode}";
    }

    AppLocalizations appLocal = AppLocalizations.of(context)!;

    return appLocal.errorDownloadSize(latestFFmpegRelease.statusCode);
  }

  @override
  void initState() {
    super.initState();

    ffmpegSize = getFFmpegSize();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocal.installFFmpeg),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            Visibility(
              visible: stepNo == 1,
              child: _InstallationStep(
                stepName: appLocal.preparation,
                stepNumber: 1,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appLocal.ffmpegDescription),
                    FutureBuilder(
                      future: ffmpegSize,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Text(
                            appLocal.downloadSize(snapshot.data ?? "Unknown"),
                          );
                        }

                        return const CircularProgressIndicator();
                      },
                    ),
                  ],
                ),
                buttons: [
                  FilledButton(
                    onPressed: () {
                      FFMpegHelper.instance
                          .setupFFMpegOnWindows(
                        onProgress: (progress) => setState(() {
                          ffmpegInstallProgress = progress;

                          if (progress.phase == FFMpegProgressPhase.inactive) {
                            stepNo++;
                          }
                        }),
                      )
                          .then((value) {
                        if (!value && context.mounted) {
                          showMessage(
                            context,
                            Text(appLocal.installFailed),
                            null,
                          );
                        }
                      });
                      setState(() {
                        stepNo++;
                      });
                    },
                    child: Text(appLocal.installFFmpeg),
                  ),
                  const Gap(10),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(appLocal.cancel),
                  ),
                ],
              )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 260.ms)
                  .slideX(duration: 250.ms, curve: Curves.easeOut),
            ),
            Visibility(
              visible: stepNo == 2,
              child: _InstallationStep(
                stepNumber: 2,
                stepName: appLocal.installation,
                content: Column(
                  children: [
                    _CompletableSubStep(
                        ffmpegInstallProgress?.phase ==
                                FFMpegProgressPhase.downloading
                            ? appLocal.downloading
                            : appLocal.download,
                        ffmpegInstallProgress?.phase ==
                                FFMpegProgressPhase.downloading
                            ? SubStepState.doing
                            : SubStepState.done,
                        progress: ffmpegInstallProgress != null
                            ? (ffmpegInstallProgress!.downloaded /
                                    ffmpegInstallProgress!.fileSize) *
                                100
                            : null),
                    _CompletableSubStep(
                        ffmpegInstallProgress?.phase ==
                                FFMpegProgressPhase.decompressing
                            ? appLocal.decompressing
                            : appLocal.decompress,
                        ffmpegInstallProgress?.phase ==
                                FFMpegProgressPhase.decompressing
                            ? SubStepState.doing
                            : ffmpegInstallProgress?.phase ==
                                    FFMpegProgressPhase.downloading
                                ? SubStepState.planned
                                : SubStepState.done),
                    _CompletableSubStep(
                        appLocal.finished,
                        ffmpegInstallProgress?.phase ==
                                FFMpegProgressPhase.inactive
                            ? SubStepState.done
                            : SubStepState.planned),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 260.ms)
                  .slideX(duration: 250.ms, curve: Curves.easeOut),
            ),
            Visibility(
              visible: stepNo == 3,
              child: _InstallationStep(
                stepNumber: 3,
                stepName: appLocal.finished,
                buttons: [
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(appLocal.returnToPreviousPage),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 260.ms)
                  .slideX(duration: 250.ms, curve: Curves.easeOut),
            ),
          ],
        ),
      ),
    );
  }
}
