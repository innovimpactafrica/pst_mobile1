class ImageUrlHelper {
  static const String baseUrl = 'http://86.106.181.31:3000';

  static String getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }

    //  CAS GOOGLE DRIVE
    if (path.contains('drive.google.com')) {
      try {
        final uri = Uri.parse(path);
        final segments = uri.pathSegments;

        // récupérer l'id du fichier (après /d/)
        final index = segments.indexOf('d');
        if (index != -1 && index + 1 < segments.length) {
          final fileId = segments[index + 1];
          return 'https://drive.google.com/uc?export=view&id=$fileId';
        }
      } catch (e) {
        return '';
      }
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$baseUrl/$cleanPath';
  }

  /// Vérifie si une URL d'image est valide
  static bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http://') ||
        url.startsWith('https://') ||
        url.startsWith('/uploads/');
  }
}
