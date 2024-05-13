import 'package:flutter/material.dart';
import 'package:footsteps/utils/widgets/rounded_container.dart';

class FindingLocationLoading extends StatelessWidget {
  const FindingLocationLoading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: RoundedContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 10),
              Text('Finding your location...'),
            ],
          ),
        ),
      ),
    );
  }
}
