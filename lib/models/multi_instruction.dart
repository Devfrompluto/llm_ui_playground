import 'layout_instruction.dart';

class MultiInstruction {
  final List<LayoutInstruction> instructions;
  final String? description;

  MultiInstruction({
    required this.instructions,
    this.description,
  });

  factory MultiInstruction.fromJson(Map<String, dynamic> json) {
    return MultiInstruction(
      instructions: (json['instructions'] as List)
          .map((instruction) => LayoutInstruction.fromJson(instruction))
          .toList(),
      description: json['description'],
    );
  }

  // Convert single instruction to multi instruction for compatibility
  factory MultiInstruction.fromSingle(LayoutInstruction instruction) {
    return MultiInstruction(
      instructions: [instruction],
    );
  }
}