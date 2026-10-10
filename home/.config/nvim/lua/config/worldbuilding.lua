local M = {}

-- Entries only hold data; the look lives in worldbuild/wikistyle.sty.
-- Keys left empty are hidden in the PDF. Values with commas need braces.
local templates = {
  character_main = [[
\begin{character}{{{NAME}}}{
  type       = main,
  role       = Protagonist,
  image      = {{SLUG}},
  age        = ,
  house      = ,
  origin     = ,
  occupation = ,
}

\field{Appearance}

\field{Personality}

\field{Backstory}

\field{Motivation}

\field{Arc}

\field{Relationships}

\end{character}
]],
  character_support = [[
\begin{character}{{{NAME}}}{
  type       = supportive,
  role       = Supporting character,
  image      = {{SLUG}},
  age        = ,
  house      = ,
  origin     = ,
  occupation = ,
}

\field{Relation to Protagonist}

\field{Personality}

\field{Purpose in the Story}

\end{character}
]],
  character_villain = [[
\begin{character}{{{NAME}}}{
  type       = villain,
  role       = Antagonist,
  image      = {{SLUG}},
  age        = ,
  house      = ,
  origin     = ,
  occupation = ,
}

\field{Motivation}

\field{Methods}

\field{Weakness}

\field{Relationship to Protagonist}

\field{Endgame}

\end{character}
]],
  house = [[
\begin{house}{{{NAME}}}{
  image      = {{SLUG}},
  color      = ,
  words      = ,
  sigil      = ,
  ruler      = ,
  capital    = ,
  region     = ,
  banovi     = {},
  religion   = ,
  climate    = ,
  population = ,
  economy    = ,
  military   = ,
  allies     = {},
  rivals     = {},
}

\field{Overview}

\field{History}

\field{Lands and Climate}

\field{Livelihood and Trade}

\field{Banovi and Vassals}

\field{Relations with Other Houses}

\field{Military}

\field{Faith and Customs}

\field{Notable Members}

\end{house}
]],
  location = [[
\begin{location}{{{NAME}}}{
  image      = {{SLUG}},
  kind       = ,
  house      = ,
  region     = ,
  ruler      = ,
  population = ,
  climate    = ,
  economy    = ,
  defenses   = ,
}

\field{Description}

\field{History}

\field{Significance to the Story}

\field{Notable Events}

\field{Inhabitants}

\field{Points of Interest}

\end{location}
]],
  freeform = [[
\begin{entry}{{{NAME}}}

\end{entry}
]],
}

local translit = {
  ["č"] = "c", ["ć"] = "c", ["š"] = "s", ["ž"] = "z", ["đ"] = "dj",
  ["Č"] = "c", ["Ć"] = "c", ["Š"] = "s", ["Ž"] = "z", ["Đ"] = "dj",
}

local function slugify(name)
  local slug = vim.trim(name)
  for from, to in pairs(translit) do
    slug = slug:gsub(from, to)
  end
  slug = slug:lower():gsub("%s+", "-"):gsub("[^%w%-]", "")
  return slug
end

local function render(template_key, name)
  local slug = slugify(name)
  local text = templates[template_key]
  text = text:gsub("{{NAME}}", function() return name end)
  text = text:gsub("{{SLUG}}", function() return slug end)
  return text
end

local function root_pointer(target_dir)
  local after = target_dir:match("worldbuild/?(.*)$") or ""
  local depth = 0
  for _ in after:gmatch("[^/]+") do depth = depth + 1 end
  return string.rep("../", depth) .. "wiki.tex"
end

local function new_note(dir, template_key, label)
  vim.ui.input({ prompt = label .. " name: " }, function(name)
    if not name then return end
    name = vim.trim(name)
    if name == "" then return end
    local root = vim.fn.getcwd()
    local target_dir = root .. "/" .. dir
    vim.fn.mkdir(target_dir, "p")
    local filename = target_dir .. "/" .. slugify(name) .. ".tex"
    if vim.fn.filereadable(filename) == 0 then
      local body = render(template_key, name)
      local content = "% !TEX root = " .. root_pointer(dir) .. "\n\n" .. body
      vim.fn.writefile(vim.split(content, "\n"), filename)
    end
    vim.cmd("edit " .. vim.fn.fnameescape(filename))
    M.build_index()
  end)
end

function M.new_character()
  vim.ui.select({ "Main", "Supportive", "Villain" }, { prompt = "Character type:" }, function(choice)
    if not choice then return end
    local map = {
      Main = { "worldbuild/characters/main", "character_main" },
      Supportive = { "worldbuild/characters/supportive", "character_support" },
      Villain = { "worldbuild/characters/villains", "character_villain" },
    }
    new_note(map[choice][1], map[choice][2], choice .. " character")
  end)
end

function M.new_house() new_note("worldbuild/houses", "house", "House") end
function M.new_location() new_note("worldbuild/locations", "location", "Location") end
function M.new_plot() new_note("worldbuild/plot", "freeform", "Plot entry") end
function M.new_history() new_note("worldbuild/history", "freeform", "History entry") end
function M.new_brainstorm() new_note("worldbuild/brainstorm", "freeform", "Brainstorm entry") end

-- groups: sub-folder -> heading shown in the table of contents
local CATEGORIES = {
  { name = "houses", dir = "worldbuild/houses" },
  { name = "locations", dir = "worldbuild/locations" },
  {
    name = "characters",
    dir = "worldbuild/characters",
    groups = {
      main = "Main Characters",
      supportive = "Supporting Characters",
      villains = "Antagonists",
    },
  },
  { name = "plot", dir = "worldbuild/plot" },
  { name = "history", dir = "worldbuild/history" },
  { name = "brainstorm", dir = "worldbuild/brainstorm" },
}

function M.build_index()
  local root = vim.fn.getcwd()
  local worldbuild = root .. "/worldbuild"
  local total = 0

  for _, cat in ipairs(CATEGORIES) do
    local full_dir = root .. "/" .. cat.dir
    vim.fn.mkdir(full_dir, "p")
    local files = vim.fn.globpath(full_dir, "**/*.tex", false, true)
    table.sort(files)

    local lines = {}
    local current_group = nil
    for _, f in ipairs(files) do
      local rel = f:sub(#worldbuild + 2):gsub("%.tex$", "")
      local group = cat.groups and rel:match("^[^/]+/([^/]+)/")
      if group and group ~= current_group and cat.groups[group] then
        table.insert(lines, "\\wikigroup{" .. cat.groups[group] .. "}")
        current_group = group
      end
      table.insert(lines, "\\input{" .. rel .. "}")
      total = total + 1
    end

    vim.fn.writefile(lines, worldbuild .. "/_index_" .. cat.name .. ".tex")
  end

  vim.notify("Wiki index rebuilt (" .. total .. " entries)", vim.log.levels.INFO)
end

return M
