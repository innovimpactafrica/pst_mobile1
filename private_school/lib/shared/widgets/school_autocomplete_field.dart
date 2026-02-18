import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/app_colors.dart';
import '../../parents/pages/school/data/models/school_model.dart';

class SchoolAutocompleteField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final List<SchoolModel> schools;
  final Function(SchoolModel? school, String schoolName) onSchoolSelected;
  final bool enabled;

  const SchoolAutocompleteField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.schools,
    required this.onSchoolSelected,
    this.enabled = true,
  });

  @override
  State<SchoolAutocompleteField> createState() => _SchoolAutocompleteFieldState();
}

class _SchoolAutocompleteFieldState extends State<SchoolAutocompleteField> {
  List<SchoolModel> _suggestions = [];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 5),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _suggestions.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Aucune école trouvée',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final school = _suggestions[index];
                        return ListTile(
                          leading: const Icon(Icons.school, color: AppColors.success),
                          title: Text(
                            school.name,
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                          subtitle: school.address.isNotEmpty
                              ? Text(
                                  school.address,
                                  style: GoogleFonts.inter(fontSize: 12),
                                )
                              : null,
                          onTap: () => _selectSchool(school),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSearchChanged(String value) {
    if (value.isEmpty) {
      _removeOverlay();
      setState(() => _suggestions = []);
      return;
    }

    final query = value.toLowerCase();
    final matchingSchools = widget.schools.where((school) {
      return school.name.toLowerCase().contains(query) ||
             school.address.toLowerCase().contains(query);
    }).toList();

    setState(() => _suggestions = matchingSchools);
    _showOverlay();
    
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _selectSchool(SchoolModel school) {
    widget.controller.text = school.name;
    _removeOverlay();
    setState(() => _suggestions = []);
    widget.onSchoolSelected(school, school.name);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        CompositedTransformTarget(
          link: _layerLink,
          child: TextFormField(
            controller: widget.controller,
            enabled: widget.enabled,
            onChanged: _onSearchChanged,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
              prefixIcon: Icon(Icons.school_outlined, color: AppColors.success.withValues(alpha: 0.7)),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        widget.controller.clear();
                        _removeOverlay();
                        setState(() => _suggestions = []);
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.success, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ce champ est requis';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
