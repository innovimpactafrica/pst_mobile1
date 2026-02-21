import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../domain/bloc/group_bloc.dart';
import '../../domain/bloc/group_event.dart';
import '../../domain/bloc/group_state.dart';
import 'package:private_school/core/utils/app_colors.dart';

class InviteMemberModal extends StatefulWidget {
  final String groupId;

  const InviteMemberModal({super.key, required this.groupId});

  @override
  State<InviteMemberModal> createState() => _InviteMemberModalState();
}

class _InviteMemberModalState extends State<InviteMemberModal> {
  bool _isEmail = true;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendInvite(BuildContext context) {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('fill_field'.tr(), style: GoogleFonts.inter()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📨 [InviteMemberModal] SEND INVITE');
    debugPrint('   GroupId: ${widget.groupId}');
    debugPrint('   ${_isEmail ? "Email" : "Phone"}: ${_controller.text.trim()}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // ✅ Utilise le BLoC parent (fourni par GroupDetailPage)
    context.read<GroupBloc>().add(
      InviteMemberEvent(
        groupId: widget.groupId,
        email: _isEmail ? _controller.text.trim() : null,
        phone: !_isEmail ? _controller.text.trim() : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ SUPPRIMÉ : BlocProvider (utilise celui du parent)
    return BlocConsumer<GroupBloc, GroupState>(
      listener: (context, state) {
        if (state is MemberInvited) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('invitation_sent'.tr(), style: GoogleFonts.inter()),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is GroupError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: GoogleFonts.inter()),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is GroupLoading;

        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'invite_member'.tr(),
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildTabButton('email'.tr(), true)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTabButton('phone'.tr(), false)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isEmail ? 'email_address'.tr() : 'phone_number_label'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _controller,
                    keyboardType: _isEmail
                        ? TextInputType.emailAddress
                        : TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: _isEmail
                          ? 'email_example_invite'.tr()
                          : 'phone_example_invite'.tr(),
                      prefixIcon: Icon(
                        _isEmail ? Icons.email : Icons.phone,
                        color: AppColors.success,
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
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _sendInvite(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'send'.tr(),
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabButton(String label, bool isEmailTab) {
    final isSelected = _isEmail == isEmailTab;
    return GestureDetector(
      onTap: () {
        setState(() {
          _isEmail = isEmailTab;
          _controller.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.success : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}