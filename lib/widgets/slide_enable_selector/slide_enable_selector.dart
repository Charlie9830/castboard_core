import 'package:castboard_core/models/SlideModel.dart';
import 'package:flutter/material.dart';

class SlideEnableSelector extends StatelessWidget {
  final List<SlideModel> slides;
  final Set<String> disabledSlideIds;
  final void Function(Set<String> value) onDisabledSlideIdsChanged;

  const SlideEnableSelector({
    Key? key,
    required this.slides,
    required this.disabledSlideIds,
    required this.onDisabledSlideIdsChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final slideVms = _buildVMs()..sort((a, b) => a.slide.index - b.slide.index);

    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              tristate: true,
              value: _reduceAllEnabledState(slideVms),
              onChanged: (value) => _handleAllCheckboxChanged(value, slideVms),
            ),
            const SizedBox(width: 12),
            Text('All', style: Theme.of(context).textTheme.caption),
          ],
        ),
        ListView(
            primary: false,
            shrinkWrap: true,
            children: slideVms
                .map((item) => CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      value: item.isEnabled,
                      title: Text(_getSlideName(item.slide)),
                      onChanged: (value) =>
                          _handleSlideEnabledChanged(value, item.slide.uid),
                    ))
                .toList()),
      ],
    );
  }

  String _getSlideName(SlideModel slide) {
    if (slide.name.isEmpty) {
      return 'Slide ${slide.index + 1}';
    }

    return slide.name;
  }

  bool? _reduceAllEnabledState(List<_SlideViewModel> slideVms) {
    if (slideVms.every((element) => element.isEnabled == true)) {
      return true;
    }

    if (slideVms.every((element) => element.isEnabled == false)) {
      return false;
    }

    return null;
  }

  List<_SlideViewModel> _buildVMs() {
    return slides
        .map((slide) => _SlideViewModel(
            slide: slide,
            isEnabled: disabledSlideIds.contains(slide.uid) == false))
        .toList();
  }

  void _handleSlideEnabledChanged(bool? value, String slideId) {
    final concrete = value ?? false;

    if (concrete == true) {
      onDisabledSlideIdsChanged(disabledSlideIds.toSet()..remove(slideId));
    } else {
      onDisabledSlideIdsChanged(disabledSlideIds.toSet()..add(slideId));
    }
  }

  void _handleAllCheckboxChanged(bool? value, List<_SlideViewModel> slideVms) {
    enableAllSlides() => onDisabledSlideIdsChanged(disabledSlideIds.toSet()
      ..removeAll(slideVms.map((vm) => vm.slide.uid)));

    disableAllSlides() => onDisabledSlideIdsChanged(
        disabledSlideIds.toSet()..addAll(slideVms.map((vm) => vm.slide.uid)));

    // Enable all if Tristate is null;
    if (value == null) {
      disableAllSlides();
      return;
    }

    if (value == true) {
      enableAllSlides();
      return;
    }

    enableAllSlides();
  }
}

class _SlideViewModel {
  final SlideModel slide;
  final bool isEnabled;

  _SlideViewModel({
    required this.slide,
    required this.isEnabled,
  });
}
