import 'package:castboard_core/elements/background/get_background_decoration.dart';
import 'package:castboard_core/elements/elementBuilders.dart';
import 'package:castboard_core/layout-canvas/LayoutCanvas.dart';
import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/CastChangeModel.dart';
import 'package:castboard_core/models/TrackModel.dart';
import 'package:castboard_core/models/SlideModel.dart';
import 'package:castboard_core/models/TrackRef.dart';
import 'package:castboard_core/slide-viewport/SlideViewport.dart';
import 'package:castboard_core/utils/get_fitted_render_scale.dart';
import 'package:flutter/material.dart';

const double _basePauseIndicatorSize = 124;

class Player extends StatelessWidget {
  final bool noSlides;
  final Map<String, SlideModel> slides;
  final Map<TrackRef, TrackModel> tracks;
  final Map<String, TrackRef> trackRefsByName;
  final Map<ActorRef, ActorModel> actors;
  final CastChangeModel displayedCastChange;
  final String currentSlideId;
  final String nextSlideId;
  final Size actualSlideSize;
  final bool playing;
  final bool offstageUpcomingSlides;
  final Size? sizeOverride;
  final double? renderScaleOverride;
  final bool showDemoIndicator;

  const Player({
    Key? key,
    this.noSlides = false,
    required this.slides,
    required this.tracks,
    required this.actors,
    required this.trackRefsByName,
    required this.displayedCastChange,
    required this.currentSlideId,
    required this.actualSlideSize,
    required this.nextSlideId,
    this.renderScaleOverride,
    this.sizeOverride,
    this.playing = true,
    this.offstageUpcomingSlides = false,
    this.showDemoIndicator = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (noSlides == true) {
      return const _NoSlidesFallback();
    }

    if (currentSlideId.isEmpty || slides[currentSlideId] == null) {
      return const _UnknownErrorFallback();
    }

    // Calculate the playing area.
    final concreteSlideSize = sizeOverride ?? actualSlideSize;

    final windowSize = sizeOverride ?? _getWindowSize(context);

    // Assert codependtness of sizeOverride and renderScaleOverride. If one is set, both must be set.
    assert(
        (sizeOverride != null || renderScaleOverride != null)
            ? sizeOverride != null && renderScaleOverride != null
            : true,
        "sizeOverride and renderScaleOverride are codependent. If one is set, the other must also be set");

    // Determine the Render scale. If sizeOverride is provided, use the renderScaleOverride otherwise
    // calculate a scale that fits all of the contents into the available area.
    double renderScale = 1.0;

    if (sizeOverride == null) {
      renderScale = getFittedRenderScale(windowSize, concreteSlideSize);
    } else {
      renderScale =
          renderScaleOverride!; // Null safety protected by the assert statement.
    }

    return DefaultTextStyle(
      style: Theme.of(context)
          .textTheme
          .bodyMedium!, // Provides a DefaultTextStyle without having to use a Scaffold. Ensures Text Underlines render correctly.
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          // Primary Viewport.
          buildSlideViewport(
              slide: slides[currentSlideId]!,
              actualSlideSize: concreteSlideSize,
              renderScale: renderScale),
          // Offstaged Viewport, preRenders the next Slide.
          if (slides[nextSlideId] != null && offstageUpcomingSlides == true)
            Offstage(
              offstage: true,
              child: buildSlideViewport(
                slide: slides[nextSlideId]!,
                actualSlideSize: concreteSlideSize,
                renderScale: renderScale,
              ),
            ),
          _buildPauseIndicator(renderScale),
          if (showDemoIndicator) _buildDemoIndicator(context, renderScale)
        ],
      ),
    );
  }

  Widget _buildDemoIndicator(BuildContext context, double renderScale) {
    return Positioned.fill(
      child: Center(
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationZ(0.5),
          child: Container(
            decoration: BoxDecoration(
                color: const Color(0x55000000),
                backgroundBlendMode: BlendMode.difference,
                borderRadius:
                    BorderRadius.all(Radius.circular(80 * renderScale))),
            child: Text('Demonstration File',
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    color: const Color(0x99999999),
                    fontSize: 180 * renderScale,
                    fontFamily: 'Poppins')),
          ),
        ),
      ),
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
      background: getBackgroundDecoration(
        slides,
        currentSlideId,
      ),
      child: LayoutCanvas(
        interactive: false,
        elements: buildElements(
          elements: slide.elements,
          actors: actors,
          tracks: tracks,
          trackRefsByName: trackRefsByName,
          castChange: displayedCastChange,
        ),
        renderScale: renderScale,
      ),
    );
  }

  Size _getWindowSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }
}

class _UnknownErrorFallback extends StatelessWidget {
  const _UnknownErrorFallback({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sentiment_dissatisfied, size: 32),
        ],
      ),
    );
  }
}

class _NoSlidesFallback extends StatelessWidget {
  const _NoSlidesFallback({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.slideshow, size: 32),
        const SizedBox(
          height: 16,
        ),
        Text('No Slides', style: Theme.of(context).textTheme.titleLarge),
      ]),
    );
  }
}
