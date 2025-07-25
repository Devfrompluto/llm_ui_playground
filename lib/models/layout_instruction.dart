import 'package:flutter/material.dart';

class LayoutInstruction {
  final String action;
  final String? component;
  final String? color;
  final String? label;
  final double? size;
  final Axis? axis;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final List<LayoutInstruction>? children;

  LayoutInstruction({
    required this.action,
    this.component,
    this.color,
    this.label,
    this.size,
    this.axis,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.children,
  });

  factory LayoutInstruction.fromJson(Map<String, dynamic> json) {
    return LayoutInstruction(
      action: json['action'],
      component: json['component'],
      color: json['color'],
      label: json['label'],
      size: json['size']?.toDouble(),
      axis: json['axis'] != null ? Axis.values.byName(json['axis']) : null,
      mainAxisAlignment: json['mainAxisAlignment'] != null
          ? MainAxisAlignment.values.byName(json['mainAxisAlignment'])
          : null,
      crossAxisAlignment: json['crossAxisAlignment'] != null
          ? CrossAxisAlignment.values.byName(json['crossAxisAlignment'])
          : null,
      children: json['children'] != null
          ? (json['children'] as List)
              .map((child) => LayoutInstruction.fromJson(child))
              .toList()
          : null,
    );
  }
}
