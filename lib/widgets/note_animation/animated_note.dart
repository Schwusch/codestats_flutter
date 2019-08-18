import 'package:codestats_flutter/widgets/note_animation/note_painter.dart';
import 'package:flutter/material.dart';

class AnimatedNote extends StatefulWidget {
  final int note;

  const AnimatedNote({Key key, this.note = 0}) : super(key: key);

  @override
  AnimatedNoteState createState() => AnimatedNoteState();
}

class AnimatedNoteState extends State<AnimatedNote>
    with SingleTickerProviderStateMixin {
  AnimationController noteController;
  Tween<double> noteTween;
  Animation noteAnimation;

  @override
  void initState() {
    super.initState();
    noteController = AnimationController(
      value: 0,
      upperBound: 1,
      lowerBound: 0,
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    noteTween = Tween(begin: 0.0, end: widget.note.toDouble());
    noteController.forward(from: 0);
    noteAnimation = noteTween.animate(noteController);
  }

  void update(int note) {
    if(note != noteTween.end.toInt()) {

        noteTween = Tween(begin: noteTween.evaluate(noteController), end: note.toDouble());
        noteAnimation = noteTween.animate(noteController);
        noteController.forward(from: 0);

    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: noteController,
      builder: (context, _) => CustomPaint(
        painter: NotePainter(note: noteAnimation.value - 1, height: noteController.value),
      ),
    );
  }
}
