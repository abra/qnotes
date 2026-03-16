import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

enum NotificationType { success, error }

void showNotification(
  BuildContext context, {
  required NotificationType type,
  required String message,
}) {
  toastification.show(
    context: context,
    type: switch (type) {
      NotificationType.success => ToastificationType.success,
      NotificationType.error => ToastificationType.error,
    },
    style: ToastificationStyle.flat,
    title: Text(message),
    autoCloseDuration: const Duration(seconds: 3),
    alignment: Alignment.topCenter,
    animationBuilder: (context, animation, alignment, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  );
}
