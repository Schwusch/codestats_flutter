import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'models/user/user.dart';

extension ScopingFunctions<T> on T {
  /// Calls the specified function [block] with `this` value
  /// as its argument and returns its result.
  R let<R>(R Function(T) block) => block(this);

  /// Calls the specified function [block] with `this` value
  /// as its argument and returns `this` value.
  T also(void Function(T) block) {
    block(this);
    return this;
  }
}

extension ListUtils<E> on List<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  E? get firstOrNull {
    Iterator<E> it = iterator;
    if (!it.moveNext()) {
      return null;
    }
    return it.current;
  }
}

log(dynamic toLog) {
  if (kDebugMode) {
    debugPrint(toLog.toString());
  }
}

int getLevel(int xp) => (0.025 * sqrt(xp)).floor();

int getXp(int level) => pow(level / 0.025, 2).round();

int getRecentXp(User userModel) => userModel.recentMachines.fold<int>(
      0,
      (previousValue, element) => element.xp + previousValue,
    );

final _formatter = NumberFormat("#,###");
String formatNumber(num num) => _formatter.format(num);
