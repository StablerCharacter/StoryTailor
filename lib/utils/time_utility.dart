import 'package:intl/intl.dart';

const aDay = Duration(days: 1);
const anHour = Duration(hours: 1);
const aMinute = Duration(minutes: 1);
final timeSectionFormat = NumberFormat("00");

String durationToDisplay(Duration duration) {
  int seconds = duration.inSeconds;
  if (duration.inDays > 0) {
    // ${Math.floor(seconds / aDay)}:${Math.floor((seconds % aDay) / anHour)}:${Math.floor((seconds % anHour) / aMinute)}:${seconds % aMinute}`
    return "${timeSectionFormat.format(seconds ~/ aDay.inSeconds)}:${timeSectionFormat.format((seconds % aDay.inSeconds) ~/ anHour.inSeconds)}:${timeSectionFormat.format((seconds % anHour.inSeconds) ~/ aMinute.inSeconds)}:${timeSectionFormat.format(seconds % aMinute.inSeconds)}";
  } else if (duration.inHours > 0) {
    // `${Math.floor((seconds / anHour))}:${Math.floor((seconds % anHour) / aMinute)}:${seconds % aMinute}`
    return "${timeSectionFormat.format(seconds ~/ anHour.inSeconds)}:${timeSectionFormat.format((seconds % anHour.inSeconds) / aMinute.inSeconds)}:${timeSectionFormat.format(seconds % aMinute.inSeconds)}";
  } else {
    return "${timeSectionFormat.format(seconds ~/ 60)}:${timeSectionFormat.format(seconds % 60)}";
  }
}