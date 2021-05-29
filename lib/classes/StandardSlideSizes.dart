import 'package:castboard_core/models/SlideSizeModel.dart';

class StandardSlideSizes {
  static final defaultSizeId = const SlideSizeModel.fullHD().uid;

  static final Map<String?, SlideSizeModel> all = {
    const SlideSizeModel.hd().uid: const SlideSizeModel.hd(),
    const SlideSizeModel.fullHD().uid: const SlideSizeModel.fullHD(),
    const SlideSizeModel.twoK().uid: const SlideSizeModel.twoK(),
    const SlideSizeModel.fourK().uid: const SlideSizeModel.fourK(),
  };

  static SlideSizeModel? get defaultSize => all[defaultSizeId];
}
