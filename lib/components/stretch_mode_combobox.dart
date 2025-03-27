import 'package:flame_character/flame_character.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:storytailor/l10n/app_localizations.dart';

class StretchModeComboBox extends StatelessWidget {
  final Stretch value;
  final void Function(Stretch?)? onChange;

  const StretchModeComboBox({
    super.key,
    this.value = Stretch.scaleToCover,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLocal = AppLocalizations.of(context)!;

    return ComboBox(
      items: [
        ComboBoxItem(value: Stretch.noStretch, child: Text(appLocal.noStretch)),
        ComboBoxItem(value: Stretch.letterbox, child: Text(appLocal.letterbox)),
        ComboBoxItem(value: Stretch.pillarbox, child: Text(appLocal.pillarbox)),
        ComboBoxItem(
          value: Stretch.scaleToCover,
          child: Text(appLocal.scaleToCover),
        ),
        ComboBoxItem(
          value: Stretch.stretchToFit,
          child: Text(appLocal.stretchToFit),
        ),
      ],
      value: value,
      onChanged: onChange,
    );
  }
}
