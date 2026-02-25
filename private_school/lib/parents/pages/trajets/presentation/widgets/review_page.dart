import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data/models/trip_model.dart';
import '../../data/models/evaluation_model.dart';
import '../../data/repositories/evaluation_repository.dart';
import '../../../../../core/utils/app_colors.dart';

class ReviewPage extends StatefulWidget {
  final TripModel trip;
  final EvaluationModel? existingEvaluation;

  const ReviewPage({super.key, required this.trip, this.existingEvaluation});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int _rating = 0;
  String? _selectedBadge;
  final _commentController = TextEditingController();
  final _repository = EvaluationRepository();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    if (widget.existingEvaluation != null) {
      _rating = widget.existingEvaluation!.rating;
      _commentController.text = widget.existingEvaluation!.comment ?? '';
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.grey.shade700,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: AppColors.success,
                        size: 60,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      widget.existingEvaluation != null
                          ? 'edit_your_review'.tr()
                          : 'trip_completed'.tr(),
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'thank_you_message'.tr(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    Text(
                      'rate_your_experience'.tr(),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              index < _rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 40,
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 32),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'what_did_you_appreciate'.tr(),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // BADGES
                    Row(
                      children: [
                        Expanded(
                          child: _buildBadge(
                            icon: Icons.schedule,
                            label: 'punctual'.tr(),
                            id: 'ponctuel',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildBadge(
                            icon: Icons.work_outline,
                            label: 'professional'.tr(),
                            id: 'professionnel',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildBadge(
                            icon: Icons.mood,
                            label: 'friendly'.tr(),
                            id: 'sympathique',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    TextField(
                      controller: _commentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'leave_comment'.tr(),
                        hintStyle: GoogleFonts.inter(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
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
                          borderSide: BorderSide(color: AppColors.success),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: GoogleFonts.inter(fontSize: 14),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    widget.existingEvaluation != null
                        ? 'update_rating'.tr()
                        : 'send_rating'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required String id,
  }) {
    final isSelected = _selectedBadge == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBadge = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.success.withValues(alpha: 0.1)
              : Colors.grey.shade100,
          border: Border.all(
            color: isSelected ? AppColors.success : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.success : Colors.grey.shade600,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.success : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('please_give_rating'.tr(), style: GoogleFonts.inter()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final isEditing = widget.existingEvaluation != null;

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(
        isEditing
            ? ' [ReviewPage] MODIFICATION ÉVALUATION'
            : '🟢 [ReviewPage] ENVOI ÉVALUATION',
      );
      debugPrint(' Trip ID: ${widget.trip.id}');
      debugPrint(' Rating: $_rating');
      debugPrint(' Comment: ${_commentController.text}');
      if (isEditing) {
        debugPrint(' Evaluation ID: ${widget.existingEvaluation!.id}');
      }
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (isEditing) {
        //  MODIFICATION
        await _repository.updateEvaluation(
          id: widget.existingEvaluation!.id!,
          rating: _rating,
          comment: _commentController.text.trim().isNotEmpty
              ? _commentController.text.trim()
              : null,
        );
        debugPrint(' Évaluation modifiée');
      } else {
        // CRÉATION
        await _repository.createEvaluation(
          tripId: int.parse(widget.trip.id),
          driverId: int.parse(widget.trip.driverId!),
          rating: _rating,
          comment: _commentController.text.trim().isNotEmpty
              ? _commentController.text.trim()
              : null,
        );
        debugPrint(' Évaluation créée');
      }

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'review_updated_success'.tr()
                : 'review_sent_success'.tr(),
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint(' Erreur: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${'error_sending_review'.tr()}: $e',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
