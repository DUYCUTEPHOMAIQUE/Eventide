import 'package:flutter/material.dart';
import 'package:enva/theme/app_theme.dart';

class SmartInputField extends StatefulWidget {
  final String label;
  final String value;
  final List<String> suggestions;
  final Function(String) onChanged;
  final IconData? icon;
  final int maxLines;
  final TextInputType keyboardType;
  final String? hintText;
  final bool required;

  const SmartInputField({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.suggestions = const [],
    this.icon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.hintText,
    this.required = false,
  }) : super(key: key);

  @override
  State<SmartInputField> createState() => _SmartInputFieldState();
}

class _SmartInputFieldState extends State<SmartInputField>
    with TickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _showSuggestions = false;
  List<String> _filteredSuggestions = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    _animationController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.defaultCurve,
    ));

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _showSuggestionsDropdown();
    } else {
      _hideSuggestionsDropdown();
    }
  }

  void _onTextChanged(String value) {
    widget.onChanged(value);
    _filterSuggestions(value);

    if (value.isNotEmpty && widget.suggestions.isNotEmpty) {
      _showSuggestionsDropdown();
    } else {
      _hideSuggestionsDropdown();
    }
  }

  void _filterSuggestions(String query) {
    if (query.isEmpty) {
      _filteredSuggestions = widget.suggestions.take(5).toList();
    } else {
      _filteredSuggestions = widget.suggestions
          .where((s) => s.toLowerCase().contains(query.toLowerCase()))
          .take(5)
          .toList();
    }
  }

  void _showSuggestionsDropdown() {
    if (widget.suggestions.isNotEmpty && !_showSuggestions) {
      setState(() {
        _showSuggestions = true;
        _filterSuggestions(_controller.text);
      });
      _animationController.forward();
    }
  }

  void _hideSuggestionsDropdown() {
    if (_showSuggestions) {
      _animationController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _showSuggestions = false;
          });
        }
      });
    }
  }

  void _selectSuggestion(String suggestion) {
    _controller.text = suggestion;
    widget.onChanged(suggestion);
    _hideSuggestionsDropdown();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(
                  widget.label,
                  style: AppTypography.subtitle2.copyWith(
                    color: Colors.white70,
                  ),
                ),
                if (widget.required)
                  Text(
                    ' *',
                    style: AppTypography.subtitle2.copyWith(
                      color: AppTheme.accentRed,
                    ),
                  ),
              ],
            ),
          ),

        // Input field
        AnimatedContainer(
          duration: AppAnimations.fast,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? AppTheme.primaryPurple
                  : Colors.white.withOpacity(0.2),
              width: _focusNode.hasFocus ? 2 : 1,
            ),
            boxShadow: _focusNode.hasFocus
                ? [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onTextChanged,
            maxLines: widget.maxLines,
            keyboardType: widget.keyboardType,
            style: AppTypography.body1.copyWith(color: Colors.white),
            decoration: InputDecoration(
              hintText: widget.hintText ?? widget.label,
              hintStyle: AppTypography.body1.copyWith(
                color: Colors.white.withOpacity(0.5),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              prefixIcon: widget.icon != null
                  ? Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 20,
                      ),
                    )
                  : null,
              suffixIcon: widget.suggestions.isNotEmpty
                  ? AnimatedRotation(
                      turns: _showSuggestions ? 0.5 : 0.0,
                      duration: AppAnimations.fast,
                      child: Icon(
                        Icons.expand_more,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    )
                  : null,
            ),
          ),
        ),

        // Suggestions dropdown
        if (_showSuggestions && _filteredSuggestions.isNotEmpty)
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: AppTheme.gray800,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryPurple.withOpacity(0.3),
                ),
                boxShadow: AppTheme.dropdownShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredSuggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _filteredSuggestions[index];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _selectSuggestion(suggestion),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.history,
                                color: Colors.white.withOpacity(0.5),
                                size: 16,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  suggestion,
                                  style: AppTypography.body2.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.north_west,
                                color: Colors.white.withOpacity(0.3),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}
