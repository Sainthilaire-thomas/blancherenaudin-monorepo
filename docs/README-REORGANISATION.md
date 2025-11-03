# 📚 Documentation Blanche Renaudin - Réorganisée

**Date de réorganisation :** 03/11/2025 13:51

## 📁 Structure

### 01-ARCHITECTURE/
Architecture du monorepo et plans d'évolution

### 02-MIGRATION/
Historique de migration et roadmaps

### 03-PACKAGES/
Documentation des packages individuels

### 04-TROUBLESHOOTING/
Résolution de problèmes et debugging

### 05-SESSIONS/
Notes de sessions de travail

---

## 📌 Convention de nommage

Format : \YYYYMMDD-NOM-FICHIER.md\

- **YYYYMMDD** = Date de dernière modification
- Permet d'identifier rapidement les docs obsolètes

## 🔍 Trouver un document

\\\powershell
# Recherche par mot-clé
Get-ChildItem -Recurse -Filter "*.md" | Select-String "mot-clé"

# Docs récentes (< 30 jours)
Get-ChildItem -Recurse -Filter "*.md" | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-30) }
\\\

---

**Fichiers originaux conservés dans docs/ et docs/CIBLE/**
