import 'package:fluent_ui/fluent_ui.dart';

Future<Color?> showColorPicker(BuildContext context,
    {Color initialColor = Colors.white}) {
  return showDialog<Color>(
    context: context,
    builder: (context) {
      ColorPickerController controller =
          ColorPickerController(color: initialColor);

      return ContentDialog(
        title: const Text("Pick a color"),
        content: ColorPicker(controller: controller),
        actions: [
          Button(
            child: const Text("Close"),
            onPressed: () {
              Navigator.pop(context, controller.color);
            },
          ),
        ],
      );
    },
  );
}

class ColorPickerController {
  Color color;

  ColorPickerController({this.color = Colors.white});
}

class ColorPicker extends StatefulWidget {
  final ColorPickerController controller;

  const ColorPicker({super.key, required this.controller});

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  int tabIndex = 0;
  List<TextEditingController> rgbControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  List<TextEditingController> hsvControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void initState() {
    super.initState();

    updateRGB();
    updateHSV();
  }

  void updateRGB() {
    Color color = widget.controller.color;
    rgbControllers[0].text = color.r.toString();
    rgbControllers[1].text = color.g.toString();
    rgbControllers[2].text = color.b.toString();
  }

  void updateHSV() {
    HSVColor hsvColor = HSVColor.fromColor(widget.controller.color);
    hsvControllers[0].text = hsvColor.hue.toString();
    hsvControllers[1].text = hsvColor.saturation.toString();
    hsvControllers[2].text = hsvColor.value.toString();
  }

  @override
  Widget build(BuildContext context) {
    HSVColor hsvColor = HSVColor.fromColor(widget.controller.color);
    if (hsvColor.hue > 255) {
      hsvColor = hsvColor.withHue(255);
    }

    return TabView(
      currentIndex: tabIndex,
      onChanged: (newValue) => setState(() => tabIndex = newValue),
      closeButtonVisibility: CloseButtonVisibilityMode.never,
      tabs: [
        Tab(
          text: const Text("RGB"),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text("Preview Color: "),
                  Container(
                    width: 20,
                    height: 20,
                    color: widget.controller.color,
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                      child: InfoLabel(label: "R"),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Slider(
                      value: widget.controller.color.r,
                      max: 1.0,
                      onChanged: (value) => setState(() {
                        widget.controller.color =
                            widget.controller.color.withValues(red: value);
                        rgbControllers[0].text = value.toString();
                        updateHSV();
                      }),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 7, 10, 7),
                      child: TextBox(
                        controller: rgbControllers[0],
                        keyboardType: const TextInputType.numberWithOptions(),
                        onChanged: (newValue) => setState(() {
                          int? val = int.tryParse(newValue);
                          if (val == null || val > 255) {
                            return;
                          }
                          widget.controller.color =
                              widget.controller.color.withRed(val);
                          updateHSV();
                        }),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                      child: InfoLabel(label: "G"),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Slider(
                      value: widget.controller.color.g,
                      max: 1,
                      onChanged: (value) => setState(() {
                        widget.controller.color =
                            widget.controller.color.withValues(green: value);
                        rgbControllers[1].text = value.toString();
                        updateHSV();
                      }),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 7, 10, 7),
                      child: TextBox(
                        controller: rgbControllers[1],
                        keyboardType: const TextInputType.numberWithOptions(),
                        onChanged: (newValue) => setState(() {
                          int? val = int.tryParse(newValue);
                          if (val == null || val > 255) {
                            return;
                          }
                          widget.controller.color =
                              widget.controller.color.withGreen(val);
                          updateHSV();
                        }),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                      child: InfoLabel(label: "B"),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Slider(
                      value: widget.controller.color.b,
                      max: 1,
                      onChanged: (value) => setState(
                        () {
                          widget.controller.color =
                              widget.controller.color.withValues(blue: value);
                          rgbControllers[2].text = value.toString();
                          updateHSV();
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 7, 10, 7),
                      child: TextBox(
                        controller: rgbControllers[2],
                        keyboardType: const TextInputType.numberWithOptions(),
                        onChanged: (newValue) => setState(() {
                          int? val = int.tryParse(newValue);
                          if (val == null || val > 255) {
                            return;
                          }
                          widget.controller.color =
                              widget.controller.color.withBlue(val);
                          updateHSV();
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Tab(
          text: const Text("HSV"),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text("Preview Color: "),
                  Container(
                    width: 20,
                    height: 20,
                    color: widget.controller.color,
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                      child: InfoLabel(label: "Hue"),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Slider(
                      value: hsvColor.hue,
                      max: 360.0,
                      onChanged: (value) => setState(
                        () {
                          widget.controller.color =
                              hsvColor.withHue(value).toColor();
                          hsvControllers[0].text = value.toString();
                          updateRGB();
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 7, 10, 7),
                      child: TextBox(
                        controller: hsvControllers[0],
                        keyboardType: const TextInputType.numberWithOptions(),
                        onChanged: (newValue) => setState(() {
                          double? val = double.tryParse(newValue);
                          if (val == null || val > 255) {
                            return;
                          }
                          widget.controller.color =
                              hsvColor.withHue(val).toColor();
                          updateRGB();
                        }),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                      child: InfoLabel(label: "Sat"),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Slider(
                      value: hsvColor.saturation,
                      max: 1.0,
                      onChanged: (value) => setState(
                        () {
                          widget.controller.color =
                              hsvColor.withSaturation(value).toColor();
                          hsvControllers[1].text = value.toString();
                          updateRGB();
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 7, 10, 7),
                      child: TextBox(
                        controller: hsvControllers[1],
                        keyboardType: const TextInputType.numberWithOptions(),
                        onChanged: (newValue) => setState(() {
                          double? val = double.tryParse(newValue);
                          if (val == null || val > 1.0) {
                            return;
                          }
                          widget.controller.color =
                              hsvColor.withSaturation(val).toColor();
                          updateRGB();
                        }),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                      child: InfoLabel(label: "Val"),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Slider(
                      value: hsvColor.value,
                      max: 1.0,
                      onChanged: (value) => setState(
                        () {
                          widget.controller.color =
                              hsvColor.withValue(value).toColor();
                          hsvControllers[2].text = value.toString();
                          updateRGB();
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 7, 10, 7),
                      child: TextBox(
                        controller: hsvControllers[2],
                        keyboardType: const TextInputType.numberWithOptions(),
                        onChanged: (newValue) => setState(() {
                          double? val = double.tryParse(newValue);
                          if (val == null || val > 1.0) {
                            return;
                          }
                          widget.controller.color =
                              hsvColor.withValue(val).toColor();
                          updateRGB();
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
