# Cours de SNT & NSI

Site de cours pour le lycée (SNT en Seconde, NSI en Première et Terminale),
construit avec [Quarto](https://quarto.org).

Chaque cours est écrit **une seule fois** en Markdown (`.qmd`) et produit :

- une **page web** accessible aux élèves, avec des blocs **Python
  exécutables dans le navigateur** (rien à installer, grâce à
  [Pyodide](https://pyodide.org) et à l'extension
  [quarto-live](https://github.com/r-wasm/quarto-live)) ;
- un **PDF** généré automatiquement par **LaTeX** (LuaLaTeX), téléchargeable
  depuis la page du cours (rubrique *Autres formats*).

## Organisation

```
.
├── _quarto.yml                  configuration du site et des formats HTML / PDF
├── _quarto-sans-corrections.yml profil qui masque toutes les corrections
├── index.qmd                    page d'accueil
├── accessibilite.qmd            page « Accessibilité »
├── snt/                         cours de SNT (Seconde)
├── nsi/premiere/                cours de NSI Première
├── nsi/terminale/               cours de NSI Terminale
├── modeles/modele-cours.qmd     modèle à copier pour un nouveau cours
├── filters/                     filtres Lua (encadrés, conversion pour le PDF)
├── latex/entete.tex             personnalisation LaTeX (en-têtes, pieds de page…)
├── styles/                      thème du site, police, accessibilité
├── _extensions/live/            extension quarto-live (Python interactif)
└── .github/workflows/           publication automatique sur GitHub Pages
```

## Écrire un nouveau cours

1. Copier `modeles/modele-cours.qmd` dans le bon dossier, par exemple
   `nsi/premiere/02-boucles.qmd`.
2. Modifier l'en-tête (`title`, `subtitle`, `description`, `order`).
3. Rédiger ! Le cours apparaît automatiquement dans le menu et dans la liste
   des chapitres de la classe.

### Encadrés pédagogiques

```markdown
::: {.definition title="Variable"}
Une variable est un nom associé à une valeur.
:::
```

| Classe         | Titre affiché       | Couleur |
|----------------|---------------------|---------|
| `.definition`  | Définition          | bleu    |
| `.propriete`   | Propriété           | rouge   |
| `.retenir`     | À retenir           | rouge   |
| `.methode`     | Méthode             | vert    |
| `.exemple`     | Exemple             | vert    |
| `.attention`   | Attention           | orange  |
| `.histoire`    | Un peu d'histoire   | bleu    |
| `.exercice`    | Exercice *n* (numéroté automatiquement) | orange |
| `.solution`    | Correction (repliée sur le site) | vert |

L'attribut `title="…"` est facultatif et complète le titre.

### Trois sortes de blocs Python

| Bloc | Exécuté… | Site web | PDF |
|------|----------|----------|-----|
| ```` ```{python} ```` | à la génération, sur votre ordinateur | code + résultat | code + résultat |
| ```` ```{pyodide} ```` | dans le navigateur de l'élève | éditeur modifiable + bouton *Run Code* | code seul, avec la mention « Code interactif » |
| ```` ```{pyodide} ```` avec `#\| exercise: nom` | dans le navigateur | exercice à trous `______`, indices, solution | code à compléter + correction |

Options utiles pour les blocs `{python}` :

- `#| echo: false` : n'afficher que le résultat (pas le code) ;
- `#| fig-cap: "…"` et `#| fig-alt: "…"` : légende et **texte alternatif**
  (indispensable pour l'accessibilité) des graphiques.

## Générer le site et les PDF sur son ordinateur

Prérequis (une seule fois) :

```bash
# 1. Installer Quarto : https://quarto.org/docs/get-started/
# 2. Installer LaTeX (TinyTeX, léger) et la police utilisée dans les PDF
quarto install tinytex
tlmgr install atkinson dejavu
# 3. Installer les bibliothèques Python des démonstrations
pip install -r requirements.txt
```

Puis :

```bash
quarto preview                 # aperçu en direct dans le navigateur
quarto render                  # génère tout le site + les PDF dans _site/
quarto render nsi/premiere/01-variables-types.qmd --to pdf   # un seul PDF
quarto render --profile sans-corrections   # version sans corrections
```

Les paquets LaTeX manquants sont installés automatiquement par Quarto lors
du premier rendu.

> **Astuce** : grâce à `freeze: auto`, le code Python d'un cours n'est
> ré-exécuté que lorsqu'il a changé. Les résultats sont mémorisés dans le
> dossier `_freeze/`, qu'il faut versionner avec Git.

## Publication en ligne (GitHub Pages)

Le workflow `.github/workflows/publier.yml` génère le site **et tous les PDF**
puis les publie à chaque `push` sur la branche `main`.

À faire une seule fois sur GitHub : **Settings → Pages → Build and
deployment → Source : GitHub Actions**.

Le site est alors disponible à l'adresse
<https://lucasdebeve.github.io/quarto-cours/>.

## Accessibilité

- police **Atkinson Hyperlegible** (site et PDF), conçue pour les personnes
  malvoyantes, hébergée localement (aucun appel à Google Fonts) ;
- grande taille de texte, interligne confortable, texte non justifié ;
- thème de coloration du code à fort contraste (`a11y`), mode sombre ;
- navigation au clavier avec focus visible, liens soulignés ;
- textes alternatifs pour les images (`fig-alt`) ;
- langue du document déclarée (`lang: fr`) pour les lecteurs d'écran.

## Remarques

- Au premier chargement d'une page contenant du Python interactif, le
  navigateur télécharge Pyodide (quelques Mo, depuis `cdn.jsdelivr.net`) ;
  il est ensuite mis en cache. Si le réseau du lycée bloque ce site, les
  blocs `{python}` classiques restent lisibles.
- Les boutons de l'éditeur interactif (*Run Code*, *Start Over*, *Hint*,
  *Show Solution*) sont fournis en anglais par l'extension quarto-live.
- Licences : extension quarto-live (MIT), police Atkinson Hyperlegible
  (SIL Open Font License, voir `styles/polices/OFL.txt`).
