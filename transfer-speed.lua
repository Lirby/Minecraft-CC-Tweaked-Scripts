local BRIDGE_A    = "meBridge_2"
local BRIDGE_B    = "meBridge_3"
local EXPORT_SIDE = "east"
local IMPORT_SIDE = "west"
local BATCH_STACKS = 8  -- 8 Stacks = 512 Items pro Batch

local function wrapOrDie(name, what)
  local p = peripheral.wrap(name)
  if not p then error(what .. " '" .. name .. "' nicht gefunden") end
  return p
end

local meA = wrapOrDie(BRIDGE_A, "Quelle")
local meB = wrapOrDie(BRIDGE_B, "Ziel")

local function total(me)
  local s=0; for _,it in pairs(me.listItems()) do s=s+(it.amount or 0) end; return s
end

local function listUniqueItems(me)
  local seen, out = {}, {}
  for _, it in pairs(me.listItems()) do
    if it.name and not seen[it.name] then
      seen[it.name] = true
      table.insert(out, { name=it.name, displayName=it.displayName or it.name, amount=it.amount or 0 })
    end
  end
  table.sort(out, function(a,b) return a.displayName < b.displayName end)
  return out
end

local function searchMatches(all, query)
  query = query:lower()
  local matches = {}
  for _, it in ipairs(all) do
    if it.name:lower():find(query, 1, true) or (it.displayName:lower():find(query, 1, true)) then
      table.insert(matches, it)
    end
  end
  return matches
end

-- ---------- UI: frage nach Item ----------
print("Welches Item willst du verschieben?")
print("Gib den genauen Namen (z.B. minecraft:iron_ingot) ODER einen Teilnamen ein.")
io.write("> ")
local query = read()
if not query or query == "" then error("Kein Suchbegriff eingegeben.") end

local all = listUniqueItems(meA)
local matches = searchMatches(all, query)

if #matches == 0 then
  error("Kein Item im Quell-Netz gefunden, das zu '"..query.."' passt.")
end

local chosen
if #matches == 1 then
  chosen = matches[1]
  print(("Gefunden: %s (%s) – Menge im Netz: %d")
    :format(chosen.displayName, chosen.name, chosen.amount))
else
  print(("Mehrere Treffer für '%s':"):format(query))
  for i,it in ipairs(matches) do
    print(("[%d] %s  (%s)  x%d"):format(i, it.displayName, it.name, it.amount))
  end
  io.write("Wähle eine Nummer: ")
  local n = tonumber(read())
  if not n or n < 1 or n > #matches then error("Ungültige Auswahl.") end
  chosen = matches[n]
end

io.write("Menge (leer = alles verfügbare von diesem Item): ")
local want = read()
local WANT_COUNT = tonumber(want)  -- nil => alles

-- ---------- Transfer nur für das gewählte Item ----------
local function exportChosen(maxCount)
  local left = maxCount -- kann nil sein
  local batch = 64 * BATCH_STACKS
  local movedTotal = 0

  while left == nil or left > 0 do
    local count = left and math.min(batch, left) or batch
    -- WICHTIG: 2. Parameter ist die SIDE an der BRIDGE, nicht der Peripherie-Name!
    local moved = meA.exportItem({ name = chosen.name, count = count }, EXPORT_SIDE) or 0
    if moved <= 0 then break end
    movedTotal = movedTotal + moved
    if left then left = left - moved end
  end
  return movedTotal
end

local function importAllFromSide()
  local batch = 64 * BATCH_STACKS
  local movedTotal = 0
  while true do
    -- WICHTIG: "from" ist die SIDE an der ZIEL-BRIDGE
    local moved = meB.importItem({ from = IMPORT_SIDE, count = batch }) or 0
    if moved <= 0 then break end
    movedTotal = movedTotal + moved
  end
  return movedTotal
end

print(("Starte Transfer des Items: %s (%s)"):format(chosen.displayName, chosen.name))
local startHave = 0
for _, it in pairs(meA.listItems()) do
  if it.name == chosen.name then startHave = startHave + (it.amount or 0) end
end
local targetTo
