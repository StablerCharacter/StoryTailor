import 'package:fluent_ui/fluent_ui.dart';

Future<String?> askString(
    BuildContext context,
    String title,
    Widget? description,
    String fieldName,
    String placeholder,
    String confirm,
    String cancel) {
  TextEditingController controller = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (context) => ContentDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          description ?? const SizedBox.shrink(),
          InfoLabel(label: fieldName),
          TextBox(
            controller: controller,
            placeholder: placeholder,
          ),
        ],
      ),
      actions: [
        FilledButton(
            child: Text(confirm),
            onPressed: () {
              Navigator.pop(context, controller.text);
            }),
        Button(
          child: Text(cancel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}
