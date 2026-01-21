import '../models/child_model.dart';
import '../services/child_service.dart';

class ChildRepository {
  final ChildService _childService = ChildService();

  Future<List<ChildModel>> getChildren() async {
    try {
      return await _childService.fetchChildren();
    } catch (e) {
      throw Exception('Failed to load children: $e');
    }
  }

  Future<ChildModel> addChild(ChildModel child) async {
    try {
      return await _childService.createChild(child);
    } catch (e) {
      throw Exception('Failed to add child: $e');
    }
  }

  Future<ChildModel> modifyChild(ChildModel child) async {
    try {
      return await _childService.updateChild(child);
    } catch (e) {
      throw Exception('Failed to update child: $e');
    }
  }

  Future<void> removeChild(String childId) async {
    try {
      await _childService.deleteChild(childId);
    } catch (e) {
      throw Exception('Failed to delete child: $e');
    }
  }
}