class BlockDelta {
  final double width;
  final double height;
  final double xPos;
  final double yPos;

  BlockDelta({this.width, this.height, this.xPos, this.yPos});

  BlockDelta scaled(double xRatio, double yRatio) {
    return BlockDelta(
      height: height * yRatio,
      width: width * xRatio,
      xPos: xPos * xRatio,
      yPos: yPos * yRatio,
    );
  }
}
