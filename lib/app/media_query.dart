// Clamps the system text scale factor for the entire widget tree.
//
// Without this, a user with a 3x system font size can break any fixed-size
// layout. Applied once at the root so individual widgets do not need to
// guard against extreme scale values.

import 'package:flutter/widgets.dart';

/// Clamps text scale factor so large system font sizes don't break the UI.
class MediaQueryRootOverride extends StatelessWidget {
  const MediaQueryRootOverride({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(maxScaleFactor: 2, child: child);
  }
}
