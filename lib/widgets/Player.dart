import 'package:castboard_core/elements/backgroundBuilder.dart';
import 'package:castboard_core/elements/elementBuilders.dart';
import 'package:castboard_core/enums.dart';
import 'package:castboard_core/layout-canvas/LayoutCanvas.dart';
import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/CastChangeModel.dart';
import 'package:castboard_core/models/SlideSizeModel.dart';
import 'package:castboard_core/models/TrackModel.dart';
import 'package:castboard_core/models/SlideModel.dart';
import 'package:castboard_core/models/TrackRef.dart';
import 'package:castboard_core/slide-viewport/SlideViewport.dart';
import 'package:flutter/material.dart';

const double _basePauseIndicatorSize = 124;

class Player extends StatelessWidget {
  final Map<String, SlideModel> slides;
  final Map<TrackRef, TrackModel> tracks;
  final Map<String, TrackRef> trackRefsByName;
  final Map<ActorRef, ActorModel> actors;
  final CastChangeModel displayedCastChange;
  final String currentSlideId;
  final String nextSlideId;
  final SlideSizeModel slideSize;
  final SlideOrientation slideOrientation;
  final bool playing;
  final bool offstageUpcomingSlides;
  final Size? overrideSize;

  const Player({
    Key? key,
    required this.slides,
    required this.tracks,
    required this.actors,
    required this.trackRefsByName,
    required this.displayedCastChange,
    required this.currentSlideId,
    required this.slideSize,
    required this.slideOrientation,
    required this.nextSlideId,
    this.overrideSize,
    this.playing = true,
    this.offstageUpcomingSlides = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (slides[currentSlideId] == null) {
      return const Text('Current Slide is Null');
    }

    final actualSlideSize =
        overrideSize ?? _getDesiredSlideSize(slideSize, slideOrientation);
    final windowSize = overrideSize ?? _getWindowSize(context);
    final renderScale = overrideSize == null
        ? _getRenderScale(windowSize, actualSlideSize)
        : 1.0;

    return Stack(
      fit: StackFit.passthrough,
      children: [
        // Primary Viewport.
        buildSlideViewport(
            slide: slides[currentSlideId]!,
            actualSlideSize: actualSlideSize,
            renderScale: renderScale),
        // Offstaged Viewport, preRenders the next Slide.
        if (slides[nextSlideId] != null && offstageUpcomingSlides == true)
          Offstage(
            offstage: true,
            child: buildSlideViewport(
              slide: slides[nextSlideId]!,
              actualSlideSize: actualSlideSize,
              renderScale: renderScale,
            ),
          ),
        _buildPauseIndicator(renderScale)
      ],
    );
  }

  AnimatedPositioned _buildPauseIndicator(double renderScale) {
    return AnimatedPositioned(
      top: 24 * renderScale,
      right: playing
          ? -((24 + _basePauseIndicatorSize) * renderScale)
          : 24 * renderScale,
      duration: const Duration(milliseconds: 125),
      child: Container(
        width: _basePauseIndicatorSize * renderScale,
        height: _basePauseIndicatorSize * renderScale,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.pause_circle_filled,
          size: _basePauseIndicatorSize * renderScale,
        ),
      ),
    );
  }

  SlideViewport buildSlideViewport({
    required SlideModel slide,
    required Size actualSlideSize,
    required double renderScale,
  }) {
    return SlideViewport(
      slideWidth: actualSlideSize.width.toInt(),
      slideHeight: actualSlideSize.height.toInt(),
      enableScrolling: false,
      slideRenderScale: renderScale,
      background: getBackground(
        slides,
        currentSlideId,
      ),
      child: LayoutCanvas(
        interactive: false,
        elements: buildElements(
          slide: slide,
          actors: actors,
          tracks: tracks,
          trackRefsByName: trackRefsByName,
          castChange: displayedCastChange,
        ),
        renderScale: renderScale,
      ),
    );
  }

  Size _getDesiredSlideSize(
      SlideSizeModel slideSize, SlideOrientation orientation) {
    return slideSize.orientated(orientation).toSize();
  }

  Size _getWindowSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  double _getRenderScale(Size windowSize, Size desiredSlideSize) {
    final xRatio = windowSize.width / desiredSlideSize.width;
    final yRatio = windowSize.height / desiredSlideSize.height;

    return xRatio < yRatio ? xRatio : yRatio;
  }
}
