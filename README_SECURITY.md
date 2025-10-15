# 🛡️ Fonction de Sécurité du Capital - Guide Rapide

## 📋 Qu'est-ce que c'est ?

Une nouvelle fonction de sécurité qui protège votre capital en empêchant l'ouverture de trades qui dépasseraient votre limite de risque.

## 🚀 Utilisation Rapide

### Activation

Dans les paramètres du robot, configurez :

```
MaxAccountBalance = 1000.0    // Votre capital fixe en € (paramètre existant)
ZeroRiskPrice = 50.0          // Le prix "point 0" en € (active la sécurité)
```

### Désactivation

```
ZeroRiskPrice = 0.0           // Désactive la sécurité
```

## 📚 Documentation Complète

| Document | Description |
|----------|-------------|
| **SECURITY_FUNCTION.md** | Guide utilisateur complet avec explications détaillées |
| **IMPLEMENTATION_SUMMARY.md** | Détails techniques de l'implémentation |
| **EXAMPLE_SCENARIO.md** | Exemples concrets avec calculs |

## 💡 Exemple Simple

**Vous avez** :
- Capital fixe : 1000€ (MaxAccountBalance)
- Prix point 0 : 100€ (ZeroRiskPrice)
- 3 positions ouvertes qui coûteraient 800€ si le prix descendait à 100€

**Nouveau trade** : coûterait 300€ à 100€

**Résultat** : 800€ + 300€ = 1100€ > 1000€ → ❌ **Trade refusé**

## ⚙️ Comment ça marche ?

1. Avant chaque achat, le robot calcule le coût total si le prix descendait au "point 0"
2. Si ce coût dépasse votre capital fixe (MaxAccountBalance) → Trade refusé
3. Sinon → Trade autorisé

## 🎯 Avantages

- ✅ Protection automatique du capital
- ✅ Contrôle précis du risque
- ✅ Compatible avec les stratégies de grille
- ✅ Désactivable à tout moment
- ✅ Messages d'alerte clairs
- ✅ Utilise le paramètre MaxAccountBalance existant (pas de duplication)

## 📞 Support

Pour plus de détails, consultez les documents de documentation mentionnés ci-dessus.

---

*Implémenté le 14 octobre 2025 - Version 4.0*
