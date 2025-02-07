import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../config/constants.dart';
import 'device.dart';

class ContainerShimmer extends StatelessWidget {
  const ContainerShimmer({super.key, required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(width: width, height: height, decoration: const BoxDecoration(color: Colors.white)));
  }
}

class ListShimmer extends StatelessWidget {
  const ListShimmer({super.key, required this.length});

  final int length;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
            children: List.generate(
          length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: kPadding),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
              Container(
                  decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(kPadding * 2))),
                  width: kPadding * 10,
                  height: kPadding * 10),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0)),
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Container(width: double.infinity, height: kPadding * 2, color: Colors.white),
                const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                Container(width: double.infinity, height: kPadding * 2, color: Colors.white),
                const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                Container(width: 50, height: kPadding * 2, color: Colors.white)
              ])),
            ]),
          ),
        )));
  }
}

class ListTileShimmer extends StatelessWidget {
  const ListTileShimmer({super.key, required this.widthHeading, required this.widthValue, required this.heightHeading, required this.heightValue});

  final double widthHeading;
  final double widthValue;
  final double heightHeading;
  final double heightValue;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(kPadding * 1))),
                width: widthHeading,
                height: heightHeading),
            SizedBox(height: Device.margin(context)),
            Container(
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(kPadding * 1))),
                width: widthValue,
                height: heightValue)
          ],
        ));
  }
}
