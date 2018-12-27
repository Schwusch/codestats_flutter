import 'dart:math';

import 'package:codestats_flutter/usermodel.dart';
import 'package:superpower/superpower.dart';

int getLevel(int xp) => (0.025 * sqrt(xp)).floor();

int getXp(int level) => pow(level / 0.025, 2).round();

int getRecentXp(UserModel userModel) =>
    $(userModel.recentLangs).sumBy((elem) => elem.xp).floor();
