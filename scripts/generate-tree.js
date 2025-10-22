// scripts/generate-tree.js
const fs = require('fs');
const path = require('path');

const IGNORE_PATTERNS = [
  'node_modules',
  '.next',
  '.turbo',
  'dist',
  'build',
  '.git',
  '.DS_Store',
  '*.log',
  '.env',
  '.env.local',
  'coverage',
  '.cache',
  'pnpm-lock.yaml',
  'package-lock.json',
  'yarn.lock',
];

function shouldIgnore(name, fullPath) {
  // Ignorer les fichiers/dossiers cachés
  if (name.startsWith('.') && name !== '.gitignore' && name !== '.env.example') {
    return true;
  }
  
  // Vérifier les patterns d'ignore
  return IGNORE_PATTERNS.some(pattern => {
    if (pattern.includes('*')) {
      const regex = new RegExp(pattern.replace('*', '.*'));
      return regex.test(name);
    }
    return name === pattern;
  });
}

function getStats(filePath) {
  try {
    const stats = fs.statSync(filePath);
    return stats;
  } catch {
    return null;
  }
}

function generateTree(dir, prefix = '', isLast = true, depth = 0, maxDepth = 10) {
  if (depth > maxDepth) return '';
  
  const stats = getStats(dir);
  if (!stats) return '';
  
  const name = path.basename(dir);
  
  // Ignorer certains dossiers
  if (shouldIgnore(name, dir)) {
    return '';
  }
  
  let output = '';
  const connector = isLast ? '└── ' : '├── ';
  const extension = prefix + connector;
  
  // Ajouter le nom du fichier/dossier
  if (stats.isDirectory()) {
    output += `${extension}📁 ${name}/\n`;
  } else {
    const ext = path.extname(name);
    const icon = getFileIcon(ext);
    output += `${extension}${icon} ${name}\n`;
  }
  
  // Si c'est un dossier, lister son contenu
  if (stats.isDirectory()) {
    try {
      const items = fs.readdirSync(dir)
        .filter(item => !shouldIgnore(item, path.join(dir, item)))
        .sort((a, b) => {
          const aIsDir = fs.statSync(path.join(dir, a)).isDirectory();
          const bIsDir = fs.statSync(path.join(dir, b)).isDirectory();
          if (aIsDir && !bIsDir) return -1;
          if (!aIsDir && bIsDir) return 1;
          return a.localeCompare(b);
        });
      
      items.forEach((item, index) => {
        const itemPath = path.join(dir, item);
        const isLastItem = index === items.length - 1;
        const newPrefix = prefix + (isLast ? '    ' : '│   ');
        output += generateTree(itemPath, newPrefix, isLastItem, depth + 1, maxDepth);
      });
    } catch (err) {
      // Ignorer les erreurs de lecture
    }
  }
  
  return output;
}

function getFileIcon(ext) {
  const icons = {
    '.ts': '🔷',
    '.tsx': '⚛️',
    '.js': '📜',
    '.jsx': '⚛️',
    '.json': '📋',
    '.md': '📝',
    '.css': '🎨',
    '.scss': '🎨',
    '.html': '🌐',
    '.yml': '⚙️',
    '.yaml': '⚙️',
    '.env': '🔐',
    '.svg': '🖼️',
    '.png': '🖼️',
    '.jpg': '🖼️',
    '.jpeg': '🖼️',
    '.gif': '🖼️',
    '.ico': '🖼️',
  };
  return icons[ext] || '📄';
}

function countItems(dir, stats = { files: 0, dirs: 0 }) {
  try {
    const items = fs.readdirSync(dir);
    items.forEach(item => {
      if (shouldIgnore(item, path.join(dir, item))) return;
      
      const itemPath = path.join(dir, item);
      const itemStats = getStats(itemPath);
      
      if (!itemStats) return;
      
      if (itemStats.isDirectory()) {
        stats.dirs++;
        countItems(itemPath, stats);
      } else {
        stats.files++;
      }
    });
  } catch {
    // Ignorer les erreurs
  }
  return stats;
}

// Main
const rootDir = process.cwd();
const outputFile = path.join(rootDir, 'docs', 'arborescence-projet.txt');

console.log('🌳 Génération de l\'arborescence du projet...\n');

// Créer le dossier docs s'il n'existe pas
const docsDir = path.join(rootDir, 'docs');
if (!fs.existsSync(docsDir)) {
  fs.mkdirSync(docsDir, { recursive: true });
}

// Générer l'arborescence
const tree = generateTree(rootDir, '', true, 0, 10);
const stats = countItems(rootDir);

// Créer le contenu du fichier
const now = new Date();
const timestamp = now.toLocaleString('fr-FR', { 
  dateStyle: 'short', 
  timeStyle: 'medium' 
});

const content = `
╔══════════════════════════════════════════════════════════════════════════════╗
║                    ARBORESCENCE DU PROJET - MONOREPO                        ║
║                                                                              ║
║  Généré le: ${timestamp.padEnd(58)}║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

🌳 Structure du projet :

📁 ${path.basename(rootDir)}/
${tree}

📈 Statistiques :
   • Dossiers : ${stats.dirs}
   • Fichiers : ${stats.files}
   • Total : ${stats.dirs + stats.files} éléments

💡 Fichiers ignorés : node_modules, .next, .turbo, dist, build, .git, etc.
`.trim();

// Écrire le fichier
fs.writeFileSync(outputFile, content, 'utf8');

console.log('✅ Arborescence générée avec succès !');
console.log(`📁 Fichier créé : ${outputFile}`);
console.log(`\n📊 Statistiques :`);
console.log(`   • ${stats.dirs} dossiers`);
console.log(`   • ${stats.files} fichiers`);
console.log(`   • ${stats.dirs + stats.files} éléments au total`);
