--[[
  pyodide-pdf.lua — Rend les blocs Python interactifs ({pyodide}) lisibles
  dans les formats non-HTML (PDF/LaTeX).

  En HTML, l'extension quarto-live transforme ces blocs en éditeurs Python
  exécutables dans le navigateur. En PDF, ce filtre :
    - convertit chaque bloc {pyodide} en bloc de code Python classique,
      précédé d'une mention « Code interactif » ;
    - supprime les blocs de préparation (`#| setup: true`) et les indices ;
    - affiche les solutions liées aux exercices (sauf si `solutions: false`).
]]

if quarto.doc.is_format("html") then
  return {}
end

local afficher_solutions = true

local function lire_meta(meta)
  if meta.solutions ~= nil then
    afficher_solutions = pandoc.utils.stringify(meta.solutions) ~= "false"
  end
end

local function est_pyodide(bloc)
  return bloc.classes:includes("{pyodide}")
      or bloc.classes:includes("pyodide")
      or bloc.classes:includes("{pyodide-python}")
end

local function code_block(bloc)
  if not est_pyodide(bloc) then
    return nil
  end

  local options, lignes = {}, {}
  for ligne in (bloc.text .. "\n"):gmatch("([^\r\n]*)\r?\n") do
    local cle, valeur = ligne:match("^#|%s*([%w%-]+)%s*:%s*(.-)%s*$")
    if cle then
      options[cle] = valeur
    else
      table.insert(lignes, ligne)
    end
  end

  -- Blocs de préparation ou masqués : rien à imprimer.
  if options["setup"] == "true" or options["echo"] == "false"
      or options["include"] == "false" then
    return {}
  end

  -- Retire les lignes vides en fin de bloc.
  while #lignes > 0 and lignes[#lignes]:match("^%s*$") do
    table.remove(lignes)
  end

  local etiquette = options["exercise"] and "Exercice interactif" or "Code interactif"
  local mention = pandoc.RawBlock("latex",
    "\\pyinteractif{" .. etiquette .. "}")
  local code = pandoc.CodeBlock(table.concat(lignes, "\n"), { class = "python" })
  return { mention, code }
end

-- Indices des exercices interactifs : inutiles sur papier.
local function div(bloc)
  if bloc.attributes["exercise"] ~= nil and bloc.classes:includes("hint") then
    return {}
  end
  return nil
end

-- Solutions des exercices interactifs (Quarto les range dans un nœud Proof).
local function preuve(p)
  if p.type ~= "Solution" or p.div == nil
      or p.div.attributes["exercise"] == nil then
    return nil
  end
  if not afficher_solutions then
    return {}
  end
  return quarto.Callout({
    type = "tip",
    title = "Correction",
    content = p.div.content,
    collapse = false,
  })
end

return {
  { Meta = lire_meta },
  { CodeBlock = code_block, Div = div, Proof = preuve },
}
