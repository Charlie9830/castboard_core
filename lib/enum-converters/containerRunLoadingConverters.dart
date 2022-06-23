import 'package:castboard_core/enum-converters/EnumConversionError.dart';
import 'package:castboard_core/enums.dart';

ContainerRunLoading parseContainerRunLoading(String value) {
  switch (value) {
    case 'bottomOrRightHeavy':
      return ContainerRunLoading.bottomOrRightHeavy;
    case 'topOrLeftHeavy':
      return ContainerRunLoading.topOrLeftHeavy;
    default:
      throw EnumConversionError(
          'Unknown value when trying to parse String into ContainerRunLoading. Unknown value is $value');
  }
}

String convertContainerRunLoading(ContainerRunLoading value) {
  switch (value) {
    case ContainerRunLoading.bottomOrRightHeavy:
      return 'bottomOrRightHeavy';
    case ContainerRunLoading.topOrLeftHeavy:
      return 'topOrLeftHeavy';
    default:
      return 'topOrLeftHeavy';
  }
}
