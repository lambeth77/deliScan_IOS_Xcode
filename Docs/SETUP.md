# Configuration Xcode et test sur iPhone

## Prérequis

- Un Mac avec la version de Xcode qui contient le SDK iOS 26.
- Un compte Apple Developer : les App Groups et une Broadcast Upload Extension doivent être signés sur un appareil réel.
- Un iPhone sous iOS 26. Le simulateur ne fournit pas un flux d’écran utilisable pour ce test.

## Ouvrir et signer le projet

1. Copiez le dossier `CourseScanner` sur le Mac, puis ouvrez `CourseScanner.xcodeproj` dans Xcode.
2. Dans la cible **CourseScanner**, ouvrez **Signing & Capabilities**, choisissez votre équipe, puis remplacez l’identifiant de bundle par un identifiant qui vous appartient, par exemple `fr.votresociete.CourseScanner`.
3. Faites de même pour **CourseScannerBroadcastUpload** et utilisez le même préfixe, par exemple `fr.votresociete.CourseScanner.BroadcastUpload`.
4. Dans **Build Settings** de chacune des deux cibles, modifiez les trois valeurs suivantes de manière cohérente :

   | Réglage | App | Extension |
   | --- | --- | --- |
   | `PRODUCT_BUNDLE_IDENTIFIER` | `fr.votresociete.CourseScanner` | `fr.votresociete.CourseScanner.BroadcastUpload` |
   | `BROADCAST_UPLOAD_EXTENSION_IDENTIFIER` | l’identifiant exact de l’extension | inutile dans l’extension |
   | `APP_GROUP_IDENTIFIER` | `group.fr.votresociete.CourseScanner` | exactement la même valeur |

5. Dans **Signing & Capabilities** de chaque cible, ajoutez **App Groups**, activez `group.fr.votresociete.CourseScanner`, puis vérifiez que Xcode a bien sélectionné le même groupe pour les deux cibles. Les deux fichiers `.entitlements` du projet utilisent déjà `$(APP_GROUP_IDENTIFIER)`.
6. Gardez le déploiement à **iOS 26.0**. Si la version Xcode disponible ne contient pas encore ce SDK, utilisez la valeur la plus élevée disponible pour compiler et testez avec un iPhone dont la version est prise en charge par ce Xcode.

Il n’y a pas d’entitlement APS à activer : le prototype emploie uniquement des notifications **locales**, jamais des notifications push.

## Ce qui est déjà réglé

L’extension `CourseScannerBroadcastUpload` est déclarée comme une Broadcast Upload Extension dans `BroadcastUpload-Info.plist` :

- `NSExtensionPointIdentifier = com.apple.broadcast-services-upload`
- `RPBroadcastProcessMode = RPBroadcastProcessModeSampleBuffer`
- `NSExtensionPrincipalClass = $(PRODUCT_MODULE_NAME).SampleHandler`

L’application principale expose `RPSystemBroadcastPickerView`. Apple impose que l’utilisateur touche ce contrôle système et confirme le démarrage ; l’app ne peut pas déclencher la diffusion silencieusement. Aucun usage de caméra, GPS ou microphone n’est demandé.

## Test du MVP

1. Branchez l’iPhone, choisissez-le comme destination et lancez la cible **CourseScanner**.
2. Touchez **Démarrer ma session** et acceptez les notifications. L’autorisation est demandée dans l’app, avant son passage en arrière-plan.
3. Touchez le bouton de diffusion de CourseScanner, puis validez **Démarrer la diffusion** dans l’interface système.
4. Quittez CourseScanner et ouvrez une application de test contenant le texte `8,73 €`. Pour rendre le test reproductible, vous pouvez afficher ce texte en gros dans Notes ou Safari.
5. L’extension analyse au plus une image par seconde. Dès que le même montant est visible sur deux analyses successives, elle écrit le montant dans l’App Group et programme l’alerte locale **« Proposition détectée » — « 8,73 € »**.
6. Revenez dans CourseScanner et touchez **Actualiser** : le dernier montant détecté doit s’afficher, même si la notification a été refusée.

## Limites connues de cette voie

ReplayKit et `RPBroadcastSampleHandler` sont marqués *deprecated* par Apple. C’est donc un prototype iOS 26, à isoler derrière cette extension afin de pouvoir remplacer la capture lorsqu’Apple proposera une API pérenne.

`processSampleBuffer` est appelé en série par ReplayKit. Le code fait l’OCR Vision synchroniquement et ne commence une analyse qu’après une seconde. Il ne met aucune frame sur disque, dans Photos, ni dans l’App Group ; seules la dernière valeur numérique, sa date et un court état de session sont partagés.

Une extension peut programmer des notifications locales via `UNUserNotificationCenter`, mais l’autorisation doit être demandée dans un contexte visible à l’utilisateur. Le prototype la demande dans l’app avant le démarrage. Les politiques de notifications et les restrictions de diffusion peuvent varier selon la version iOS et les réglages du téléphone : le test sur l’iPhone cible reste nécessaire. Si une alerte est bloquée, le montant persiste dans l’App Group et sera visible au retour dans l’app ; une app suspendue ne peut pas être réveillée de façon fiable seulement par une modification d’App Group.

## Évolutions prévues, volontairement absentes du MVP

Les emplacements d’extension sont séparés de la détection actuelle : un futur `ProposalEnricher` pourra consommer `DetectedProposal` et ajouter restaurant, destination, GPS, itinéraire, coûts et calcul de rentabilité. Le flux OCR ne doit pas devenir responsable de ces traitements.
