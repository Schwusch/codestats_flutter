import 'package:codestats_flutter/bloc/bloc_provider.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/widgets/fluid_slider.dart';
import 'package:flutter/material.dart';

class RecentPeriodSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserBloc bloc = BlocProvider.of(context);
    return Padding(
      padding: EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
      child: StreamBuilder(
        stream: bloc.recentLength,
        builder:(_, __) => FluidSlider(
          sliderColor: Colors.blueGrey.shade700,
          min: 2,
          max: 14,
          value: bloc.recentLength.value?.toDouble() ?? 7,
          onChanged: (value) => bloc.recentLength.add(value.round()),
          onChangeEnd: (value) {
            if(value.round() != 1) bloc.fetchAllUsers();
          },
        ),
      ),
    );
  }
}
