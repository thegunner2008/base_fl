import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class EmoSimmer extends StatelessWidget {
  final Widget? child;
  final bool? isLoading;

  const EmoSimmer({Key? key, this.isLoading = true, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return isLoading!
        ? Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.white,
            enabled: true,
            child: child!)
        : child!;
  }
}
