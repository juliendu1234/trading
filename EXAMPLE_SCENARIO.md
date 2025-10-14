# Scénario d'Exemple - Fonction de Sécurité

## Configuration
```
FixedCapital = 1000.0 €
ZeroRiskPrice = 50.0 €
LotSizeBuy = 0.01
```

## Scénario 1 : Trade Accepté ✅

### Situation actuelle
- **Positions ouvertes** : 2 positions BUY
  - Position 1 : 0.01 lot à 120€
  - Position 2 : 0.01 lot à 110€
- **Nouveau trade prévu** : 0.01 lot à 105€

### Calcul (ContractSize = 100 pour exemple)
```
Position 1 au point 0 : 0.01 × 100 × (120 - 50) = 70 €
Position 2 au point 0 : 0.01 × 100 × (110 - 50) = 60 €
Nouveau trade au point 0 : 0.01 × 100 × (105 - 50) = 55 €

Total : 70 + 60 + 55 = 185 €
```

### Résultat
```
185 € ≤ 1000 € → ✅ Trade autorisé
```

---

## Scénario 2 : Trade Refusé ❌

### Situation actuelle
- **Positions ouvertes** : 5 positions BUY
  - Position 1 : 0.05 lot à 200€
  - Position 2 : 0.05 lot à 180€
  - Position 3 : 0.05 lot à 160€
  - Position 4 : 0.05 lot à 140€
  - Position 5 : 0.05 lot à 120€
- **Nouveau trade prévu** : 0.05 lot à 100€

### Calcul (ContractSize = 100 pour exemple)
```
Position 1 au point 0 : 0.05 × 100 × (200 - 50) = 750 €
Position 2 au point 0 : 0.05 × 100 × (180 - 50) = 650 €
Position 3 au point 0 : 0.05 × 100 × (160 - 50) = 550 €
Position 4 au point 0 : 0.05 × 100 × (140 - 50) = 450 €
Position 5 au point 0 : 0.05 × 100 × (120 - 50) = 350 €
Nouveau trade au point 0 : 0.05 × 100 × (100 - 50) = 250 €

Total : 750 + 650 + 550 + 450 + 350 + 250 = 3000 €
```

### Résultat
```
3000 € > 1000 € → ❌ Trade refusé
```

### Message dans les logs
```
⛔ Capital de risque atteint : Coût total si prix = 50.0 serait 3000.0 € > Capital fixe 1000.0 €
⛔ PlaceBuyOrder : Trade refusé par sécurité du capital
```

---

## Scénario 3 : Sécurité Désactivée

### Configuration
```
FixedCapital = 0.0 €  (désactivé)
```

### Résultat
```
Tous les trades sont autorisés, quelle que soit l'exposition
→ Comportement identique à la version précédente du robot
```

---

## Graphique Visuel

```
Prix de l'actif
│
│  200€  ●───── Position 1 (0.05 lot)
│
│  180€  ●───── Position 2 (0.05 lot)
│
│  160€  ●───── Position 3 (0.05 lot)
│
│  140€  ●───── Position 4 (0.05 lot)
│
│  120€  ●───── Position 5 (0.05 lot)
│
│  100€  ○───── Nouveau trade prévu (0.05 lot) ← REFUSÉ
│
│   50€  ═══════ ZeroRiskPrice (Point 0)
│              Si le prix descend ici :
│              Perte totale = 3000 € > Capital fixe (1000 €)
│
└────────────────────────────────────────────────
```

---

## Interprétation

La fonction de sécurité garantit que :
- ✅ Vous ne perdrez jamais plus que votre `FixedCapital`
- ✅ Si le prix descend au `ZeroRiskPrice`, votre perte maximale = `FixedCapital`
- ✅ Les trades sont automatiquement bloqués quand le risque devient trop élevé
- ✅ Vous gardez le contrôle avec la possibilité de désactiver cette fonction

C'est exactement ce que vous vouliez : une sécurité par rapport à un "point 0" et à un "Capital Fixe" !
