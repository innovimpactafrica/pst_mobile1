# Guide de remplacement des couleurs en dur

## Couleurs à remplacer dans tout le projet

### Remplacements à effectuer:

1. `Colors.white` → `AppColors.white`
2. `Colors.black.withValues(alpha: 0.05)` → `AppColors.blackOpacity05`
3. `Colors.black.withValues(alpha: 0.1)` → `AppColors.blackOpacity10`
4. `Colors.transparent` → `Colors.transparent` (garder tel quel)
5. `Colors.grey.shade50` → `AppColors.backgroundLight`
6. `Colors.grey.shade100` → `AppColors.backgroundLight`
7. `Colors.grey.shade200` → `AppColors.grey200`
8. `Colors.grey.shade300` → `AppColors.grey300`
9. `Colors.grey.shade400` → `AppColors.grey400`
10. `Colors.grey.shade500` → `AppColors.textSecondary`
11. `Colors.grey.shade600` → `AppColors.grey600`
12. `Colors.grey.shade700` → `AppColors.grey700`
13. `Colors.black87` → `AppColors.textPrimary`
14. `Colors.red` → `AppColors.error`
15. `Colors.green` → `AppColors.success`
16. `Colors.orange` → `AppColors.warning`
17. `Colors.blue` → `AppColors.info`
18. `Colors.amber` → `AppColors.rating`
19. `Color(0xFF5B4FC7)` → `AppColors.secondary`
20. `Color(0xFF2C1E85)` → `AppColors.primary`
21. `Colors.purple` → `AppColors.secondary`

## Couleurs manquantes à ajouter dans AppColors:

```dart
// À ajouter dans app_colors.dart si nécessaire
static const Color orange = Color(0xFFFF9800);
static const Color blue = Color(0xFF2196F3);
static const Color purple = Color(0xFF9C27B0);
```

## Commande de remplacement automatique (PowerShell):

```powershell
# Exemple pour remplacer Colors.white
Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse | ForEach-Object {
    (Get-Content $_.FullName) -replace 'Colors\.white', 'AppColors.white' | Set-Content $_.FullName
}
```

## Fichiers prioritaires à corriger manuellement:

1. parents/pages/enfants/ (tous les fichiers)
2. parents/pages/groupes/ (tous les fichiers)
3. parents/pages/trajets/ (tous les fichiers)
4. parents/pages/profil/ (tous les fichiers)
5. parents/pages/authentification/ (tous les fichiers)
6. chauffeurs/ (tous les fichiers)

## Note importante:

- Vérifier que `import 'package:private_school/core/utils/app_colors.dart';` est présent dans chaque fichier
- Tester l'application après chaque lot de modifications
- Certaines couleurs comme `Colors.transparent` peuvent rester telles quelles
