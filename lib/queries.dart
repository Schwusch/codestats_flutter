import 'package:date_format/date_format.dart';

String formatDateUtc(DateTime date) {
  return formatDate(
      date, [yyyy, "-", m, "-", dd, "T", HH, ":", mm, ":", ss, ".", SSS, z]);
}

String profile(String username, DateTime since) => """
{
$username: profile(username: "$username") {
    totalXp: totalXp
    total_langs: languages {
      name
      xp
    }
    recent_langs: languages(since: "${formatDateUtc(since.toUtc())}") {
      name
      xp
    }
    total_machines: machines {
      name
      xp
    }
    recent_machines: machines(since: "${formatDateUtc(since.toUtc())}") {
      name
      xp
    }
    day_language_xps: dayLanguageXps(since: "${formatDate(since.subtract(Duration(days: 7)), [
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
    day_of_year_xps: dayOfYearXps
    hour_of_day_xps: hourOfDayXps
  } }
""";
