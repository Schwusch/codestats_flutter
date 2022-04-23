import 'package:codestats_flutter/bloc/codestats_bloc.dart';
import 'package:codestats_flutter/widgets/bouncable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'flip_panel.dart';

class TotalXp extends StatelessWidget {
  const TotalXp({
    Key? key,
    required this.totalXp,
  }) : super(key: key);

  final int totalXp;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<UserBloc>();

    final xpStr = "$totalXp";
    var digitWidgits = <Widget>[];
    final xpStrChars = xpStr.split('');

    for (var index = 0; index < xpStrChars.length; index++) {
      final char = xpStrChars[index];
      digitWidgits.add(
        Expanded(
          child: Bouncable(
            child: LayoutBuilder(
              builder: (context, constraints) => Container(
                margin: const EdgeInsets.all(4.0),
                decoration: ShapeDecoration(
                  shadows: const [
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
                  duration: const Duration(milliseconds: 100),
                  itemStream: Rx.concat(
                    [
                      Rx.range(0, int.parse(char)).transform(
                        IntervalStreamTransformer(
                          const Duration(milliseconds: 250),
                        ),
                      ),
                      bloc.currentUser.map((user) {
                        if (user.data?.totalXp != null &&
                            "${user.data!.totalXp}".length > index) {
                          return "${user.data!.totalXp}"[index];
                        } else {
                          return "0";
                        }
                      }),
                    ],
                  ),
                  itemBuilder: (context, value) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blueGrey.shade200,
                    ),
                    padding: const EdgeInsets.all(6.0),
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
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: digitWidgits,
      ),
    );
  }
}
