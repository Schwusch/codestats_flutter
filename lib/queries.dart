import 'package:date_format/date_format.dart';

String formatDateUtc(DateTime date) {
  return formatDate(
      date, [yyyy, "-", mm, "-", dd, "T", HH, ":", mm, ":", ss, ".", SSS, z]);
}

String profiles(List<String> users, DateTime since, int recentDays) {
  var buffer = StringBuffer();
  buffer.write("{\n");
  
  users.forEach((user) => buffer.write("""
$user: profile(username: "$user") {
    ...ProfileInfo
  }
"""));

  buffer.write("""}
fragment ProfileInfo on Profile {
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
    dayLanguageXps: dayLanguageXps(since: "${formatDate(since.subtract(Duration(days: recentDays)), [
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
  """);

  return buffer.toString();
}
