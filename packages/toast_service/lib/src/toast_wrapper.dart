import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastWrapper extends StatelessWidget {
  const ToastWrapper({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => ToastificationWrapper(child: child);
}
