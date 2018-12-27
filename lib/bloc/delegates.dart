import 'package:bloc/bloc.dart';

class LogTransitionDelegate extends BlocDelegate {
  @override
  void onTransition(Transition transition) {
    print(transition.toString());
  }
}