class ImageUrlHelper {
  static const String baseUrl = 'https://api.pst.innovimpactdev.cloud';

  static String getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$baseUrl/api/uploads$cleanPath';
  }

  /// Vérifie si une URL d'image est valide
  static bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http://') ||
        url.startsWith('https://') ||
        url.startsWith('/uploads/');
  }
}
