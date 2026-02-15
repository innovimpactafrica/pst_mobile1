# Configuration de la fonctionnalité "Inviter des amis"

## ✅ Modifications effectuées

### 1. Packages ajoutés
- `flutter_contacts: ^1.1.7+1` - Pour accéder aux contacts du téléphone
- `share_plus: ^7.2.2` - Pour le partage natif sur toutes les plateformes

### 2. Permissions Android (AndroidManifest.xml)
- `READ_CONTACTS` - Lire les contacts
- `WRITE_CONTACTS` - Écrire les contacts
- Queries pour WhatsApp, Instagram, Messenger, Twitter/X, SMS

### 3. Permissions iOS (Info.plist)
- `NSContactsUsageDescription` - Accès aux contacts
- `LSApplicationQueriesSchemes` - Schémas d'URL pour les apps sociales

### 4. Fonctionnalités implémentées

#### 📋 Copier le lien
- Copie le lien d'invitation dans le presse-papiers
- Affiche une notification de confirmation

#### 💬 WhatsApp
- Ouvre WhatsApp avec le message pré-rempli
- Fallback vers share_plus si WhatsApp n'est pas installé
- Pour les contacts: envoie directement au numéro sélectionné

#### 📸 Instagram
- Utilise share_plus pour partager le message
- Ouvre Instagram si disponible avec instruction de copier le lien

#### 💬 Messenger
- Ouvre Messenger avec le lien
- Fallback vers share_plus si non disponible

#### 🐦 Twitter/X
- Essaie d'ouvrir l'app X (nouveau nom)
- Fallback vers Twitter
- Fallback vers le web si aucune app installée

#### 👥 Inviter des contacts
- Charge les contacts du téléphone
- Barre de recherche pour filtrer
- Options d'invitation:
  - SMS
  - WhatsApp (avec numéro)
  - Autres options (share_plus)

## 🚀 Installation

1. Installer les dépendances:
```bash
cd c:\privateschooltransport_mobile\private_school
flutter pub get
```

2. Pour Android, nettoyer et rebuilder:
```bash
flutter clean
flutter pub get
flutter run
```

3. Pour iOS (si vous développez sur Mac):
```bash
cd ios
pod install
cd ..
flutter run
```

## 📝 Configuration du lien d'invitation

Dans `invite_friends_page.dart`, modifiez ces variables:

```dart
final String _inviteLink = 'https://privateschool.app/invite?ref=USER123';
final String _inviteMessage = '🚌 Rejoignez-moi sur Private School Transport ! ...';
```

Remplacez par:
- Votre vrai lien d'invitation (avec deep linking si configuré)
- Le code de référence de l'utilisateur connecté

## 🔧 Personnalisation

### Changer le message d'invitation
Modifiez `_inviteMessage` dans la classe `_InviteFriendsPageState`

### Ajouter d'autres réseaux sociaux
Ajoutez un nouveau bouton dans `_buildSocialButtons()` et créez la méthode correspondante

### Modifier les couleurs
Les couleurs sont définies dans `AppColors`:
- `AppColors.success` - Vert principal
- `AppColors.whatsapp` - Vert WhatsApp
- `AppColors.instagram` - Dégradé Instagram
- `AppColors.messenger` - Bleu Messenger
- `AppColors.twitter` - Bleu Twitter

## ⚠️ Notes importantes

1. **Permissions**: L'utilisateur doit accepter l'accès aux contacts au premier lancement
2. **Apps non installées**: Un fallback vers share_plus est prévu
3. **Deep linking**: Pour un lien d'invitation fonctionnel, configurez le deep linking dans votre app
4. **Messenger**: Nécessite un Facebook App ID (remplacez `YOUR_APP_ID` dans le code)

## 🧪 Test

1. Testez sur un appareil réel (pas l'émulateur) pour les contacts
2. Vérifiez que les apps sociales sont installées
3. Testez chaque bouton de partage
4. Testez l'invitation d'un contact via SMS et WhatsApp
