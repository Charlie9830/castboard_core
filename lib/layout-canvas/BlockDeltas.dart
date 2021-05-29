class BlockDelta {
  final double width;
  final double height;
  final double xPos;
  final double yPos;

  BlockDelta({
    this.width = 0.0,
    this.height = 0.0,
    this.xPos = 0.0,
    this.yPos = 0.0,
  });

  BlockDelta scaled(double xRatio, double yRatio) {
    return BlockDelta(
      height: height * yRatio,
      width: width * xRatio,
      xPos: xPos * xRatio,
      yPos: yPos * yRatio,
    );
  }
}
