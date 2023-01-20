import 'package:castboard_core/utils/is_mobile_layout.dart';
import 'package:flutter/material.dart';

class NoTracksOrArtistsFallback extends StatelessWidget {
  const NoTracksOrArtistsFallback({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isMobileLayout(context)) {
      return Text(
          "Uh oh.. There aren't any tracks or artists. Please user the designer desktop application to add these to your showfile.",
          style: Theme.of(context).textTheme.caption);
    }

    return Text(
        'Tracks and Artists you create will appear here ready to be assigned to eachother.',
        style: Theme.of(context).textTheme.caption);
  }
}
