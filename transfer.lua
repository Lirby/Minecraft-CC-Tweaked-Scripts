local BRIDGE_A = "meBridge_0"
local BRIDGE_B = "meBridge_1"
local BUFFER = "minecraft:barrel_0"
local BATCH = 8

local meA = peripheral.wrap(BRIDGE_A)
local meB = peripheral.wrap(BRIDGE_B)
local buf = peripheral.wrap(BUFFER)

assert(meA, "meBridge_0 nicht gefunden!")
assert(meB, "meBridge_1 nicht gefunden!")
assert(buf, "minecraft:barrel_0 nicht gefunden!")

local function total(me)
  local sum = 0
  for _, it in pairs(me.listItems()) do
    sum = sum + (it.amount or 0)
  end
  return sum
end

local function export_batch()
  local moved = 0
  local items = meA.listItems()
  table.sort(items, function(a,b) return (a.amount or 0) > (b.amount or 0) end)
  for _, it in ipairs(items) do
    local have = it.amount or 0
    if have > 0 then
      local n = meA.exportItem({ name = it.name, count = math.min(64 * BATCH, have) }, BUFFER) or 0
      if n > 0 then moved = moved + n end
    end
  end
  return moved
end

local function import_all()
  while true do
    local n = meB.importItem({ from = BUFFER, count = 64 * BATCH }) or 0
    if n <= 0 then break end
  end
end

print("Starte Transfer: meBridge_0 → Barrel → meBridge_1 ...")
local start = total(meA)
local moved = 0

while true do
  local n = export_batch()
  if n <= 0 then break end
  import_all()
  moved = moved + n
  local rest = total(meA)
  local pct = start > 0 and (100 * (start - rest) / start) or 100
  print(("Fortschritt: %d / %d (%.1f%%)"):format(start - rest, start, pct))
end

import_all()
print("Fertig! Insgesamt übertragen: " .. moved .. " Items.")
print("Tipp: In Netz B nur die Ziel-Storage-Cell aktiv lassen oder ihr die höchste Priorität geben.")