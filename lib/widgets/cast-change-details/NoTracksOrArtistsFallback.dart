import 'package:castboard_core/utils/is_mobile_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const String kMessage =
    "There are no Cast Changes to display. Please user the designer desktop application to add these to your showfile.";

class NoTracksOrArtistsFallback extends StatelessWidget {
  const NoTracksOrArtistsFallback({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isMobileLayout(context)) {
      return Center(
        child: Text(kMessage, style: Theme.of(context).textTheme.bodySmall),
      );
    }

    if (kIsWeb) {
      return Text(kMessage, style: Theme.of(context).textTheme.bodySmall);
    }

    return Text(
        'Tracks and Artists you create will appear here ready to be assigned to eachother.',
        style: Theme.of(context).textTheme.bodySmall);
  }
}
