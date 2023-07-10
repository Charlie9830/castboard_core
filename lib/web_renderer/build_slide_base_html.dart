import 'package:castboard_core/models/SlideSizeModel.dart';
import 'package:html/dom.dart';

Document buildSlideBaseHTML(SlideSizeModel slideSize) {
  return Document.html('''
<!doctype html>
    <html>
    <head>
    <title>Castboard Performer</title>
    <meta name="Castboard Performer" content="Castboard Performer">
    <style>
      @font-face {
      font-family: Fredoka One;
      src: url(FredokaOne-Regular.ttf);
    }
    </style>
    </head>
    <body>
    </body>
    </html>
''');
}
