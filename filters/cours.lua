--[[
  cours.lua — Encadrés pédagogiques pour les cours de SNT / NSI.

  Transforme des blocs simples en encadrés (« callouts ») Quarto, rendus
  à la fois en HTML et en PDF (LaTeX / tcolorbox) :

      ::: {.definition title="Variable"}
      Une variable est un nom associé à une valeur.
      :::

  Encadrés disponibles : definition, propriete, retenir, methode, exemple,
  attention, histoire, exercice, solution (ou correction).

  - Les exercices sont numérotés automatiquement (Exercice 1, 2, …).
  - Les solutions sont repliées en HTML et peuvent être masquées partout
    avec `solutions: false` (dans _quarto.yml ou l'en-tête du cours).
]]

local encadres = {
  definition = { type = "note",      titre = "Définition" },
  propriete  = { type = "important", titre = "Propriété" },
  retenir    = { type = "important", titre = "À retenir" },
  methode    = { type = "tip",       titre = "Méthode" },
  exemple    = { type = "tip",       titre = "Exemple" },
  attention  = { type = "warning",   titre = "Attention" },
  histoire   = { type = "note",      titre = "Un peu d'histoire" },
  exercice   = { type = "caution",   titre = "Exercice" },
  solution   = { type = "tip",       titre = "Correction" },
  correction = { type = "tip",       titre = "Correction" },
}

local afficher_solutions = true
local num_exercice = 0

local function lire_meta(meta)
  if meta.solutions ~= nil then
    afficher_solutions = pandoc.utils.stringify(meta.solutions) ~= "false"
  end
end

local function encadre(div)
  -- Les blocs .hint / .solution liés à un exercice interactif
  -- (attribut exercise="…") sont gérés par quarto-live / pyodide-pdf.lua.
  if div.attributes["exercise"] ~= nil then
    return nil
  end

  for classe, def in pairs(encadres) do
    if div.classes:includes(classe) then
      local est_solution = classe == "solution" or classe == "correction"
      if est_solution and not afficher_solutions then
        return {}
      end

      local titre = def.titre
      if classe == "exercice" then
        num_exercice = num_exercice + 1
        titre = titre .. " " .. num_exercice
      end
      if div.attributes["title"] ~= nil then
        titre = titre .. " — " .. div.attributes["title"]
      end

      local repli = nil
      if est_solution then
        repli = quarto.doc.is_format("html")
      elseif div.attributes["collapse"] ~= nil then
        repli = div.attributes["collapse"] == "true"
      end

      return quarto.Callout({
        type = def.type,
        title = pandoc.Inlines(pandoc.read(titre, "markdown").blocks[1].content),
        content = div.content,
        collapse = repli,
        appearance = "default",
      })
    end
  end
  return nil
end

-- Quarto transforme lui-même les blocs `.solution` en « preuves » (Proof)
-- avant nos filtres : on récupère le bloc d'origine pour en faire un encadré.
local function preuve(p)
  if p.type == "Solution" and p.div ~= nil then
    if not p.div.classes:includes("solution") then
      p.div.classes:insert("solution")
    end
    return encadre(p.div)
  end
  return nil
end

return {
  { Meta = lire_meta },
  { Div = encadre, Proof = preuve },
}
