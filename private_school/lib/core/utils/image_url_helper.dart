/// Helper class for managing image URLs
/// Converts relative paths to full URLs
class ImageUrlHelper {
  // 🔧 Remplacez par l'URL de votre backend
  static const String baseUrl = 'http://86.106.181.31:3000';

  /// Convertit un chemin relatif en URL complète
  /// 
  /// Exemples:
  /// - "/uploads/drivers/photo.jpg" -> "http://86.106.181.31:3000/uploads/drivers/photo.jpg"
  /// - "http://example.com/photo.jpg" -> "http://example.com/photo.jpg" (inchangé)
  /// - null ou "" -> "" (chaîne vide)
  static String getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return ''; // Retourner une chaîne vide pour les images par défaut
    }

    // Si le path commence déjà par http, le retourner tel quel
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    // Supprimer le slash initial si présent
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