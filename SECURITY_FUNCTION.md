# Fonction de Sécurité du Capital

## Description

La fonction de sécurité `CanAffordNextTrade()` a été ajoutée pour protéger votre capital de trading contre les pertes excessives.

## Principe de Fonctionnement

### Paramètres

- **FixedCapital** (Capital Fixe) : Le montant maximum que vous êtes prêt à risquer (par exemple 1000€)
  - Valeur par défaut : `0.0` (désactivé)
  - Si `FixedCapital > 0`, la sécurité est activée

- **ZeroRiskPrice** (Prix Point 0) : Le prix auquel votre compte serait à zéro
  - Valeur par défaut : `0.0` (utilise 0.01 automatiquement)
  - Si le prix atteint ce niveau, vous ne perdriez pas plus que votre capital fixe

### Comment ça marche ?

1. **Avant chaque achat**, la fonction calcule :
   - Le coût de toutes les positions ouvertes si le prix descendait au "prix point 0"
   - Le coût du nouvel achat prévu au "prix point 0"
   - La somme totale de ces coûts

2. **Vérification** :
   - Si `coût total ≤ FixedCapital` → ✅ Trade autorisé
   - Si `coût total > FixedCapital` → ❌ Trade refusé

3. **Protection** :
   - Empêche l'ouverture de positions qui dépasseraient votre capital fixe
   - Affiche un message d'alerte dans les logs

## Exemple d'utilisation

### Scénario
- Vous avez 1000€ sur votre compte de trading
- Vous voulez garder toujours 1000€ et récupérer les gains quotidiennement
- Vous définissez le prix point 0 à 100€ (par exemple)

### Configuration
```
FixedCapital = 1000.0
ZeroRiskPrice = 100.0
```

### Fonctionnement
- Si vous avez déjà 3 positions ouvertes qui coûteraient 800€ si le prix descendait à 100€
- Et que vous voulez ouvrir une 4ème position qui coûterait 300€ à 100€
- Total : 800€ + 300€ = 1100€ > 1000€
- → **Trade refusé** ❌

## Formule de calcul

Pour chaque position :
```
Coût = Volume × ContractSize × (PrixOuverture - PrixPoint0)
```

Coût total :
```
CoûtTotal = Somme(Coût de toutes les positions) + Coût du nouveau trade
```

## Messages d'alerte

Si un trade est refusé, vous verrez dans les logs :
```
⛔ Capital de risque atteint : Coût total si prix = [prix] serait [montant] € > Capital fixe [montant] €
⛔ PlaceBuyOrder : Trade refusé par sécurité du capital
```
ou
```
⛔ PlaceSellOrder : Trade refusé par sécurité du capital
```

## Désactivation

Pour désactiver la sécurité, définissez simplement :
```
FixedCapital = 0.0
```

## Notes importantes

- Cette fonction protège uniquement contre le risque de baisse de prix jusqu'au "prix point 0"
- Elle ne remplace pas un stop-loss traditionnel
- Elle est particulièrement utile pour les stratégies de grille (grid trading)
- Le calcul est effectué en temps réel avant chaque ordre
