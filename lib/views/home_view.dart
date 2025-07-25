import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'widgets/input_bar.dart';
import 'widgets/dynamic_component.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: controller.backgroundColor.value,
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildComponentsList(context)),
              InputBar(controller: controller),
            ],
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        controller.title.value,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: _getContrastColor(controller.backgroundColor.value),
      actions: [
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: () => Get.toNamed('/history'),
          tooltip: 'Prompt History',
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => Get.toNamed('/settings'),
          tooltip: 'LLM Settings',
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: controller.reset,
          tooltip: 'Reset',
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getContrastColor(
          controller.backgroundColor.value,
        ).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getContrastColor(
            controller.backgroundColor.value,
          ).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'UI Playground',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _getContrastColor(controller.backgroundColor.value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Components: ${controller.components.length}',
            style: TextStyle(
              fontSize: 14,
              color: _getContrastColor(
                controller.backgroundColor.value,
              ).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentsList(BuildContext context) {
    if (controller.components.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: controller.components.length,
      itemBuilder: (context, index) {
        final instruction = controller.components[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: DynamicComponent(
              instruction: instruction,
              index: index,
              onRemove: () => controller.removeComponent(index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.widgets_outlined,
              size: 48,
              color: _getContrastColor(
                controller.backgroundColor.value,
              ).withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No components yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _getContrastColor(controller.backgroundColor.value),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try typing or speaking commands like:\n"add a red button", "add a textfield", or "change background to blue"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: _getContrastColor(
                controller.backgroundColor.value,
              ).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          _buildQuickActionChips(),
        ],
      ),
    );
  }

  Widget _buildQuickActionChips() {
    final quickActions = [
      {'label': 'Add Button', 'command': 'add a red button'},
      {'label': 'Add TextField', 'command': 'add a textfield'},
      {'label': 'Add Switch', 'command': 'add a toggle switch'},
      {'label': 'Add Icon', 'command': 'add a heart icon'},
      {'label': 'Add Slider', 'command': 'add a blue slider'},
      {'label': 'Change Background', 'command': 'change background to blue'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          quickActions.map((action) {
            return ActionChip(
              label: Text(action['label']!),
              onPressed: () => controller.handlePrompt(action['command']!),
              backgroundColor: Colors.blue.withOpacity(0.1),
              labelStyle: const TextStyle(color: Colors.blue),
            );
          }).toList(),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      heroTag: "add",
      onPressed: () => _showQuickAddDialog(),
      backgroundColor: Colors.blue,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _showQuickAddDialog() {
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(Get.context!).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    _buildQuickActionTile(
                      'Add Red Button',
                      'add a red button',
                      Icons.smart_button,
                      Colors.red,
                    ),
                    _buildQuickActionTile(
                      'Add TextField',
                      'add textfield with placeholder "Enter name"',
                      Icons.text_fields,
                      Colors.blue,
                    ),
                    _buildQuickActionTile(
                      'Add Toggle Switch',
                      'add a blue toggle switch',
                      Icons.toggle_on,
                      Colors.blue,
                    ),
                    _buildQuickActionTile(
                      'Add Heart Icon',
                      'add a red heart icon',
                      Icons.favorite,
                      Colors.red,
                    ),
                    _buildQuickActionTile(
                      'Add Slider',
                      'add a green slider',
                      Icons.tune,
                      Colors.green,
                    ),
                    _buildQuickActionTile(
                      'Add Checkbox',
                      'add a checkbox for terms',
                      Icons.check_box,
                      Colors.purple,
                    ),
                    _buildQuickActionTile(
                      'Add Progress Bar',
                      'add a blue progress bar',
                      Icons.trending_up,
                      Colors.blue,
                    ),
                    _buildQuickActionTile(
                      'Add Image Placeholder',
                      'add an image placeholder',
                      Icons.image,
                      Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildQuickActionTile(
    String title,
    String command,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title),
      onTap: () {
        Get.back();
        controller.handlePrompt(command);
      },
    );
  }

  Color _getContrastColor(Color backgroundColor) {
    // Calculate luminance to determine if we should use light or dark text
    double luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
