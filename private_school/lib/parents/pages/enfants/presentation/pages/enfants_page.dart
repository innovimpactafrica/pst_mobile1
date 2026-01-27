import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../utils/modal_helper.dart';
import '../../domain/bloc/child_bloc.dart';
import '../../domain/bloc/child_event.dart';
import '../../domain/bloc/child_state.dart';
import '../../data/models/child_model.dart';
import '../widgets/child_card_widget.dart';
import '../widgets/add_child_modal.dart';

class EnfantsPage extends StatefulWidget {
  const EnfantsPage({super.key});

  @override
  State<EnfantsPage> createState() => _EnfantsPageState();
}

class _EnfantsPageState extends State<EnfantsPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ChildBloc>().add(const LoadChildrenEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<ChildBloc>().add(SearchChildrenEvent(query));
  }

  void _showAddChildModal() {
    ModalHelper.showSlideModal(context: context, child: const AddChildModal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.success,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: BlocConsumer<ChildBloc, ChildState>(
                        listener: (context, state) {
                          if (state is ChildActionSuccessState) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                backgroundColor: AppColors.success,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } else if (state is ChildErrorState) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.error),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        builder: (context, state) {
                          if (state is ChildLoadingState) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppColors.success,
                              ),
                            );
                          }

                          if (state is ChildErrorState &&
                              state.children.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Erreur de chargement',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () {
                                      context.read<ChildBloc>().add(
                                        const LoadChildrenEvent(),
                                      );
                                    },
                                    child: Text(
                                      'Réessayer',
                                      style: GoogleFonts.inter(
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (state is ChildLoadedState) {
                            if (state.filteredChildren.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      state.searchQuery.isEmpty
                                          ? 'Aucun enfant'
                                          : 'Aucun résultat',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return _buildChildrenList(state.filteredChildren);
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddChildModal,
        backgroundColor: AppColors.success,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Text(
        'Enfants',
        style: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Rechercher',
            hintStyle: GoogleFonts.inter(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey.shade500,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildChildrenList(List<ChildModel> children) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 80),
      itemCount: children.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ChildCardWidget(child: children[index]),
        );
      },
    );
  }
}
