
local BRIDGE_A    = "meBridge_2"   -- Quelle links
local BRIDGE_B    = "meBridge_3"   -- Ziel rechts
local EXPORT_SIDE = "east"         -- Kiste steht östlich von Bridge 2
local IMPORT_SIDE = "west"         -- Kiste steht westlich von Bridge 3
local BATCH       = 8              -- 8 Stacks = 512 Items pro Durchlauf

local meA = peripheral.wrap(BRIDGE_A)
local meB = peripheral.wrap(BRIDGE_B)
assert(meA, "meBridge_2 (Quelle) nicht gefunden!")
assert(meB, "meBridge_3 (Ziel) nicht gefunden!")

-- Summiert alle Items in einem Netzwerk
local function total(me)
  local s = 0
  for _, it in pairs(me.listItems()) do
    s = s + (it.amount or 0)
  end
  return s
end

-- Exportiert Items von Netz A in die Kiste
local function export_batch()
  local moved = 0
  local items = meA.listItems()
  table.sort(items, function(a,b) return (a.amount or 0) > (b.amount or 0) end)
  for _, it in ipairs(items) do
    local have = it.amount or 0
    if have > 0 then
      local n = meA.exportItem({ name = it.name, count = math.min(64*BATCH, have) }, EXPORT_SIDE) or 0
      if n > 0 then moved = moved + n end
    end
  end
  return moved
end

-- Importiert Items von der Kiste in Netz B
local function import_all()
  while true do
    local n = meB.importItem({ from = IMPORT_SIDE, count = 64*BATCH }) or 0
    if n <= 0 then break end
  end
end

-- Hauptlogik
print("Starte Transfer: meBridge_2 → Kiste → meBridge_3")
local start = total(meA)
local moved = 0

while true do
  local n = export_batch()
  if n <= 0 then break end
  import_all()
  moved = moved + n
  local rest = total(meA)
  local pct = start > 0 and (100 * (start - rest) / start) or 100
  print(("Fortschritt: %d/%d (%.1f%%)"):format(start - rest, start, pct))
end

import_all()
print("Fertig! Insgesamt übertragen: " .. moved .. " Items.")
print("Tipp: In Netz B nur die Ziel-Storage-Cell aktiv lassen oder ihr die höchste Priorität geben.")
