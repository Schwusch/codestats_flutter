import 'dart:math';

import 'package:codestats_flutter/models/user/user.dart';
import 'package:superpower/superpower.dart';

int getLevel(int xp) => (0.025 * sqrt(xp)).floor();

int getXp(int level) => pow(level / 0.025, 2).round();

int getRecentXp(User userModel) =>
    $(userModel.recentMachines).sumBy((elem) => elem.xp).floor();
