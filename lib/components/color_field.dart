import 'package:fluent_ui/fluent_ui.dart';
import 'package:gap/gap.dart';
import 'package:storytailor/components/color_picker.dart';
import 'package:storytailor/l10n/app_localizations.dart';

class ColorField extends StatefulWidget {
  const ColorField(
      {super.key,
      this.initialValue = const Color(0xFF000000),
      this.onColorSelected});

  final Color initialValue;
  final void Function(Color?)? onColorSelected;

  @override
  State<StatefulWidget> createState() => _ColorFieldState();
}

class _ColorFieldState extends State<ColorField> {
  late Color color;

  @override
  void initState() {
    super.initState();

    color = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: kDefaultButtonPadding,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(
              Radius.circular(4),
            ),
          ),
          width: 32,
          child: Text(""),
        ),
        const Gap(5),
        Tooltip(
          message: appLocal.pickColor,
          child: IconButton(
            icon: const Icon(FluentIcons.eyedropper),
            onPressed: () {
              showColorPicker(context, initialColor: color).then(
                (value) {
                  if (value == null) {
                    return;
                  }

                  if (widget.onColorSelected != null) {
                    widget.onColorSelected!(value);
                  }

                  setState(() {
                    color = value;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
