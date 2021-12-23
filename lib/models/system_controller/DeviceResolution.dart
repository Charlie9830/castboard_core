class DeviceResolution {
  final int width;
  final int height;
  final bool auto;

  const DeviceResolution(this.width, this.height) : auto = false;


  const DeviceResolution.auto()
      : width = 0,
        height = 0,
        auto = true;

  Map<String, dynamic> toMap() {
    return {
      'width': width,
      'height': height,
      'auto': auto,
    };
  }

  factory DeviceResolution.fromMap(Map<String, dynamic> map) {
    if (map['auto'] == true) {
      return DeviceResolution.auto();
    }

    return DeviceResolution(
      map['width'],
      map['height'],
    );
  }

  String get uid => '$width, $height, $auto';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeviceResolution &&
        other.width == width &&
        other.height == height &&
        other.auto == auto;
  }

  @override
  int get hashCode => width.hashCode ^ height.hashCode ^ auto.hashCode;
}
