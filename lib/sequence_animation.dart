import 'package:flutter/material.dart';

class _AnimationInformation<E> {
  _AnimationInformation({
    required this.animatable,
    required this.from,
    required this.to,
    required this.curve,
    required this.tag,
  });

  final Animatable<E> animatable;
  final Duration from;
  final Duration to;
  final Curve curve;
  final Object tag;
}

class SequenceAnimationBuilder<E> {
  final List<_AnimationInformation<E>> _animations = [];

  /// Adds an [Animatable] to the sequence, in the most cases this would be a [Tween].
  /// The from and to [Duration] specify points in time where the animation takes place.
  /// You can also specify a [Curve] for the [Animatable].
  ///
  /// [Animatable]s which animate on the same tag are not allowed to overlap and they also need to be add in the same order they are played.
  /// These restrictions only apply to [Animatable]s operating on the same tag.
  ///
  ///
  /// ## Sample code
  ///
  /// ```dart
  ///     SequenceAnimation sequenceAnimation = new SequenceAnimationBuilder()
  ///         .addAnimatable(
  ///           animatable: new ColorTween(begin: Colors.red, end: Colors.yellow),
  ///           from: const Duration(seconds: 0),
  ///           to: const Duration(seconds: 2),
  ///           tag: "color",
  ///         )
  ///         .animate(controller);
  /// ```
  ///
  SequenceAnimationBuilder<E> addAnimatable({
    required Animatable<E> animatable,
    required Duration from,
    required Duration to,
    Curve curve = Curves.linear,
    required Object tag,
  }) {
    assert(to >= from);
    _animations.add(_AnimationInformation(
        animatable: animatable, from: from, to: to, curve: curve, tag: tag));
    return this;
  }

  /// The controllers duration is going to be overwritten by this class, you should not specify it on your own
  SequenceAnimation<E> animate(AnimationController controller) {
    int longestTimeMicro = 0;
    for (var info in _animations) {
      int micro = info.to.inMicroseconds;
      if (micro > longestTimeMicro) {
        longestTimeMicro = micro;
      }
    }
    // Sets the duration of the controller
    controller.duration = Duration(microseconds: longestTimeMicro);

    Map<Object, Animatable<E>> animatables = {};
    Map<Object, double> begins = {};
    Map<Object, double> ends = {};

    for (var info in _animations) {
      assert(info.to.inMicroseconds <= longestTimeMicro);

      double begin = info.from.inMicroseconds / longestTimeMicro;
      double end = info.to.inMicroseconds / longestTimeMicro;
      Interval intervalCurve = Interval(begin, end, curve: info.curve);
      if (animatables[info.tag] == null) {
        animatables[info.tag] =
            IntervalAnimatable.chainCurve(info.animatable, intervalCurve);
        begins[info.tag] = begin;
        ends[info.tag] = end;
      } else {
        assert(
            ends[info.tag]! <= begin,
            "When animating the same property you need to: \n"
            "a) Have them not overlap \n"
            "b) Add them in an ordered fashion");
        animatables[info.tag] = IntervalAnimatable(
          animatable: animatables[info.tag]!,
          defaultAnimatable:
              IntervalAnimatable.chainCurve(info.animatable, intervalCurve),
          begin: begins[info.tag]!,
          end: ends[info.tag]!,
        );
        ends[info.tag] = end;
      }
    }

    Map<Object, Animation<E>> result = {};

    animatables.forEach((tag, animInfo) {
      result[tag] = animInfo.animate(controller);
    });

    return SequenceAnimation._internal(result);
  }
}

class SequenceAnimation<E> {
  final Map<Object, Animation<E>> _animations;

  /// Use the [SequenceAnimationBuilder] to construct this class.
  SequenceAnimation._internal(this._animations);

  /// Returns the animation with a given tag, this animation is tied to the controller.
  Animation<E> operator [](Object key) {
    assert(_animations.containsKey(key),
        "There was no animatable with the key: $key");
    return _animations[key]!;
  }
}

/// Evaluates [animatable] if the animation is in the time-frame of [begin] (inclusive) and [end] (inclusive),
/// if not it evaluates the [defaultAnimatable]
class IntervalAnimatable<T> extends Animatable<T> {
  IntervalAnimatable({
    required this.animatable,
    required this.defaultAnimatable,
    required this.begin,
    required this.end,
  });

  final Animatable animatable;
  final Animatable defaultAnimatable;

  /// The relative begin to of [animatable]
  /// If your [AnimationController] is running from 0->1, this needs to be a value between those two
  final double begin;

  /// The relative end to of [animatable]
  /// If your [AnimationController] is running from 0->1, this needs to be a value between those two
  final double end;

  /// Chains an [Animatable] with a [CurveTween] and the given [Interval].
  /// Basically, the animation is being constrained to the given interval
  static Animatable<E> chainCurve<E>(Animatable<E> parent, Interval interval) {
    return parent.chain(CurveTween(curve: interval));
  }

  @override
  T transform(double t) {
    if (t >= begin && t <= end) {
      return animatable.transform(t);
    } else {
      return defaultAnimatable.transform(t);
    }
  }
}
