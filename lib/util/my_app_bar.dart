import 'package:flutter/material.dart';

class MyAppBar extends AppBar {
  MyAppBar({
    super.key,
    required String title,
    super.actions,
    super.leading,
    super.backgroundColor,
    double super.elevation = 0,
  }) : super(
         automaticallyImplyLeading: leading != null,
         title: Builder(
           builder:
               (context) => Padding(
                 padding:
                     leading == null
                         ? const EdgeInsets.only(left: 16)
                         : const EdgeInsets.all(0),
                 child: Text(
                   title,
                   style: Theme.of(context).textTheme.displayLarge,
                 ),
               ),
         ),
         actionsPadding: const EdgeInsets.only(right: 16),
         scrolledUnderElevation: 0.0,
         titleSpacing: 8.0,
       );
}
