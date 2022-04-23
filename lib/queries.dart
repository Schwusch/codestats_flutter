import 'package:date_format/date_format.dart';

String formatDateUtc(DateTime date) {
  return formatDate(
      date, [yyyy, "-", mm, "-", dd, "T", HH, ":", mm, ":", ss, ".", SSS, z]);
}

String profiles(List<String> users, DateTime since, int recentDays) {
  var buffer = StringBuffer();
  buffer.write("{\n");

  for (var user in users) {
    buffer.write("""
$user: profile(username: "$user") {
    ...ProfileInfo
  }
""");
  }

  final twelveHoursAgo = formatDateUtc(since.subtract(const Duration(hours: 12)).toUtc());

  final customDateAgo = formatDate(since.subtract(Duration(days: recentDays)), [
        yyyy,
        '-',
        mm,
        '-',
        dd
      ]);

  buffer.write("""}
fragment ProfileInfo on Profile {
    totalXp
    totalLangs: languages {
      name
      xp
    }
    recentLangs: languages(since: "$twelveHoursAgo") {
      name
      xp
    }
    totalMachines: machines {
      name
      xp
    }
    recentMachines: machines(since: "$twelveHoursAgo") {
      name
      xp
    }
    dayLanguageXps(since: "$customDateAgo") {
      date
      language
      xp
    }
    dayOfYearXps
    hourOfDayXps
    registered
    flowMinsByDay(since: "$customDateAgo") {
      date
      mins
    }
    topFlows {
      averageDuration
      averageXp
      longest {
        duration
        languages
        startTimeLocal
        xp
      }
      mostProlific {
        duration
        languages
        startTimeLocal
        xp
      }
      strongest {
        duration
        languages
        startTimeLocal
        xp
      }
    }
  }
  """);

  return buffer.toString();
}
