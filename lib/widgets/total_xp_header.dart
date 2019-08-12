import 'package:codestats_flutter/bloc/bloc_provider.dart';
import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/widgets/bouncable.dart';
import 'package:flip_panel/flip_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midi/flutter_midi.dart';
import 'package:rxdart/rxdart.dart';
import 'package:superpower/superpower.dart';
import 'package:tonic/tonic.dart';

class TotalXp extends StatelessWidget {
  const TotalXp({
    Key key,
    @required this.totalXp,
  }) : super(key: key);

  final int totalXp;

  @override
  Widget build(BuildContext context) {
    final UserBloc bloc = BlocProvider.of(context);
    final scale =
        ScalePattern.findByName('Harmonic Minor').at(PitchClass(integer: 4));
    List<int> midis = [];

    final xpStr = "$totalXp";
    var digitWidgits = List<Widget>();

    $(xpStr.split('')).forEachIndexed(
      (char, index) {
        midis.add(name2midi(scale.pitchClasses[index]
            .toPitch(octave: index > 4 ? 4 : 3)
            .toString()));
        digitWidgits.add(
          Expanded(
            child: Bouncable(
              onTap: () => FlutterMidi.playMidiNote(midi: midis[index]),
              child: LayoutBuilder(
                builder: (context, constraints) => Container(
                  margin: EdgeInsets.all(4.0),
                  decoration: ShapeDecoration(
                    shadows: [
                      BoxShadow(
                          color: Colors.grey,
                          blurRadius: 2,
                          //spreadRadius: 1,
                          offset: Offset(3, 3))
                    ],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: FlipPanel.stream(
                    key: ValueKey(bloc.currentUserController.value),
                    spacing: 2,
                    initValue: "0",
                    duration: Duration(milliseconds: 100),
                    itemStream: Observable.concat(
                      [
                        Observable.range(0, int.parse(char)).transform(
                          IntervalStreamTransformer(
                            Duration(milliseconds: 250),
                          ),
                        ),
                        bloc.currentUser
                            .map((user) => "${user?.totalXp}"[index]),
                      ],
                    ),
                    itemBuilder: (context, value) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.blueGrey.shade200,
                      ),
                      padding: EdgeInsets.all(6.0),
                      child: SizedBox(
                        width: constraints.maxWidth - 12,
                        height: constraints.maxWidth,
                        child: Center(
                          child: Text(
                            '$value',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: constraints.maxWidth * 0.9,
                              fontFamily: "OCRAEXT",
                              color: Colors.white,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: digitWidgits,
      ),
    );
  }
}
