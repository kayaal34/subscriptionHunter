import 'dart:io';
import 'package:flutter/material.dart';
import 'package:subscription_tracker/domain/entities/subscription.dart';

class SubscriptionAvatar extends StatelessWidget {
  const SubscriptionAvatar({
    Key? key,
    required this.subscription,
    this.size = 56,
    this.fontSize = 24,
  }) : super(key: key);

  final Subscription subscription;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
        image: subscription.imagePath != null
            ? DecorationImage(
                image: FileImage(File(subscription.imagePath!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: subscription.imagePath == null
          ? Center(
              child: Text(
                subscription.icon,
                style: TextStyle(
                  fontSize: fontSize * 0.9,
                ),
              ),
            )
          : null,
    );
}
