import 'package:date_format/date_format.dart';

String formatDateUtc(DateTime date) {
  return formatDate(
      date, [yyyy, "-", m, "-", dd, "T", HH, ":", mm, ":", ss, ".", SSS, z]);
}

String _profile(String username, DateTime since) => """
$username: profile(username: "$username") {
    totalXp: totalXp
    totalLangs: languages {
      name
      xp
    }
    recentLangs: languages(since: "${formatDateUtc(since.subtract(Duration(hours: 12)).toUtc())}") {
      name
      xp
    }
    totalMachines: machines {
      name
      xp
    }
    recentMachines: machines(since: "${formatDateUtc(since.subtract(Duration(hours: 12)).toUtc())}") {
      name
      xp
    }
    dayLanguageXps: dayLanguageXps(since: "${formatDate(since.subtract(Duration(days: 7)), [
      yyyy,
      '-',
      mm,
      '-',
      dd
    ])}") {
      date
      language
      xp
    }
    dayOfYearXps: dayOfYearXps
    hourOfDayXps: hourOfDayXps
  } 

""";

String profiles(List<String> users, DateTime since) {
  var buffer = StringBuffer();
  buffer.write("{");
  users.forEach((user) => buffer.write(_profile(user, since)));
  buffer.write("}");

  return buffer.toString();
}
