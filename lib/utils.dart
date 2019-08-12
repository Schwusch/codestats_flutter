import 'dart:math';

import 'package:codestats_flutter/models/user/user.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:superpower/superpower.dart';
import 'package:flutter/material.dart';

int getLevel(int xp) => (0.025 * sqrt(xp)).floor();

int getXp(int level) => pow(level / 0.025, 2).round();

int getRecentXp(User userModel) =>
    $(userModel.recentMachines).sumBy((elem) => elem.xp).floor();

final _formatter = NumberFormat("#,###");
String formatNumber(num num) => _formatter.format(num);

setupDebugLog(Dio dio) {
  assert((){
    dio.interceptors.add(LogInterceptor(responseBody: true));
    return true;
  }());
}