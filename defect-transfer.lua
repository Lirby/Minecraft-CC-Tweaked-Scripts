-- detect_transfer.lua
-- Auto-Detect der richtigen Sides + Item-Transfer
-- Annahme: meBridge_2 = Quelle (Netz A), meBridge_3 = Ziel (Netz B)
-- Zwischen den Bridges steht eine Kiste (oder anderes Inventar), die BEIDE Bridges physisch berührt.

local SRC = "meBridge_2"
local DST = "meBridge_3"
local SIDES = {"up","down","north","south","west","east"}
local BATCH_STACKS = 8

local function wrapOrDie(n)
  local p = peripheral.wrap(n)
  if not p then error("Peripherie nicht gefunden: "..n) end
  return p
end

local a = wrapOrDie(SRC)
local b = wrapOrDie(DST)

-- Nimm irgendein vorhandenes Item aus Netz A als Testobjekt
local function pickTestItem()
  local items = a.listItems()
  for _, it in ipairs(items) do
    if (it.amount or 0) > 0 then
      return { name = it.name, displayName = it.displayName or it.name }
    end
  end
  error("Netz A ist leer – kein Test/Transfer möglich.")
end

-- Versuche Export je Side, liefere Seite zurück, die >0 bewegt.
local function detectExportSide(testItem)
  for _, s in ipairs(SIDES) do
    local moved = a.exportItem({ name = testItem.name, count = 1 }, s) or 0
    if moved > 0 then
      -- 1 Item liegt jetzt in der Kiste an Seite s. Versuche, es gleich wieder zurück zu holen,
      -- damit die Kiste nicht zugemüllt wird:
      local tookBack = a.importItem({ count = 1 }, s) or 0
      return s
    end
  end
  error("An keiner Seite von "..SRC.." wurde ein Inventar gefunden. Steht die Kiste DIREKT an der Bridge?")
end

-- Um die Import-Seite zu prüfen, legen wir ein Testitem an alle Export-Sides von A
-- und schauen, bei welcher Side B erfolgreich importiert.
local function detectImportSide(testItem, exportSideA)
  -- lege 1 Testitem in die Kiste an exportSideA
  local moved = a.exportItem({ name = testItem.name, count = 1 }, exportSideA) or 0
  if moved <= 0 then
    error("Konnte Testitem nicht in die Kiste an "..exportSideA.." exportieren.")
  end
  local detected = nil
  for _, s in ipairs(SIDES) do
    local n = b.importItem({ count = 1 }, s) or 0
    if n > 0 then detected = s; break end
  end
  if not detected then
    error("Ziel-Bridge "..DST.." sieht die Kiste an keiner Seite. Berührt sie die Kiste direkt?")
  end
  return detected
end

local function listUniqueItems(me)
  local seen, out = {}, {}
  for _, it in ipairs(me.listItems()) do
    if it.name and not seen[it.name] then
      seen[it.name] = true
      table.insert(out, { name=it.name, displayName=it.displayName or it.name, amount=it.amount or 0 })
    end
  end
  table.sort(out, function(x,y) return x.displayName < y.displayName end)
  return out
end

local function searchMatches(all, q)
  q = q:lower()
  local m = {}
  for _, it in ipairs(all) do
    if it.name:lower():find(q, 1, true) or it.displayName:lower():find(q,1,true) then
      table.insert(m, it)
    end
  end
  return m
end

local function exportChosen(name, side, want)
  local left = want
  local movedTotal = 0
  local batch = 64 * BATCH_STACKS
  while left == nil or left > 0 do
    local count = left and math.min(batch, left) or batch
    local n = a.exportItem({ name = name, count = count }, side) or 0
    if n <= 0 then break end
    movedTotal = movedTotal + n
    if left then left = left - n end
  end
  return movedTotal
end

local function importAll(side)
  local batch = 64 * BATCH_STACKS
  local movedTotal = 0
  while true do
    local n = b.importItem({ count = batch }, side) or 0
    if n <= 0 then break end
    movedTotal = movedTotal + n
  end
  return movedTotal
end

-- === Detect ===
print("Ermittle Sides…")
local testItem = pickTestItem()
local EXP = detectExportSide(testItem)
local IMP = detectImportSide(testItem, EXP)
print(("Gefundene Sides: EXPORT_SIDE=%s, IMPORT_SIDE=%s"):format(EXP, IMP))

-- === Item-Auswahl ===
print("\nWelches Item willst du verschieben?")
io.write("> ")
local q = read()
local all = listUniqueItems(a)
local matches = searchMatches(all, q)
if #matches == 0 then error("Kein Treffer für '"..q.."' in Netz A.") end

local choice
if #matches == 1 then
  choice = matches[1]
  print(("Gefunden: %s (%s), Menge: %d"):format(choice.displayName, choice.name, choice.amount))
else
  print(("Mehrere Treffer für '%s':"):format(q))
  for i,it in ipairs(matches) do
    print(("[%d] %s  (%s)  x%d"):format(i, it.displayName, it.name, it.amount))
  end
  io.write("Nummer: ")
  local n = tonumber(read())
  if not n or n < 1 or n > #matches then error("Ungültige Auswahl.") end
  choice = matches[n]
end

io.write("Menge (leer = alles): ")
local t = read()
local WANT = tonumber(t)
if not WANT then
  -- alles von diesem Item in Netz A summieren
  local sum = 0
  for _, it in ipairs(a.listItems()) do
    if it.name == choice.name then sum = sum + (it.amount or 0) end
  end
  WANT = sum
end
if WANT <= 0 then error("Von diesem Item ist nichts in Netz A.") end

print(("\nTransferiere %d × %s …"):format(WANT, choice.name))
local moved = 0
while moved < WANT do
  local e = exportChosen(choice.name, EXP, WANT - moved)
  if e <= 0 then break end
  importAll(IMP)
  moved = moved + e
  local pct = math.min(100, (moved*100.0)/WANT)
  print(("Fortschritt: %d/%d (%.1f%%)"):format(moved, WANT, pct))
end
-- Rest aus der Kiste ins Ziel
importAll(IMP)
print(("Fertig! Übertragen: %d × %s"):format(moved, choice.name))
print("Hinweis: In Netz B nur die Ziel-Cell aktiv lassen oder höchste Priorität setzen.")
