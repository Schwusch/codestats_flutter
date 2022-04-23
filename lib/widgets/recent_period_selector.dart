import 'package:codestats_flutter/bloc/bloc_provider.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/widgets/fluid_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecentPeriodSettings extends StatelessWidget {
  const RecentPeriodSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserBloc bloc = context.read<UserBloc>();
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
      child: StreamBuilder(
        stream: bloc.recentLength,
        builder: (_, __) => FluidSlider(
          sliderColor: Colors.blueGrey.shade700,
          min: 2,
          max: 14,
          value: bloc.recentLength.value.toDouble(),
          onChanged: (value) => bloc.recentLength.add(value.round()),
          onChangeEnd: (value) {
            if (value.round() != 1) bloc.fetchAllUsers();
          },
        ),
      ),
    );
  }
}
