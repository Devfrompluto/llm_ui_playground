import 'package:flutter/material.dart';
import '../../models/layout_instruction.dart';
import '../../services/prompt_service.dart';

class DynamicComponent extends StatefulWidget {
  final LayoutInstruction instruction;
  final int index;
  final VoidCallback? onRemove;

  const DynamicComponent({
    super.key,
    required this.instruction,
    required this.index,
    this.onRemove,
  });

  @override
  State<DynamicComponent> createState() => _DynamicComponentState();
}

class _DynamicComponentState extends State<DynamicComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;
  
  // State variables for interactive components
  bool _switchValue = false;
  double _sliderValue = 50.0;
  bool _checkboxValue = false;
  String _radioValue = '';
  String _dropdownValue = '';
  double _progressValue = 0.5;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation.drive(
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildComponent(context),
      ),
    );
  }

  Widget _buildComponent(BuildContext context) {
    switch (widget.instruction.component) {
      case 'button':
        return _buildButton(context);
      case 'container':
        return _buildContainer(context);
      case 'textfield':
        return _buildTextField(context);
      case 'text':
        return _buildText(context);
      case 'card':
        return _buildCard(context);
      case 'switch':
        return _buildSwitch(context);
      case 'slider':
        return _buildSlider(context);
      case 'checkbox':
        return _buildCheckbox(context);
      case 'radio':
        return _buildRadio(context);
      case 'dropdown':
        return _buildDropdown(context);
      case 'image':
        return _buildImage(context);
      case 'icon':
        return _buildIcon(context);
      case 'divider':
        return _buildDivider(context);
      case 'progress':
        return _buildProgress(context);
      case 'listitem':
        return _buildListItem(context);
      case 'chip':
        return _buildChip(context);
      case 'badge':
        return _buildBadge(context);
      case 'fab':
        return _buildFloatingActionButton(context);
      case 'iconbutton':
        return _buildIconButton(context);
      case 'textbutton':
        return _buildTextButton(context);
      case 'outlinedbutton':
        return _buildOutlinedButton(context);
      case 'passwordfield':
        return _buildPasswordField(context);
      case 'emailfield':
        return _buildEmailField(context);
      case 'numberfield':
        return _buildNumberField(context);
      case 'textarea':
        return _buildTextArea(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildButton(BuildContext context) {
    final color =
        PromptService.getColorFromString(widget.instruction.color) ??
        Colors.blue;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(right: 50),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: _getContrastColor(color),
                  elevation: 4,
                  shadowColor: color.withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  setState(() => _isPressed = true);
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (mounted) setState(() => _isPressed = false);
                  });
                  _showInteractionSnackbar('Button tapped!');
                },
                icon: Icon(
                  Icons.touch_app,
                  size: 20,
                  color: _getContrastColor(color),
                ),
                label: Text(
                  widget.instruction.label ?? 'Button',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _getContrastColor(color),
                  ),
                ),
              ),
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  Widget _buildContainer(BuildContext context) {
    final color =
        PromptService.getColorFromString(widget.instruction.color) ??
        Colors.grey;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 100,
            margin: const EdgeInsets.only(right: 50),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showInteractionSnackbar('Container tapped!'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.widgets,
                        color: _getContrastColor(color),
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.instruction.label ?? 'Container',
                        style: TextStyle(
                          color: _getContrastColor(color),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 50),
            child: TextField(
              decoration: InputDecoration(
                hintText: widget.instruction.label ?? 'Enter text...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                prefixIcon: const Icon(Icons.edit),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onChanged: (value) {
                // Text input handling - no snackbar needed
              },
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  Widget _buildText(BuildContext context) {
    final color = PromptService.getColorFromString(widget.instruction.color) ?? 
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final fontSize = widget.instruction.size ?? 16.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(right: 50),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.text_fields,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.instruction.label ?? 'Sample Text',
                    style: TextStyle(
                      color: color,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(right: 50),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
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
                            Icons.credit_card,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.instruction.label ?? 'Card',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This is a card component that can contain other widgets.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  // NEW COMPONENTS IMPLEMENTATION

  Widget _buildSwitch(BuildContext context) {
    final color = PromptService.getColorFromString(widget.instruction.color) ?? Colors.blue;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(right: 50),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.toggle_on, color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.instruction.label ?? 'Toggle Switch',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                Switch(
                  value: _switchValue,
                  activeColor: color,
                  onChanged: (value) {
                    setState(() => _switchValue = value);
                    _showInteractionSnackbar('Switch ${value ? 'ON' : 'OFF'}');
                  },
                ),
              ],
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  Widget _buildSlider(BuildContext context) {
    final color = PromptService.getColorFromString(widget.instruction.color) ?? Colors.blue;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(right: 50),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.tune, color: color, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      widget.instruction.label ?? 'Slider',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Text(
                      '${_sliderValue.round()}',
                      style: TextStyle(color: color, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  value: _sliderValue,
                  min: 0,
                  max: 100,
                  activeColor: color,
                  onChanged: (value) {
                    setState(() => _sliderValue = value);
                  },
                  onChangeEnd: (value) {
                    _showInteractionSnackbar('Slider value: ${value.round()}');
                  },
                ),
              ],
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    final color = PromptService.getColorFromString(widget.instruction.color) ?? Colors.blue;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(right: 50),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _checkboxValue,
                  activeColor: color,
                  onChanged: (value) {
                    setState(() => _checkboxValue = value ?? false);
                    _showInteractionSnackbar('Checkbox ${value! ? 'checked' : 'unchecked'}');
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.instruction.label ?? 'Checkbox Option',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  Widget _buildRadio(BuildContext context) {
    final color = PromptService.getColorFromString(widget.instruction.color) ?? Colors.blue;
    final options = ['Option 1', 'Option 2', 'Option 3'];
    if (_radioValue.isEmpty) _radioValue = options.first;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(right: 50),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.radio_button_checked, color: color, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      widget.instruction.label ?? 'Radio Options',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...options.map((option) => RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: _radioValue,
                  activeColor: color,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() => _radioValue = value!);
                    _showInteractionSnackbar('Selected: $value');
                  },
                )),
              ],
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  Widget _buildDropdown(BuildContext context) {
    final color = PromptService.getColorFromString(widget.instruction.color) ?? Colors.blue;
    final options = ['Select Option', 'Option A', 'Option B', 'Option C'];
    if (_dropdownValue.isEmpty) _dropdownValue = options.first;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(right: 50),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.arrow_drop_down_circle, color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    value: _dropdownValue,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: options.map((option) => DropdownMenuItem(
                      value: option,
                      child: Text(option),
                    )).toList(),
                    onChanged: (value) {
                      setState(() => _dropdownValue = value!);
                      if (value != options.first) {
                        _showInteractionSnackbar('Selected: $value');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final color = PromptService.getColorFromString(widget.instruction.color) ?? Colors.grey;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 150,
            margin: const EdgeInsets.only(right: 50),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3), width: 2, style: BorderStyle.solid),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showInteractionSnackbar('Image tapped!'),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, color: color, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      widget.instruction.label ?? 'Image Placeholder',
                      style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final color = PromptService.getColorFromString(widget.instruction.color) ?? Colors.blue;
    final iconData = _getIconFromLabel(widget.instruction.label);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(right: 50),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(iconData, color: color, size: 32),
                const SizedBox(width: 12),
                Text(
                  widget.instruction.label ?? 'Icon',
                  style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final color = PromptService.getColorFromString(widget.instruction.color) ?? Colors.grey;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(right: 50),
            child: Column(
              children: [
                if (widget.instruction.label != null) ...[
                  Text(
                    widget.instruction.label!,
                    style: TextStyle(color: color, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                ],
                Divider(color: color, thickness: 2),
              ],
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  Widget _buildProgress(BuildContext context) {
    final color = PromptService.getColorFromString(widget.instruction.color) ?? Colors.blue;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(right: 50),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.trending_up, color: color, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      widget.instruction.label ?? 'Progress',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Text(
                      '${(_progressValue * 100).round()}%',
                      style: TextStyle(color: color, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _progressValue,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ],
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context) {
    final color = PromptService.getColorFromString(widget.instruction.color) ?? Colors.blue;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(right: 50),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: color, child: Icon(Icons.person, color: Colors.white)),
              title: Text(widget.instruction.label ?? 'List Item'),
              subtitle: const Text('Subtitle text'),
              trailing: Icon(Icons.arrow_forward_ios, color: color),
              onTap: () => _showInteractionSnackbar('List item tapped!'),
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context) {
    final color = PromptService.getColorFromString(widget.instruction.color) ?? Colors.blue;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(right: 50),
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(widget.instruction.label ?? 'Chip'),
                  backgroundColor: color.withOpacity(0.1),
                  labelStyle: TextStyle(color: color),
                  deleteIcon: Icon(Icons.close, size: 16, color: color),
                  onDeleted: () => _showInteractionSnackbar('Chip deleted!'),
                ),
              ],
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  Widget _buildBadge(BuildContext context) {
    final color = PromptService.getColorFromString(widget.instruction.color) ?? Colors.red;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(right: 50),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Badge(
                  label: Text(widget.instruction.label ?? '5'),
                  backgroundColor: color,
                  child: Icon(Icons.notifications, size: 32, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                const Text('Notification with badge', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(context) {
    final color = PromptService.getColorFromString(widget.instruction.color) ?? Colors.blue;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(right: 50),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  backgroundColor: color,
                  foregroundColor: _getContrastColor(color),
                  onPressed: () => _showInteractionSnackbar('FAB tapped!'),
                  child: const Icon(Icons.add),
                ),
                const SizedBox(width: 16),
                Text(
                  widget.instruction.label ?? 'Floating Action Button',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  Widget _buildIconButton(BuildContext context) {
    final color = PromptService.getColorFromString(widget.instruction.color) ?? Colors.blue;
    final iconData = _getIconFromLabel(widget.instruction.label);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(right: 50),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(iconData, color: color),
                  onPressed: () => _showInteractionSnackbar('Icon button tapped!'),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.instruction.label ?? 'Icon Button',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  Widget _buildTextButton(BuildContext context) {
    final color = PromptService.getColorFromString(widget.instruction.color) ?? Colors.blue;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(right: 50),
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              ),
              onPressed: () => _showInteractionSnackbar('Text button tapped!'),
              child: Text(
                widget.instruction.label ?? 'Text Button',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    final color = PromptService.getColorFromString(widget.instruction.color) ?? Colors.blue;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(right: 50),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _showInteractionSnackbar('Outlined button tapped!'),
              child: Text(
                widget.instruction.label ?? 'Outlined Button',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 50),
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: widget.instruction.label ?? 'Enter password...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: const Icon(Icons.visibility_off),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 50),
            child: TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: widget.instruction.label ?? 'Enter email...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                prefixIcon: const Icon(Icons.email),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  Widget _buildNumberField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 50),
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: widget.instruction.label ?? 'Enter number...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                prefixIcon: const Icon(Icons.numbers),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  Widget _buildTextArea(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 50),
            child: TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: widget.instruction.label ?? 'Enter text...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                prefixIcon: const Icon(Icons.text_snippet),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  // HELPER METHODS

  IconData _getIconFromLabel(String? label) {
    if (label == null) return Icons.star;
    final lowerLabel = label.toLowerCase();
    
    if (lowerLabel.contains('heart')) return Icons.favorite;
    if (lowerLabel.contains('star')) return Icons.star;
    if (lowerLabel.contains('home')) return Icons.home;
    if (lowerLabel.contains('user') || lowerLabel.contains('person')) return Icons.person;
    if (lowerLabel.contains('settings')) return Icons.settings;
    if (lowerLabel.contains('search')) return Icons.search;
    if (lowerLabel.contains('phone')) return Icons.phone;
    if (lowerLabel.contains('email') || lowerLabel.contains('mail')) return Icons.email;
    if (lowerLabel.contains('location') || lowerLabel.contains('map')) return Icons.location_on;
    if (lowerLabel.contains('camera')) return Icons.camera_alt;
    if (lowerLabel.contains('music')) return Icons.music_note;
    if (lowerLabel.contains('video')) return Icons.videocam;
    if (lowerLabel.contains('photo') || lowerLabel.contains('image')) return Icons.photo;
    if (lowerLabel.contains('calendar')) return Icons.calendar_today;
    if (lowerLabel.contains('clock') || lowerLabel.contains('time')) return Icons.access_time;
    if (lowerLabel.contains('notification') || lowerLabel.contains('bell')) return Icons.notifications;
    if (lowerLabel.contains('menu')) return Icons.menu;
    if (lowerLabel.contains('close') || lowerLabel.contains('x')) return Icons.close;
    if (lowerLabel.contains('check') || lowerLabel.contains('tick')) return Icons.check;
    if (lowerLabel.contains('add') || lowerLabel.contains('plus')) return Icons.add;
    if (lowerLabel.contains('edit')) return Icons.edit;
    if (lowerLabel.contains('delete') || lowerLabel.contains('trash')) return Icons.delete;
    if (lowerLabel.contains('share')) return Icons.share;
    if (lowerLabel.contains('download')) return Icons.download;
    if (lowerLabel.contains('upload')) return Icons.upload;
    if (lowerLabel.contains('play')) return Icons.play_arrow;
    if (lowerLabel.contains('pause')) return Icons.pause;
    if (lowerLabel.contains('stop')) return Icons.stop;
    if (lowerLabel.contains('refresh')) return Icons.refresh;
    if (lowerLabel.contains('info')) return Icons.info;
    if (lowerLabel.contains('warning')) return Icons.warning;
    if (lowerLabel.contains('error')) return Icons.error;
    if (lowerLabel.contains('success')) return Icons.check_circle;
    
    return Icons.star; // Default icon
  }

  Widget _buildRemoveButton() {
    return Positioned(
      right: 8,
      top: 8,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              if (widget.onRemove != null) {
                _animationController.reverse().then((_) {
                  widget.onRemove!();
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ),
    );
  }

  Color _getContrastColor(Color color) {
    double luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  void _showInteractionSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
