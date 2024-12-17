import 'package:flutter/material.dart';

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
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          description ?? const SizedBox.shrink(),
          Text(fieldName),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: placeholder,
            ),
          ),
        ],
      ),
      actions: [
        FilledButton(
          child: Text(confirm),
          onPressed: () {
            Navigator.pop(context, controller.text);
          },
        ),
        OutlinedButton(
          child: Text(cancel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

void showMessage(BuildContext context, Widget? title, Widget? content) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: title,
      content: content,
    ),
  );
}
