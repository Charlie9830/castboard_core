import 'package:castboard_core/models/system_controller/DeviceResolution.dart';

class AvailableResolutions {
  final List<DeviceResolution> resolutions;

  AvailableResolutions(this.resolutions);

  const AvailableResolutions.none() : resolutions = const [];

  Map<String, dynamic> toMap() {
    return {
      'resolutions': resolutions.map((item) => item.toMap()).toList(),
    };
  }

  factory AvailableResolutions.fromMap(Map<String, dynamic> map) {
    if (map['resolutions'] == null) {
      return AvailableResolutions.none();
    }
    return AvailableResolutions(
      List<DeviceResolution>.from(
          map['resolutions'].map((item) => DeviceResolution.fromMap(item))),
    );
  }
}
