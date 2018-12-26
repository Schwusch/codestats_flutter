class UserModel {
  List<TotalMachines> totalMachines;
  List<TotalLangs> totalLangs;
  List<RecentMachines> recentMachines;
  List<RecentLangs> recentLangs;
  Map<String, int> hourOfDayXps;
  Map<String, int> dayOfYearXps;
  List<DayLanguageXps> dayLanguageXps;
  int totalXp;

  UserModel(
      {this.totalMachines,
        this.totalLangs,
        this.recentMachines,
        this.recentLangs,
        this.hourOfDayXps,
        this.dayOfYearXps,
        this.dayLanguageXps,
        this.totalXp
      });

  UserModel.fromJson(Map<String, dynamic> json) {
    if (json['total_machines'] != null) {
      totalMachines = new List<TotalMachines>();
      json['total_machines'].forEach((v) {
        totalMachines.add(new TotalMachines.fromJson(v));
      });
    }
    if (json['total_langs'] != null) {
      totalLangs = new List<TotalLangs>();
      json['total_langs'].forEach((v) {
        totalLangs.add(new TotalLangs.fromJson(v));
      });
    }
    if (json['recent_machines'] != null) {
      recentMachines = new List<RecentMachines>();
      json['recent_machines'].forEach((v) {
        recentMachines.add(new RecentMachines.fromJson(v));
      });
    }
    if (json['recent_langs'] != null) {
      recentLangs = new List<RecentLangs>();
      json['recent_langs'].forEach((v) {
        recentLangs.add(new RecentLangs.fromJson(v));
      });
    }
    hourOfDayXps = json['hour_of_day_xps'] != null
        ? Map<String, int>.from(json['hour_of_day_xps'])
        : null;
    dayOfYearXps = json['day_of_year_xps'] != null
        ? Map<String, int>.from(json['day_of_year_xps'])
        : null;
    if (json['day_language_xps'] != null) {
      dayLanguageXps = new List<DayLanguageXps>();
      json['day_language_xps'].forEach((v) {
        dayLanguageXps.add(new DayLanguageXps.fromJson(v));
      });
    }
    if(json['totalXp'] != null) {
      totalXp = json['totalXp'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.totalMachines != null) {
      data['total_machines'] =
          this.totalMachines.map((v) => v.toJson()).toList();
    }
    if (this.totalLangs != null) {
      data['total_langs'] = this.totalLangs.map((v) => v.toJson()).toList();
    }
    if (this.recentMachines != null) {
      data['recent_machines'] =
          this.recentMachines.map((v) => v.toJson()).toList();
    }
    if (this.recentLangs != null) {
      data['recent_langs'] = this.recentLangs.map((v) => v.toJson()).toList();
    }
    if (this.hourOfDayXps != null) {
      data['hour_of_day_xps'] = hourOfDayXps;
    }
    if (this.dayOfYearXps != null) {
      data['day_of_year_xps'] = dayOfYearXps;
    }
    if (this.dayLanguageXps != null) {
      data['day_language_xps'] =
          this.dayLanguageXps.map((v) => v.toJson()).toList();
    }
    if(this.totalXp != null) {
      data['totalXp'] = this.totalXp;
    }
    return data;
  }
}

class TotalMachines {
  int xp;
  String name;

  TotalMachines({this.xp, this.name});

  TotalMachines.fromJson(Map<String, dynamic> json) {
    xp = json['xp'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['xp'] = this.xp;
    data['name'] = this.name;
    return data;
  }
}

class TotalLangs {
  int xp;
  String name;

  TotalLangs({this.xp, this.name});

  TotalLangs.fromJson(Map<String, dynamic> json) {
    xp = json['xp'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['xp'] = this.xp;
    data['name'] = this.name;
    return data;
  }
}

class RecentMachines {
  int xp;
  String name;

  RecentMachines({this.xp, this.name});

  RecentMachines.fromJson(Map<String, dynamic> json) {
    xp = json['xp'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['xp'] = this.xp;
    data['name'] = this.name;
    return data;
  }
}

class RecentLangs {
  int xp;
  String name;

  RecentLangs({this.xp, this.name});

  RecentLangs.fromJson(Map<String, dynamic> json) {
    xp = json['xp'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['xp'] = this.xp;
    data['name'] = this.name;
    return data;
  }
}

class DayLanguageXps {
  int xp;
  String language;
  String date;

  DayLanguageXps({this.xp, this.language, this.date});

  DayLanguageXps.fromJson(Map<String, dynamic> json) {
    xp = json['xp'];
    language = json['language'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['xp'] = this.xp;
    data['language'] = this.language;
    data['date'] = this.date;
    return data;
  }
}