import 'dart:math';

import 'package:codestats_flutter/models/user/user.dart';
import 'package:dio/dio.dart';
import 'package:superpower/superpower.dart';
import 'package:flutter/material.dart';

int getLevel(int xp) => (0.025 * sqrt(xp)).floor();

int getXp(int level) => pow(level / 0.025, 2).round();

int getRecentXp(User userModel) =>
    $(userModel.recentMachines).sumBy((elem) => elem.xp).floor();

setupDebugLog(Dio dio) {
  assert((){
    dio.interceptor.request.onSend = logRequest;
    dio.interceptor.response.onSuccess = logResponse;
    dio.interceptor.response.onError = logError;
    return true;
  }());
}

Options logRequest(Options options) {
  debugPrint(""" BEGIN HTTP REQUEST
${buildRequestString(options)}
""", wrapWidth: 1024);
  return options;
}

String buildRequestString(Options options) => """URL:
${options?.baseUrl}${options?.path}
HEADERS:
${options?.headers}
DATA:
${options?.data}""";

Response logResponse(Response response) {
  debugPrint(""" BEGIN HTTP RESPONSE
${buildResponseString(response)}
""", wrapWidth: 1024);
  return response;
}

String buildResponseString(Response response) => """URL:
${response?.request?.baseUrl}${response?.request?.path}
HEADERS:
${response?.headers}
${response?.data.toString()}""";

DioError logError(DioError error) {
  debugPrint(""" BEGIN HTTP ERROR
${error?.message}
${error?.type.toString()}
REQUEST:
${buildRequestString(error?.response?.request)}
RESPONSE:
${buildResponseString(error?.response)}
  """, wrapWidth: 1024);
  return error;
}