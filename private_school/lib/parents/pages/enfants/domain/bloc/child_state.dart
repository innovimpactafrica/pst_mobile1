import 'package:equatable/equatable.dart';
import '../../data/models/child_model.dart';

/// Base class for all child states
abstract class ChildState extends Equatable {
  const ChildState();

  @override
  List<Object?> get props => [];
}

/// Initial state when bloc is created
class ChildInitialState extends ChildState {
  const ChildInitialState();
}

/// State when children are being loaded
class ChildLoadingState extends ChildState {
  const ChildLoadingState();
}

/// State when children are successfully loaded
class ChildLoadedState extends ChildState {
  final List<ChildModel> children;
  final List<ChildModel> filteredChildren;
  final String searchQuery;

  const ChildLoadedState({
    required this.children,
    required this.filteredChildren,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [children, filteredChildren, searchQuery];

  ChildLoadedState copyWith({
    List<ChildModel>? children,
    List<ChildModel>? filteredChildren,
    String? searchQuery,
  }) {
    return ChildLoadedState(
      children: children ?? this.children,
      filteredChildren: filteredChildren ?? this.filteredChildren,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// State when a child is being added/updated/deleted
class ChildActionInProgressState extends ChildState {
  final List<ChildModel> currentChildren;

  const ChildActionInProgressState(this.currentChildren);

  @override
  List<Object?> get props => [currentChildren];
}

/// State when a child action succeeds
class ChildActionSuccessState extends ChildState {
  final String message;
  final List<ChildModel> children;

  const ChildActionSuccessState({
    required this.message,
    required this.children,
  });

  @override
  List<Object?> get props => [message, children];
}

/// State when an error occurs
class ChildErrorState extends ChildState {
  final String error;
  final List<ChildModel> children;

  const ChildErrorState({required this.error, this.children = const []});

  @override
  List<Object?> get props => [error, children];
}
